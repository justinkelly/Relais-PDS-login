=head1 NAME
PDS.pm
=head1 SYNOPSIS
    use PDS;
    PDS->login unless $pds_handle;
    my $pds = PDS->new( $pds_handle );
    my $error = PDS->error;
    if ( $error ) {
	print $error;
    } else {
	my $id = $pds->userid;
	my $group = $pds->group;
    }
=head1 DESCRIPTION
Allows scripts to use Ex Libris Patron Directory Service (PDS) to manage user logins.
Scripts can be run after login by adding the script URL as a parameter on the
PDS login link, e.g. from the URL:

    https://our.hosted.exlibrisgroup.com/pds
    ?func=load-login&institute=61ADELAIDEU&calling_system=primo&lang=eng
    &url=https://library.adelaide.edu.au/cgi/ourscript

Alternatively the script can force a login with PDS->login, which will return to the calling script.
Username is obtained by calling PDS back with the bor-info function, which should
return an XML data structure like so:

    <bor>
	<bor_id>
	    <id>1234567</id>
	    <handle>6820141643591607825054665244825</handle>
	    <institute>61ADELAIDE_INST</institute>
	</bor_id>
	<bor-info>
	    <id>1234567</id>
	    <id>Stephen</id>
	    <institute>61ADELAIDE_INST</institute>
	    <name>Stephen</name>
	    <group>STAFF</group>
	    <email_address>stephen.thomas@adelaide.edu.au</email_address>
	</bor-info>
    </bor>

=cut

package PDS;
use warnings;

use LWP::Simple;
use URI::Escape;
use XML::Simple;
use Data::Dumper;
$XML::Simple::PREFERRED_PARSER = 'XML::Parser';


##--------CONFIGURE-----------------------------------------------------
my $pds_url = "<YOUR PDS URL>";
my $alma_api_key = "<YOUR ALMA API KEY>";
my $alma_url = "https://api-na.hosted.exlibrisgroup.com/almaws/v1/users/"; 
my $alma_url_params = "?user_id_type=all_unique&view=full&expand=none&apikey=";
my $institute = "<YOUR PRIMO INSTITUTE>";
##----------------------------------------------------------------------

my $errstr = '';

=head1 METHODS

=head2 PDS->new( $pds_handle );

Retrieves the details of the logged in user from PDS.

If the script is called on return from PDS, there will be a handle,
otherwise we can redirect to PDS to get one.

=cut

sub new {
	my $class = shift;
	my $pds_handle = shift;
	my $pds = {};

	unless ( $pds_handle )
	{
		## No handle, so we haven't logged in yet.
		## Redirect to the login page 
		PDS->login;
	}

	## OK, we have already been authenticated 
	## Get the user details. Specifically, the user id
	my $dumper_url = "$pds_url?func=bor-info&pds_handle=$pds_handle&institute=$institute" ;
	my $result = `curl '$dumper_url'`;
	
	my $xml = XML::Simple->new;
	my $pds_xml = $xml->XMLin($result);
	#print "<br />\nXML dump: \n<br /><br />";
	#print Dumper($pds_xml);

	if ( $result =~ /<bor>/ && $pds_xml->{bor_id}->{id} ne "")
	{
		my $alma_url_full = $alma_url . $pds_xml->{bor_id}->{id} . $alma_url_params . $alma_api_key ;

		#print "<br /><br />\nALMA url: \n<br /><br />";
		#print Dumper($alma_url_full);

		## get alma data
		my $alma_data = `curl '$alma_url_full'`;
		my $alma_data_xml = XML::Simple->new;
		my $alma_xml = $alma_data_xml->XMLin($alma_data);

		%user_data = (
			"userid", $pds_xml->{'bor_id'}->{id} ,
			"username", $pds_xml->{'bor-info'}->{name} ,
			"userinstitute", $pds_xml->{'bor_id'}->{institute} ,
			"usergroup", $alma_xml->{user_group}->{content} 
		);

		#print "<br />\nALMA dump: \r\n\r\n<br /><br />";
		#print Dumper($alma_xml);

		#print "<br /><br />\nUSER dump: \r\n\r\n<br /><br />";
		#print Dumper(%user_data);

	}
	else
	{
		$errstr = "Failed to get user details: $result";
	}

	bless $pds, $class;
	return $pds;
}

###Redirect to PDS login form, returning to our calling script and preserving query parameters.

sub login {
	my $class = shift;
	print "Location: ", $pds_url,
	    "?func=load-login&institute=".$institute."&calling_system=primo&lang=eng&url=",
	    uri_escape("https://$ENV{'SERVER_NAME'}$ENV{'SCRIPT_NAME'}?$ENV{'QUERY_STRING'}"),
	    "\n\n";
	exit;
}

###Return any error as a string. Returns the empty string if no errors.

sub error {
	my $pds = shift;
	return $errstr;
}

###Return the id of the logged-in user.

sub userid {
	return $user_data{"userid"};
}

###Returns the group of the logged-in user.
### NOTE: Make sure that the XML tags match the parameters being read. Ex. 'bor-info' vs bor_info cause a problem


sub group {
	return $user_data{"usergroup"};
}

sub institute {
	return $user_data{"userinstitute"};
}

1;

__END__

=head1 AUTHOR
Steve Thomas <stephen.thomas@adelaide.edu.au>
This is version 2014.08.19
=cut


