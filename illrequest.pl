#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use lib "/var/www/cgi-bin/PDS";
use PDS;
use Data::Dumper;
use XML::Simple;

##--------CONFIGURE-----------------------------------------------------
# Relais code
my $libcode = '<YOUR RELAIS CODE>';

# Alma institute code
my $institutecode = '<YOUR ALMA INSTITUTE CODE>';

# Relais url
my $relais = '<YOUR RELAIS URL>';
## example format 
### Swinburne $relais = 'https://h7.relais-host.com/vswt/loginpRFT.jsp?';
### Swinburne $relais = 'https://h7.relais-host.com/vswt/loginp.jsp';
### Monash $relais = 'https://<YOUR RELAIS URL HERE>/user/login.html?group=patron';
##----------------------------------------------------------------------

my $q = new CGI;
my $pds_handle = $q->param('pds_handle');

unless ( $pds_handle )
{
## No handle, so we haven't logged in yet.
PDS->login;
}
my $pds = PDS->new( $pds_handle );
my $group = $pds->group;

if ( my $id = $pds->userid )
{
  if (my $institute = $pds->institute) {
    if ($institute eq $institutecode) {
	
	##Swinburne Alma Groups
	##03 Masters/Doctorate
	##11 Staff - Academic
	##12 Staff - Non-academic
	##13 Staff - Casual
	##34 Other (Full Staff Privileges)
	##81 Psuedo patron/Library use
	##82 Psuedo patrons - Holds

       ##if ($id) {
       my @almagroups = ("03","11","12","13","34","81","82");
       if (grep { $_ eq $group } @almagroups) {

	   ##NOTE: PI & RK are the identifiers in your Relais ILL
           print "Location: $relais&LS=$libcode&PI=$id&RK=$id\n\n";
	   #print "Content-type: text/html\n\n";
	   #print "Congratulations";
	   #print "<br />\n\nUser: $id ";
	   #print "<br />\n\nInstitute: $institute";
	   #print "<br />\n\n\Group: $group";
       }
       else
       {
       	   ##User not in allowed group
	   print "Content-type: text/html\n\n";
	   print "<html>";
	   print "<head>";
	   print "<title>Search - Error</title>";
	   print "</head>";
	   print "<body><center>";
	   print "<table height=150><tr><td><a href='https://www.swinburne.edu.au/library/search/'><img src='http://www.swinburne.edu.au/media/swinburneeduau/style-assets/images/logo-landscape.png'></a></td></tr></table>";
	   print "<table><tr><td align=center>";
           print "<h3>Sorry, you may be not eligible for inter-library loans. <br>";
           print "See <a href='http://www.swinburne.edu.au/library/about/borrow/other-libraries/inter-library-loans/'>Inter-library loans</a> for more information. <br></h3>";
           #print "Group  = $group <br>";
           #print "Institute  = $institute <br>";
	   print "</td></tr></table>";
	   print "</center></body>";
	   print "</html>";
       }
    }
    else{
	   ##Institute incorrect
	   print "Content-type: text/html\n\n";
           print "<html>";
           print "<head>";
           print "<title>Search - Error</title>";
           print "</head>";
           print "<body><center>";
           print "<table height=150><tr><td><a href='https://www.swinburne.edu.au/library/search/'><img src='http://www.swinburne.edu.au/media/swinburneeduau/style-assets/images/logo-landscape.png'></a></td></tr></table>";
           print "<table><tr><td align=center>";
           print "<h3>Sorry, you may not be eligible for inter-library loans. <br>";
           print "See <a href='http://www.swinburne.edu.au/library/about/borrow/other-libraries/inter-library-loans/'>Inter-library loans</a> for more information. <br></h3>";
           print "</td></tr></table>";
           print "</center></body>";
           print "</html>";

    }
  }
  else{
           ##print "Institute is blank ";
           print "Content-type: text/html\n\n";
           print "<html>";
           print "<head>";
           print "<title>Search - Error</title>";
           print "</head>";
           print "<body><center>";
           print "<table height=150><tr><td><a href='https://www.swinburne.edu.au/library/search/'><img src='http://www.swinburne.edu.au/media/swinburneeduau/style-assets/images/logo-landscape.png'></a></td></tr></table>";
           print "<table><tr><td align=center>";
           print "<h3>Sorry, you may not be eligible for inter-library loans. <br>";
           print "See <a href='http://www.swinburne.edu.au/library/about/borrow/other-libraries/inter-library-loans/'>Inter-library loans</a> for more information. <br></h3>";
           print "</td></tr></table>";
           print "</center></body>";
           print "</html>";

  }
}
else
{
## fail disgracefully
print "Content-type: text/plain\n\n";
print "Error: ", $pds->error;
}
