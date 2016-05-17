# Relais-PDS-login
Allows Relais to use ExLibris PDS (Primo login system) to authenticate users and use ExLibris Alma to manage user/group authorisation.

* This assumes NCIP has been setup between Relais and ExLibris Alma
* That you have access to the Alma API - you need to setup an API key with access to production user details - read-only

This is a fork of the great work done by [Steve Thomas](https://github.com/spotrick) of [The University of Adelaide Library](http://www.adelaide.edu.au/library/) and Rachell Anne Orodio-Williams of [Monash University Library](http://www.monash.edu/library) for use at [Swinburne University Library](https://www.swinburne.edu.au/library)

* https://github.com/spotrick/Relais-via-PDS
* https://github.com/spotrick/PDS.pm

# Changes from Steve's code

* Uses `curl` instead of `LWP::Simple get()`
  * Our server couldnt use `get()` for whatever reason so swapped it out for `curl`
* Uses the Alma API to get user groups details
  * Our PDS didn't provide user groups information, instead of reconfiguring PDS, the Alma API was used

# Setup

Copy the fiels `PDS.pm` and `illrequest.pl` onto a webserver that can run perl scripts.

## illrequest.pl

Edit the file `illrequest.pl` and adjust the following settings

`use lib "/var/www/cgi-bin/PDS";`

Set this as the directory on the server where you will put these 2 perl files

Update `$libcode` with your Relais code
```
# Relais code
my $libcode = '<YOUR RELAIS CODE>';
```

Update `$institutecode` with your Alma institute code 
```
# Alma institute code
my $institutecode = '<YOUR ALMA INSTITUTE CODE>';
```

Update `$relais` with your Relais patron login url
```
# Relais url
my $relais = '<YOUR RELAIS URL>';
## example format 
### Swinburne $relais = 'https://h7.relais-host.com/<YOUR RELAIS CODE>/loginpRFT.jsp?';
### Swinburne $relais = 'https://h7.relais-host.com/<YOUR RELAIS CODE>/loginp.jsp';
### Monash $relais = 'https://<YOUR RELAIS URL HERE>/user/login.html?group=patron';
```

Update `@almagroups` with the code numbers for the user groups that are allowed to palce inter-library loan requests in Relais 
```
## List which Alma user groups are allowed to borrow via ILL/Relais		
my @almagroups = ("03","11","12","13","34","81","82");
```

## PDS.pm

Update the 3 configurations in `PDS.pm` with your PDS url, Alma API key and Primo institute code
```
##--------CONFIGURE-----------------------------------------------------
my $pds_url = "<YOUR PDS URL>";
my $alma_api_key = "<YOUR ALMA API KEY>";
my $institute = "<YOUR PRIMO INSTITUTE>";
##----------------------------------------------------------------------
```

# Alma API key

To access the users group details from ExLibris Alma and Alma API key is required.  
An API key can be created in the ExLibris Developers Network, refer below links, please make sure that the key is for your production server and is read-only

ExLibris Alma API - getting started documentation

* https://developers.exlibrisgroup.com/alma/apis

User API details

* https://developers.exlibrisgroup.com/alma/apis/users/GET/gwPcGly021r0XQMGAttqcPPFoLNxBoEZSZhrICr+9So=/0aa8d36f-53d6-48ff-8996-485b90b103e4
