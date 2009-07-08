
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

my $tasks = Net::Google::Tasks->new(
	login => $login,
	password => $password
);

die "Couldn't connect." unless $tasks->connect;

print Dumper( $tasks->get_lists );
