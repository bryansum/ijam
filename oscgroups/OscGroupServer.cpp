/*
OSCgroups -- open sound control groupcasting infrastructure
Copyright (C) 2005  Ross Bencina

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#include "OscGroupServer.h"

#include <string.h>
#include <iostream>
#include <fstream>
#include <cassert>
#include <time.h>

#include "osc/OscReceivedElements.h"
#include "osc/OscOutboundPacketStream.h"

#include "ip/UdpSocket.h"
#include "osc/OscPacketListener.h"
#include "ip/TimerListener.h"

#include "GroupServer.h"


static std::ostream& Log()
{
    std::time_t t;
    time( &t );

    // ctime() returns a constant width 26 char string including trailing \0
    // the fields are all constant width.
    char s[26];
    strcpy( s, std::ctime( &t ) );
    s[24] = '\0'; // remove trailing null

    std::cout << s << ": ";
    return std::cout;
}


static const char *UserStatusToString( GroupServer::UserStatus userStatus )
{
    switch( userStatus ){
        case GroupServer::USER_STATUS_OK:
            return "ok";
        case GroupServer::USER_STATUS_WRONG_PASSWORD:
            return "wrong password";
        case GroupServer::USER_STATUS_SERVER_LIMIT_REACHED:
            return "user limit reached";
        case GroupServer::USER_STATUS_UNKNOWN:
            /* FALLTHROUGH */ ;
    }

    return "unknown";
}


class OscGroupServerListener
    : public osc::OscPacketListener
    , public TimerListener
{

    GroupServer groupServer_;
    UdpSocket& externalSocket_;

    #define IP_MTU_SIZE 1536
    char buffer_[IP_MTU_SIZE];
    osc::OutboundPacketStream resultStream_;
    unsigned int emptyResultSize_;

    void user_alive( const osc::ReceivedMessage& m, 
				const IpEndpointName& remoteEndpoint )
    {
        // /groupserver/user_alive
        //      userName password
        //      privateIpAddress privatePort
        //      groupName0 groupPassword0 groupName1 groupPassword1 ...

        osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
        const char *userName, *userPassword;
        long privateAddress, privatePort;

        args >> userName >> userPassword >> privateAddress >> privatePort;

        // addresses are transmitted as ones complement (bit inverse)
        // to avoid problems with buggy NATs trying to re-write addresses
        privateAddress = ~privateAddress;

		IpEndpointName privateEndpoint( privateAddress, privatePort );

        int groupCount = (m.ArgumentCount() - 4) / 2;
        const char **groupNamesAndPasswords = 0;
        GroupServer::UserStatus *userGroupsStatus = 0;
        if( groupCount > 0 ){
            groupNamesAndPasswords = new const char*[ groupCount * 2 ];
            int i = 0;
            while( !args.Eos() ){
                args >> groupNamesAndPasswords[i++];    // group name
                args >> groupNamesAndPasswords[i++];    // group password
            }

            userGroupsStatus = new GroupServer::UserStatus[ groupCount ];
            for( int j=0; j < groupCount; ++j )
                userGroupsStatus[j] = GroupServer::USER_STATUS_UNKNOWN;
        }

        GroupServer::UserStatus userStatus =
                groupServer_.UserAlive( userName, userPassword,
                        privateEndpoint, remoteEndpoint,
                        groupNamesAndPasswords, userGroupsStatus, groupCount );

        resultStream_ << osc::BeginMessage( "/groupclient/user_alive_status" )
            << userName
            << userPassword
            << UserStatusToString( userStatus )                
            << osc::EndMessage;

        if( userStatus == GroupServer::USER_STATUS_OK ){
            for( int i=0; i < groupCount; ++i ){
                const char *groupName = groupNamesAndPasswords[i*2];
                const char *groupPassword = groupNamesAndPasswords[i*2 + 1];

                resultStream_
                    << osc::BeginMessage( "/groupclient/user_group_status" )
                    << userName
                    << userPassword
                    << groupName
                    << groupPassword
                    << UserStatusToString( userGroupsStatus[i] )
                    << osc::EndMessage;
            }
        }

        delete [] groupNamesAndPasswords;
        delete [] userGroupsStatus;
    }

    void MakeUserInfoMessage( osc::OutboundPacketStream& p,
            User *user, unsigned long currentTime )
    {
        // addresses are transmitted as ones complement (bit inverse)
        // to avoid problems with buggy NATs trying to re-write addresses
        
        p << osc::BeginMessage( "/groupclient/user_info" )
            << user->name.c_str()
            << ~((long)user->privateEndpoint.address)
            << user->privateEndpoint.port
            << ~((long)user->publicEndpoint.address)
            << user->publicEndpoint.port
            << (long)user->SecondsSinceLastAliveReceived( currentTime );

        for( User::const_group_iterator i = user->groups_begin();
                i != user->groups_end(); ++i )
            p << (*i)->name.c_str();
                
        p << osc::EndMessage;
    }

    void get_group_users_info( const osc::ReceivedMessage& m,
            const IpEndpointName& remoteEndpoint )
    {
        // /groupserver/get_group_users_info group-name group-password

        osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
        const char *groupName, *groupPassword;

        args >> groupName >> groupPassword >> osc::EndMessage;

        Group *group = groupServer_.FindGroup( groupName );
        if( group && group->password.compare( groupPassword ) == 0 ){
            unsigned long currentTime = time(0);
            
            for( Group::const_user_iterator i = group->users_begin();
                    i != group->users_end(); ++i )
                MakeUserInfoMessage( resultStream_, *i, currentTime );
        }

        // we don't return a result to the client in the case where the group
        // doesn't exist, or the password is wrong because legitimate clients
        // will have already successfully joined the group, or they will have
        // received an error message when they tried to join.
    }

protected:
    
    virtual void ProcessMessage( const osc::ReceivedMessage& m, 
			const IpEndpointName& remoteEndpoint )
    {
        try{

            if( strcmp( m.AddressPattern(), "/groupserver/user_alive" ) == 0 ){
                user_alive( m, remoteEndpoint );
            }else if( strcmp( m.AddressPattern(), "/groupserver/get_group_users_info" ) == 0 ){
                get_group_users_info( m, remoteEndpoint );
            }

        }catch( osc::Exception& e ){
            Log() << "error while parsing message: " << e.what() << std::endl;
        }
    }

public:
    OscGroupServerListener( int timeoutSeconds, int maxUsers, int maxGroups,
                UdpSocket& externalSocket )
        : groupServer_( timeoutSeconds, maxUsers, maxGroups )
        , externalSocket_( externalSocket )
        , resultStream_( buffer_, IP_MTU_SIZE )
    {
        resultStream_ << osc::BeginBundle();
        resultStream_ << osc::EndBundle;
        emptyResultSize_ = resultStream_.Size();
    }

    virtual void ProcessPacket( const char *data, int size, 
			const IpEndpointName& remoteEndpoint )
    {
        resultStream_.Clear();
        resultStream_ << osc::BeginBundle();

        osc::OscPacketListener::ProcessPacket( data, size, remoteEndpoint );

        resultStream_ << osc::EndBundle;

        assert( resultStream_.IsReady() );

        if( resultStream_.Size() != emptyResultSize_ ){
            char addressString[ IpEndpointName::ADDRESS_AND_PORT_STRING_LENGTH ];
            remoteEndpoint.AddressAndPortAsString( addressString );
		    Log() << "responding to request from " << addressString << "." << std::endl;
            
		    externalSocket_.SendTo(
                    remoteEndpoint, resultStream_.Data(), resultStream_.Size() );
        }
    }

    virtual void TimerExpired()
    {
        groupServer_.PurgeStaleUsers();
    }
};


void RunOscGroupServerUntilSigInt(
        int port, int timeoutSeconds, int maxUsers, int maxGroups, const char *logFile )
{
    std::ofstream *logStream = 0;
    std::streambuf *oldCoutRdbuf = std::cout.rdbuf();

    try{
        if( logFile ){
            std::cout << "oscgroupserver redirecting output to " << logFile << std::endl;
            logStream = new std::ofstream( logFile, std::ios_base::app );
            std::cout.rdbuf( logStream->rdbuf() );
        }
    
        UdpReceiveSocket externalSocket(
                IpEndpointName( IpEndpointName::ANY_ADDRESS, port ) );
        OscGroupServerListener externalSocketListener(
                timeoutSeconds, maxUsers, maxGroups, externalSocket );

        SocketReceiveMultiplexer mux;
        mux.AttachSocketListener( &externalSocket, &externalSocketListener );

        // timer is used for purging inactive users
        mux.AttachPeriodicTimerListener( (timeoutSeconds * 1000) / 10, &externalSocketListener );
    
        Log() << "oscgroupserver listening on port " << port << "...\n"
                << "timeoutSeconds=" << timeoutSeconds << ", "
                << "maxUsers=" << maxUsers << ", "
                << "maxGroups=" << maxGroups << ", "
                << "logFile=" << ((logFile) ? logFile : "stdout") << "\n"
                << "press ctrl-c to end" << std::endl;

        mux.RunUntilSigInt();
        
        Log() << "finishing." << std::endl;

    }catch( std::exception& e ){
        Log() << e.what() << std::endl;
        Log() << "finishing." << std::endl;
    }

    std::cout.rdbuf( oldCoutRdbuf );
    delete logStream;
}


static void usage()
{
    std::cerr << "usage: oscgroupserver [-p port] [-t timeoutSeconds] [-u maxUsers] [-g maxGroups] [-l logfile]\n";
}


int oscgroupserver_main(int argc, char* argv[])
{
    if( argc % 2 != 1 ){
        usage();
        return 0;
    }

    int port = 22242;
    int timeoutSeconds = 60;
    int maxUsers = 100;
    int maxGroups = 50;
    const char *logFile = 0;

    int argIndex = 1;
    while( argIndex < argc ){
        const char *selector = argv[argIndex];
        const char *value = argv[argIndex + 1];
        if( selector[0] == '-' && selector[1] != '\0' && selector[2] == '\0' ){
            switch( selector[1] ){
                case 'p':
                    port = atoi( value );
                    break;
                case 't':
                    timeoutSeconds = atoi( value );
                    break;
                case 'u':
                    maxUsers = atoi( value );
                    break;
                case 'g':
                    maxGroups = atoi( value );
                    break;
                case 'l':
                    logFile = value;
                    break;
                default:
                    usage();
                    return 0;
            }
        }else{
            usage();
            return 0;
        }
        argIndex += 2;
    }
        
    RunOscGroupServerUntilSigInt(
            port, timeoutSeconds, maxUsers, maxGroups, logFile );

    return 0;
}


#ifndef NO_MAIN

int main(int argc, char* argv[])
{
    return oscgroupserver_main( argc, argv );
}

#endif /* NO_MAIN */

