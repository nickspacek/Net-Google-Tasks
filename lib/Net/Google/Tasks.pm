package Net::Google::Tasks;

=head1 NAME

Net::Google::Tasks - Provides a basic API for Google Tasks.

=head1 SYNOPSIS

	use Net::Google::Tasks;
  
	my $t = Net::Google::Tasks->new( 
		login => 'your.login@gmail.com',
		password => 'password'
	);
	
	$t->connect; # must be connected to call any method
	my $lists = $t->get_lists;
	my $tasks = $t->get_tasks_for_list( $lists->[0] );

=head1 DESCRIPTION

This module interacts with Google Tasks, allowing you to retrieve
your tasks, update them, etc.

=cut

our $VERSION = '0.01';

use Moose;
use Net::Google::Tasks::Task;
use Net::Google::Tasks::Fetcher;
use Net::Google::Tasks::List;

has 'login' => (
	is => 'rw',
	isa => 'Str',
	required => 1
);
has 'password' => (
	is => 'rw',
	isa => 'Str',
	required => 1
);
has 'address' => (
	is => 'rw',
	isa => 'Str',
	required => 1,
	default => 'http://mail.google.com/tasks/ig'
);
has '_fetcher' => (
	is => 'rw',
	isa => 'Net::Google::Tasks::Fetcher',
	required => 1,
	lazy => 1,
	builder => '_build_fetcher',
	handles => {
		connected => 'connected',
		connect => 'connect'
	}
);

=head1 METHODS

=head2 get_lists

Retrieves a reference to an array of List objects.

=cut

sub get_lists {
	my $self = shift;

	die 'Not connected.' unless $self->connected;
	
	my $fetcher = $self->_fetcher;
	my $arr = $fetcher->request_lists;

	my @lists = map { $self->_build_list( $_ ) } @{ $arr };
	return \@lists;
}

=head2 get_tasks_for_list( $list_obj )

Retrieves a reference to an array of Task objects for the given list.

=cut

sub get_tasks_for_list {
	my ( $self, $list ) = @_;
	
	die 'No list specified.' unless $list;
	die 'Not connected.' unless $self->connected;
	
	my $fetcher = $self->_fetcher;
	my $res = $fetcher->request_tasks_for_list( $list->id );
	
	my @tasks = map { $self->_build_task( $_ ) } @{ $res };
	return \@tasks;
}

=head2 update_list( $list_obj )

Saves any changes to an existing list (currently only saves the name).

=cut

sub update_list {
	my ( $self, $list ) = @_;
	
	die 'No list specified.' unless $list;
	die 'Not connected.' unless $self->connected;
	
	my $fetcher = $self->_fetcher;
	my $res = $fetcher->request_update_list( $list );
	
	return $res ? 1 : 0;
}

sub _build_fetcher {
	my $self = shift;
	
	return Net::Google::Tasks::Fetcher->new(
		login => $self->login,
		password => $self->password,
		address => $self->address
	);
}

sub _build_list {
	my ( $self, $hash ) = @_;
	
	return Net::Google::Tasks::List->new(
		id => $hash->{ id },
		name => $hash->{ name },
		_manager => $self
	);
}

sub _build_task {
	my ( $self, $hash ) = @_;
	
	return Net::Google::Tasks::Task->new(
		id => $hash->{ id },
		name => $hash->{ name },
#		creation_date => $hash->{ creation_date },
		completed => _is_true( $hash->{ completed } ),
#		completed_date => $hash->{ completed_date },
		list_id => $hash->{ list_id },
		deleted => _is_true( $hash->{ deleted } ),
		_manager => $self
	);
}

sub _is_true {
	return shift == JSON::XS::true ? 1 : 0;
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

