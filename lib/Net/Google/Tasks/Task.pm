package Net::Google::Tasks::Task;

use Moose;

has 'id' => (
	is => 'ro',
	isa => 'Str',
	required => 1
);
has 'name' => (
	is => 'rw',
	isa => 'Str',
	required => 1,
);
has 'completed' => (
	is => 'rw',
	isa => 'Bool',
	required => 1,
	default => 0
);
has 'completed_date' => (
	is => 'rw',
	isa => 'Date',
	#coerce
);
has 'creation_date' => (
	is => 'ro',
	isa => 'Date',
	#coerce
);
has 'list_id' => (
	is => 'ro',
	isa => 'ArrayRef', # of Str
	required => 1
);
has '_archived' => (
	is => 'ro',
	isa => 'Bool',
	required => 1,
	default => 0
);
has '_deleted' => (
	is => 'ro',
	isa => 'Bool',
	required => 1,
	default => 0
);

=pod
"creation_date": "",
            "id": "01723986328272461292:0:1",
            "archived": false,
            "name": "gran torino",
            "list_id": ["01723986328272461292:0:0"],
            "deleted": false,
            "completed": false
=cut

1;

