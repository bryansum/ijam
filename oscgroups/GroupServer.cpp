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

#include "GroupServer.h"

#include <string>
#include <set>
#include <iostream>
#include <time.h>
#include <algorithm>
#include <iterator>
#include <assert.h>

#include "ip/NetworkingUtils.h"

/*
TODO:
    switch to using char * instead of string:: to avoid allocating new strings
    every time we execute a find()
*/


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


GroupServer::GroupServer( int timeoutSeconds, int maxUsers, int maxGroups )
    : timeoutSeconds_( timeoutSeconds )
    , maxUsers_( maxUsers )
    , maxGroups_( maxGroups )
    , userCount_( 0 )
    , groupCount_( 0 )
{

}


GroupServer::~GroupServer()
{
    for( const_user_iterator i = users_begin(); i != users_end(); ++i )
        delete i->second;
    for( const_group_iterator i = groups_begin(); i != groups_end(); ++i )
        delete i->second;
}


User *GroupServer::CreateUser( const char *userName, const char *userPassword )
{
    Log() << "creating user '" << userName << "'." << std::endl;
    
    User *user = new User( userName, userPassword );
    std::pair<user_iterator,bool> r =
            users_.insert( std::make_pair( user->name, user ) );
    // we assume the caller didn't try to create a user with an existing name
    assert( r.second == true );
    ++userCount_;

    return user;
}


User *GroupServer::FindUser( const char *userName )
{
    user_iterator user = users_.find( userName );

    return ( user != users_.end() ) ? user->second : (User*) 0;
}


void GroupServer::PurgeStaleUsers()
{
    unsigned long currentTime = time(0);
    
    for( std::map< std::string, User* >::iterator i = users_.begin();
            i != users_.end(); /* nothing */ ){

        unsigned long inactiveSeconds =
                i->second->SecondsSinceLastAliveReceived( currentTime );
        if( inactiveSeconds >= (unsigned int)timeoutSeconds_ ){
            Log() << "purging user '" << i->second->name << "' after "
                    << inactiveSeconds << " seconds of inactivity." << std::endl;

            SeparateUserFromAllGroups( i->second );
            delete i->second;
            --userCount_;
                
            // i think this is safe, we increment i before erasing the
            // element referenced by its old value...
            std::map< std::string, User* >::iterator j = i;
            ++i;
            users_.erase( j );
        }else{
            ++i;
        }
    }
}


Group *GroupServer::CreateGroup(
        const char *groupName, const char *groupPassword )
{
    Log() << "creating group '" << groupName << "'." << std::endl;
    
    Group *group = new Group( groupName, groupPassword );
    std::pair<group_iterator, bool> r =
            groups_.insert( std::make_pair( group->name, group ) );
    // we assume the caller didn't try to create an existing group
    assert( r.second == true );
    ++groupCount_;

    return group;
}


Group *GroupServer::FindGroup( const char *groupName )
{
    group_iterator group = groups_.find( groupName );

    return ( group != groups_.end() ) ? group->second : (Group*) 0;
}


// The User <-> Group relation is managed as a bidirectional link (each User
// contains a set of groups which it is associated with, and each Group
// maintains a set of Users which it is associated with). The Associate*
// and Separate* methods below create and destroy the bidirectional link
// RemoveUserReferenceFromGroup is a helper function which only destroys
// one side of the link.

void GroupServer::AssociateUserWithGroup( User *user, Group* group )
{
    Log() << "adding user '" << user->name
            << "' to group '" << group->name << "'." << std::endl;
    
    user->groups_.insert( group );
    group->users_.insert( user );
}


void GroupServer::RemoveUserReferenceFromGroup( User *user, Group* group )
{
    Log() << "removing user '" << user->name
            << "' from group '" << group->name << "'." << std::endl;
    
    std::set< User* >::iterator i = group->users_.find( user );
    assert( i != group->users_.end() );

    group->users_.erase( i );

    if( group->users_.empty() ){
        Log() << "purging empty group '" << group->name << "'." << std::endl;
        
        groups_.erase( group->name );
        delete group;
        --groupCount_;
    }
}


void GroupServer::SeparateUserFromGroup( User *user, Group* group )
{
    user->groups_.erase( group );
    RemoveUserReferenceFromGroup( user, group );
}


void GroupServer::SeparateUserFromAllGroups( User *user )
{
    for( std::set<Group*>::iterator i = user->groups_.begin();
            i != user->groups_.end(); ++i ){

        RemoveUserReferenceFromGroup( user, *i);
    }

    user->groups_.clear();
}


static void UpdateEndpoint( IpEndpointName& dest, const IpEndpointName& src,
        const char *userName, const char *whichEndpoint )
{
    if( dest != src ){

		char endpointString[ IpEndpointName::ADDRESS_AND_PORT_STRING_LENGTH ];
		src.AddressAndPortAsString( endpointString );

        Log() << "updating " << whichEndpoint << " endpoint for user '"
                << userName << "' to " << endpointString << "." << std::endl;

        dest = src;
    }
}


GroupServer::UserStatus GroupServer::UserAlive(
        const char *userName, const char *userPassword,
        const IpEndpointName& privateEndpoint,
		const IpEndpointName& publicEndpoint,
        const char **groupNamesAndPasswords,
        UserStatus *userGroupsStatus, int groupCount )
{
    // find or create the user, aborting if the password for an existing
    // user is incorrect, or if the maximum number of users has been reached

    User *user = FindUser( userName );
    if( user ){
        if( user->password.compare( userPassword ) != 0 ){
            Log() << "attempt to update user '"
                    << userName << "' with incorrect password." << std::endl;
            return USER_STATUS_WRONG_PASSWORD;
        }
    }else{
        if( userCount_ == maxUsers_ ){
            Log() << "user limit reached, user '"
                    << userName << "' not admitted." << std::endl;
            return USER_STATUS_SERVER_LIMIT_REACHED;
        }else{
            user = CreateUser( userName, userPassword );
        }
    }

    UpdateEndpoint(
            user->privateEndpoint, privateEndpoint, userName, "private" );
    UpdateEndpoint( user->publicEndpoint, publicEndpoint, userName, "public" );

    user->lastAliveMessageArrivalTime = time(0);


    // previousButNotCurrentGroups begins containing all the groups the user
    // was in before the current message was received. We remove those which
    // the user is still a member of, leaving the set that the user is no
    // longer a member of. We then use the set to remove associations with
    // non-current groups.

    std::set<Group*> previousButNotCurrentGroups( user->groups_ );

    for( int i=0; i < groupCount; ++i ){
        const char *groupName = groupNamesAndPasswords[i*2];
        const char *groupPassword = groupNamesAndPasswords[i*2 + 1];

        Group *group = FindGroup( groupName );
        if( group ){
            if( user->IsMemberOf( group ) ){
                // check that previousButNotCurrentGroups contains group before
                // removing it. it won't if we were passed the same group
                // multiple times
                std::set<Group*>::iterator j =
                        previousButNotCurrentGroups.find( group );
                if( j != previousButNotCurrentGroups.end() )
                    previousButNotCurrentGroups.erase( j );

                userGroupsStatus[i] = USER_STATUS_OK;
            }else{
                // user isn't in group so join it
                if( group->password.compare( groupPassword ) == 0 ){
                    AssociateUserWithGroup( user, group );
                    userGroupsStatus[i] = USER_STATUS_OK;
                }else{                                   
                    userGroupsStatus[i] = USER_STATUS_WRONG_PASSWORD;
                }
            }
        }else{  // group doesn't exist
            if( groupCount_ == maxGroups_ ){
                Log() << "group limit reached, group '"
                        << groupName << "' not created." << std::endl;
                userGroupsStatus[i] = USER_STATUS_SERVER_LIMIT_REACHED;
            }else{
                group = CreateGroup( groupName, groupPassword );
                AssociateUserWithGroup( user, group );
                userGroupsStatus[i] = USER_STATUS_OK;
            }
        }
    }

    for( std::set<Group*>::iterator j = previousButNotCurrentGroups.begin();
            j != previousButNotCurrentGroups.end(); ++j ){

        SeparateUserFromGroup( user, *j );
    }

    return USER_STATUS_OK;
}

