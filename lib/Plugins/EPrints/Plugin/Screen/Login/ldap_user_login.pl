# Kerberos authentication for "user", "editor" and "admin" types (roles)
   
$c->{check_user_password} = sub {
	my( $repo, $username, $password ) = @_;

	# try local login first
	my $res = $repo->get_database->valid_login( $username, $password );
	return $res if defined $res;

	# try kerberos login
	use Authen::Krb5::Simple;
   	my $krb = Authen::Krb5::Simple->new( realm => $repo->config( "krb_hostname" ) );
	unless ( $krb )
	{
		$repo->log( "Kerberos error: $@" );
		return undef;
	}
	unless( $krb->authenticate( $username, $password ) )
	{
		$repo->log( "$username authentication failed: " . $krb->errstr );
		return undef;
	}

	# connect to AD 
	use Net::LDAP;
	my $ldap = Net::LDAP->new ( $repo->config( "ldap_hostname" ) );
	unless( $ldap )
	{
		$repo->log( "LDAP error: $@" );
		return undef;
	}

	my $bind_dn = $repo->config( "ldap_bind_username" );
	my $bind_pword = $repo->config( "ldap_bind_password" );
	my $mesg = $ldap->bind( $bind_dn, password => $bind_pword );
	if( $mesg->code() )
	{
		$repo->log( "LDAP Bind error: " . $mesg->error );
		return undef;
	}

	# search for account
	my $cn = $repo->config( "ldap_login_cn" );
	my $filter = $repo->config( "ldap_login_filter" );
	$mesg = $ldap->search (
		base => $repo->config( "ldap_login_base" ),
		filter => "$cn=$username",
		attrs => $repo->config( "ldap_login_attrs" ),
		sizelimit => 1
	);
	if( $mesg->code() )
	{
		$repo->log( "LDAP search error: " . $mesg->error );
		return undef;
	}
	my $entry = $mesg->pop_entry;

	# create account if doesn't exist
	my $user = EPrints::DataObj::User::user_with_username( $repo, $username );
	unless( defined $user )
	{
		my $data = {
			username => $username,
			usertype => "user",
		};
		$user = EPrints::DataObj::User->create_from_data(
			$repo,
			$data,
			$repo->dataset( "user" ) );
	}
	return undef unless defined $user;

	# update account
	my $name = {};
	$name->{given} = $entry->get_value( "givenName" ) if defined $entry->get_value( "givenName" );
	$name->{family} = $entry->get_value( "sn" ) if defined $entry->get_value( "sn" );
	$user->set_value( "name", $name );
	$user->set_value( "email", $entry->get_value( "mail" ) );
	$user->set_value( "dept", $entry->get_value( "department" ) );
	$user->commit();

	$ldap->unbind;

	return $username;
}
