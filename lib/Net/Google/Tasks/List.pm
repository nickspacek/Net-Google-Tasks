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

=head1 AUTHOR

Nick Spacek, E<lt>nick.spacek@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Nick Spacek

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;

