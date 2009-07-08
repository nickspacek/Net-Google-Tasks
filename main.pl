
use strict;
use warnings;

use lib 'lib';

use Term::ReadKey;

use Net::Google::Tasks;

print 'Login: ';
my $login = ReadLine(0);
$login =~ s/\n//g;

print 'Password: ';
ReadMode('noecho');
my $password = ReadLine(0);
$password =~ s/\n//g;
ReadMode('restore');

print "\nLoading tasks...\n";

my $t = Net::Google::Tasks->new(
	login => $login,
	password => $password
);

die "Couldn't connect." unless $t->connect;

my $lists = $t->get_lists;
die 'No lists' unless scalar @{ $lists };

my $l = $lists->[0];
my $tasks = $t->get_tasks_for_list( $l );
die 'No tasks' unless scalar @{ $tasks };

print "Current name: " . $l->name;
print "New name: ";

my $new_name = ReadLine(0);
$new_name =~ s/\n//g;

$l->name( $new_name );

die "Couldn't update list." unless $t->update_list( $l );

