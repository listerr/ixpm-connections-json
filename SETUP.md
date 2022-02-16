# Brief Setup Guide


## Install Debian/Ubunu install packages:

```
apt-get install libcgi-pm-perl libwww-perl libjson-xs-perl libjson-perl libdbi-perl libdbd-mysql-perl
```
      
 * Optional: 

```
 apt-get install jq
```

## Web server config

- Example in [nginx/site_conf_example]

## Put the script and lib/IXPTools in some location e.g. /usr/local/lib..

## Edit script

* Update at least the following:

```
my $MYSQL_DATABASE           = 'ixpmanager';
my $MYSQL_SERVER             = '127.0.0.1';
my $MYSQL_USER               = 'your_db_user';
my $MYSQL_PASS               = 'your_db_pass';
```

- Your peering VLAN (actual VLAN tag, not id):

my %defs = ('vlan' =>  {
                      'name' => 'vlan_list',
                      'default' => '4',
                      'function' => 'find_in_set',
                       },
                       
## Set up MySQL View

- Run the file [view_local_connections.sql] to create the view in ixpmanager database
- Grant read only permissions etc as needed to the user, e.g:

```
GRANT SELECT on ixpmanager.view_local_connections TO 'my_user'@'192.168.1.10';
GRANT SELECT on ixpmanager.view_local_connections TO 'my_user'@'yourhost.example.com';
```
