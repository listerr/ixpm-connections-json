package IXPTools::QueryHelper;
use 5.010;
use Carp;
use Exporter;
use strict;
use POSIX qw(strftime);
use DBI; # !! DEPENDS: libdbi-perl

use vars qw(@ISA @EXPORT_OK @EXPORT %EXPORT_TAGS $VERSION $AUTOLOAD );

@ISA = ("Exporter");
@EXPORT    = qw(BuildWhereField GetTableColumnInfo);
@EXPORT_OK = qw(BuildWhereField GetTableColumnInfo);

# %EXPORT_TAGS = (Builder => [qw(BuildWhereField GetTableColumnInfo)],
#                 all => \@EXPORT_OK);

our $dbh_db;

sub DBConnect {

  my %opts = @_;

  my $server    = $opts{server};
  my $user      = $opts{user};
  my $pass      = $opts{pass};
  my $database  = $opts{database};

  my $mysql_data_source = "dbi:mysql:$database:$server";

    $dbh_db = DBI->connect_cached($mysql_data_source, $user, $pass, {
             RaiseError       => 1,
             PrintError       => 1,
             AutoCommit       => 1,
             }) or confess "Can't connect to mysql db $database / $server : $DBI::errstr";

}


sub BuildWhereField {

    # Returns part of a MySQL query.
    #
    # field => 'switch'
    # values => 'switch1,switch2'
    # 
    # returns the part to add to the query:
    # AND ( switch = ? OR switch = ? )
    #
    # or with placeholder => 'value':
    # AND ( switch = "inx-sr1" OR switch = "hex-qr1" )
    #
    # not => '1' will invert the logic:
    # AND (switch IS NULL OR NOT ( switch = "?" OR switch = "hex-qr1" ) )
    #
    my $args = shift;
    return 0 unless ($args);

    my $field             = $args->{field} || confess("no field");
    my $values            = $args->{values} || confess("no values");
    my $oper              = $args->{oper} || 'OR';
    my $function          = $args->{function};  # allow a function e.g find_in_set();
    my $not               = $args->{not};
    my $comp              = $args->{comp};
    $comp = '=' unless ($comp =~ /^(like|like_starts)$/i);
    $comp = lc($comp);

    # Assume safe query and want to use only placeholders in the query.
    # Set to 'value' to use the value if there's no possibility of SQL injections in the value.
    my $placeholder       = $args->{placeholder} || '?';
    $placeholder = '?' unless ($placeholder eq 'value');
    
    my $query;
    my $prepend = "\nAND";
    my $brackets;

    my $count = () = $values =~ /,/g;
    if ($count > 0) { $brackets = 1 };

        foreach my $v (split(/,/,$values)) {
          my $value_placeholder = $placeholder;
          if ($placeholder eq 'value') {  $value_placeholder = $v };

          if ($comp eq '=') {
           if (($function) && ($placeholder eq '?'))      { $query .= "$function($value_placeholder, $field)"; }
           if (($function) && ($placeholder eq 'value'))  { $query .= "$function(\'$value_placeholder\', $field)"; }

           if ((!$function) && ($placeholder eq '?'))     { $query .= "$field = $value_placeholder"; }
           if ((!$function) && ($placeholder eq 'value')) { $query .= "$field = \"$value_placeholder\""; }
          }
          
          if ($comp eq 'like') {
           if (($function eq 'find_in_set') && ($placeholder eq '?'))      { $query .= '( ' . $field  . ' LIKE ? OR '. $field . ' LIKE ? )' ; };
           if (($function eq 'find_in_set') && ($placeholder eq 'value'))  { $query .= $field . ' LIKE \'%\'' . $value_placeholder . '%\' OR '. $field . ' LIKE \'%,%' . $value_placeholder . '%\'' }

           if ((!$function) && ($placeholder eq '?'))     { $query .= $field . ' LIKE ?'; }
           if ((!$function) && ($placeholder eq 'value')) { $query .= $field . ' LIKE ' . $value_placeholder }
          }


          if ($count > 0) { $query .= ' ' . $oper . ' ' };
          $count--;
        }

    if ($brackets) { $query = '( ' . $query . ' )'};

    if ($not) { $prepend .= " ($field IS NULL OR NOT"};

    $query = ' ' . $prepend . ' ' . $query;

    if ($not) { $query = $query . ' )'};

    return ("$query");

}


sub GetTableColumnInfo {

 # Get info about columns in a table, (field names, type, other properties)

  my %opts = @_;
  my $table     = $opts{table} || confess("no table");

  DBConnect(%opts);

  my $array_from = $opts{array_from} || undef;
  
  my (@column_names);
  my %column;

  my $sth_column_info = $dbh_db->column_info( undef, undef, $table, undef );
  my $col_info = $sth_column_info->{NAME};

  my %row; 
  $sth_column_info->bind_columns(\@row{@$col_info});

   while ($sth_column_info->fetch) {
    push @column_names, $row{COLUMN_NAME};

    unless ($array_from) {
      my $cn =  $row{COLUMN_NAME};
        foreach my $k (@$col_info) { 
          next unless $row{$k};
          $column{$cn}{$k}=$row{$k};
       }
      }
    
   }

   if ($array_from) { 
     return (@column_names);
   } else {
     return %column;
   }

}


1;

