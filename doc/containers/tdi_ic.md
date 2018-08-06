3. Download env.txt from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/env.txt.
   
   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/env.txt
   ```
 
4. Open env.txt and update the variables for your environment:

   - **TDISOL_URL**
   
     The internal download location of your TDI solution directory for Connections.
   
   - **LDAP_TYPE**
   
     The type of your LDAP system. Supported options are:
     
     - AD (Microsoft Active Directory)
     - DOMINO (IBM Domino)
     - DSEE (Oracle Directory Server Enterprise Edition)
     - SDS (IBM Security Directory Server)
     
   - **LDAP_HOST**
   
     The FQDN of your LDAP server.
     
   - **LDAP_PORT**
   
     The port used for LDAP communication (typically 389 or 636).
     
   - **LDAP_BIND_DN**
     
     The distinguished name used to bind to LDAP. For example, LDAP_BIND_DN=cn=ldapbind,ou=ic,dc=ad,dc=com.
   
   - **LDAP_BIND_PWD**
     
     The password for the distinguished name used to bind to LDAP.
   
   - **LDAP_SEARCH_BASE**
     
     The search base used for locating users and groups in LDAP. For example, LDAP_SEARCH_BASE=ou=ic,dc=ad,dc=com.
   
   - **LDAP_SEARCH_FILTER**
     
     The search filter used for locating users in LDAP. Note that special characters like '&' must be escaped with a backslash (\) character. For example: LDAP_SEARCH_FILTER=(\&(uid=*)(objectClass=inetOrgPerson)).
   
   - **DB2_HOST**
     
     The FQDN of your DB2 server.
   
   - **DB2_PORT**
     
     The port used for DB2 communication (typically 50000).
   
   - **DB2_PROFILES_USER**
     
     The user account that owns the profiles database (default is lcuser).
   
   - **DB2_PROFILES_PWD**
     
     The password for the user account that owns the profiles database.