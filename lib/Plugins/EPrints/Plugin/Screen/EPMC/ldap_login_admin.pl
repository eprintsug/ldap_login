package EPrints::Plugin::Screen::EPMC::ldap_login_admin;

use EPrints::Plugin::Screen::EPMC;

@ISA = ( 'EPrints::Plugin::Screen::EPMC' );

use strict;

sub new
{
      my( $class, %params ) = @_;

      my $self = $class->SUPER::new( %params );

      $self->{actions} = [qw( enable disable configure )];
      $self->{disable} = 0; # always enabled, even in lib/plugins

      $self->{package_name} = "LDAP Login";

      return $self;
}

sub action_enable
{
	my( $self, $skip_reload ) = @_;

     	$self->SUPER::action_enable( $skip_reload );
 
	$self->reload_config if !$skip_reload;
}

sub action_disable
{
	my( $self, $skip_reload ) = @_;

      	$self->SUPER::action_disable( $skip_reload );

	my $repo = $self->{repository};
}

sub render_messages
{
	my( $self ) = @_;

	my $repo = $self->{repository};

	my $epm = $self->{processor}->{dataobj};

	my $xml = $repo->xml;

	my $frag = $xml->create_document_fragment;

	return $frag if (!$epm->is_enabled());

		#TODO
	if( $conf_ok ) {
            $frag->appendChild( $repo->render_message( 'message', $self->html_phrase( 'ready' ) ) );
	}	
	return $frag;
}

sub allow_configure { shift->can_be_viewed( @_ ) }

sub action_configure
{
	my( $self ) = @_;

	my $epm = $self->{processor}->{dataobj};
	my $epmid = $epm->id;

	foreach my $file ($epm->installed_files)
	{
		my $filename = $file->value( "filename" );
		next if $filename !~ m#^epm/$epmid/cfg/cfg\.d/(.*)#;
		my $url = $self->{repository}->current_url( host => 1 );
		$url->query_form(
			screen => "Admin::Config::View::Perl",
			configfile => "cfg.d/ldap_login.pl",
		);
		$self->{repository}->redirect( $url );
		exit( 0 );
	}

	$self->{processor}->{screenid} = "Admin::EPM";

	$self->{processor}->add_message( "error", $self->html_phrase( "missing" ) );
}



1;
