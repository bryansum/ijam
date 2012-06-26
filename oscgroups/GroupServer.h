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

#ifndef INCLUDED_GROUPSERVER_H
#define INCLUDED_GROUPSERVER_H

// GroupServer.h/cpp implements user and group admission control using passwords
// Users live as long as they are sending alive messages more frequency
// than the timeout value. Groups live as long as they have members.
// Once Users and Groups are destroyed they can be reused with different
// passwords.
// This module has no dependence on the messaging protocol, although it does
// assume IPV4 addresses.


#include <map>
#include <set>
#include <string>

#include "ip/IpEndpointName.h"

class User;
class Group;
class GroupServer;


class User{
    friend class GroupServer;
    
    std::set<Group*> groups_;

public:
    User( const char *userName, const char *userPassword )
        : name( userName )
        , password( userPassword ) {}
        
    std::string name;
    std::string password;
    
    IpEndpointName privateEndpoint;
	IpEndpointName publicEndpoint;

    unsigned long lastAliveMessageArrivalTime;

    unsigned long SecondsSinceLastAliveReceived( unsigned long currentTime )
            { return currentTime - lastAliveMessageArrivalTime; }

    bool IsMemberOf( Group *group ) const
            { return groups_.count( group ) == 1; }
    
    typedef std::set<Group*>::const_iterator const_group_iterator;
    const_group_iterator groups_begin() const { return groups_.begin(); }
    const_group_iterator groups_end() const { return groups_.end(); }
};


class Group{
    friend class GroupServer;
    
    std::set<User*> users_;
     
public:
    Group( const char *groupName, const char *groupPassword )
        : name( groupName )
        , password( groupPassword ) {}
        
    std::string name;
    std::string password;
    
    typedef std::set<User*>::const_iterator const_user_iterator;
    const_user_iterator users_begin() const { return users_.begin(); }
    const_user_iterator users_end() const { return users_.end(); }
};


class GroupServer{
    const int timeoutSeconds_;
    const int maxUsers_;
    const int maxGroups_;
    
    typedef std::map< std::string, User* > user_map;
    typedef user_map::iterator user_iterator;
    user_map users_;
    int userCount_;
    
    typedef std::map< std::string, Group* > group_map;
    typedef group_map::iterator group_iterator;
    group_map groups_;
    int groupCount_;

    User *CreateUser( const char *userName, const char *userPassword );

    Group *CreateGroup( const char *groupName, const char *groupPassword );
    void AssociateUserWithGroup( User *user, Group* group );
    void RemoveUserReferenceFromGroup( User *user, Group* group );
    void SeparateUserFromGroup( User *user, Group* group );
    void SeparateUserFromAllGroups( User *user );

public:
    GroupServer( int timeoutSeconds, int maxUsers, int maxGroups );
    ~GroupServer();

    enum UserStatus {
            USER_STATUS_UNKNOWN,
            USER_STATUS_OK,
            USER_STATUS_WRONG_PASSWORD,
            USER_STATUS_SERVER_LIMIT_REACHED
        };

    UserStatus UserAlive( const char *userName, const char *userPassword,
            const IpEndpointName& privateEndpoint,
			const IpEndpointName& publicEndpoint,
            const char **groupNamesAndPasswords,
            UserStatus *userGroupsStatus, int groupCount );

    typedef user_map::const_iterator const_user_iterator;
    const_user_iterator users_begin() const { return users_.begin(); }
    const_user_iterator users_end() const { return users_.end(); }
    User *FindUser( const char *userName );

    typedef group_map::const_iterator const_group_iterator;
    const_group_iterator groups_begin() const { return groups_.begin(); }
    const_group_iterator groups_end() const { return groups_.end(); }
    Group *FindGroup( const char *groupName );

    void PurgeStaleUsers();
};


#endif /* INCLUDED_GROUPSERVER_H */
