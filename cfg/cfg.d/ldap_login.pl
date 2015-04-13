# LDAP SERVER SETTINGS

# LDAP Server
# The domain name or IP address of your LDAP Server such as "ad.unm.edu".
$c->{ldap_hostname} = "";
$c->{ldap_port} = "";

# LDAP Server Type
# TODO This field is informative. It's purpose is to assist with default values and give validation warnings.
# Active Directory, Default LDAP, Open LDAP ...
# $c->{ldap_server_type} = "";

# Binding method
# TODO Binding Method for Searches. For now only Service Account Bind is supported
# Service Account Bind, Bind with Users Credentials, Anonymous Bind for search, then Bind with Users Credentials,
 Anonymous Bind.
# $c->{ldap_binding_method} = "";

# DN for non-anonymous search. Password is stored somewhere else
$c->{ldap_bind_username} = "";

# Base DNs for LDAP users, groups, and other entries this server configuration.
$c->{ldap_login_base} = "";
$c->{ldap_login_filter} = "()";

# AuthName attribute
$c->{ldap_login_cn} = "";

# AccountName attribute
$c->{ldap_login_accountname} = "";

# Email attribute
$c->{ldap_login_email} = "";

# LDAP query
$c->{ldap_login_attrs} = [ '1.1', 'uid', 'sn', 'givenname', 'mail', 'department', 'personalTitle' ];

# Kerboros settings
$c->{krb_hostname} = "";
