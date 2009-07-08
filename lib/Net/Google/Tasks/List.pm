package Net::Google::Tasks::List;

use Moose;

has 'name' => (
	is => 'rw',
	isa => 'Str',
	required => 1
);
has 'id' => (
	is => 'ro',
	isa => 'Str',
	required => 1
);

1;

