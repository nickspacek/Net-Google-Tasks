package Net::Google::Tasks::List;

=head1 NAME

Net::Google::Tasks::List - Contains List data.

=head1 DESCRIPTION

This class provides storage of list data.

=cut

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
has '_manager' => (
	is => 'ro',
	isa => 'Net::Google::Tasks',
	required => 1,
	weak_ref => 1
);

=head1 METHODS

=head2 tasks

Uses the manager reference to get a reference to the array of Task
objects for this list.

=cut

sub tasks {
	my ( $self ) = @_;
	
	return $self->_manager->get_tasks_for_list( $self );
}

=head1 AUTHOR

Nick Spacek, E<lt>nick.spacek@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Nick Spacek

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;

