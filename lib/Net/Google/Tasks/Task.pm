package Net::Google::Tasks::Task;

=head1 NAME

Net::Google::Tasks::Task - Contains Task data.

=head1 DESCRIPTION

This class provides storage of task data.

=cut

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

=head1 AUTHOR

Nick Spacek, E<lt>nick.spacek@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Nick Spacek

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;

