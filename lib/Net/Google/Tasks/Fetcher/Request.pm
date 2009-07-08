package Net::Google::Tasks::Fetcher::Request;

=head1 NAME

Net::Google::Tasks::Fetcher::Request - Logic to create specific requests.

=head1 DESCRIPTION

This module deals with creating the correct requests for supported
operations.

=cut

use strict;
use warnings;

use HTTP::Request::Common;

sub request_tasks_for_list {
	shift;
	my ( $fetcher, $id ) = @_;
	
	my $request_id = $fetcher->_request_count;
	my $v = $fetcher->js_version;
	
	return _base_request( $fetcher, [
		r => "{'action_list':[{'action_type':'get_all','action_id':'$request_id','list_id':'$id','get_deleted':false}],'client_version':$v}"
	]);
}

sub request_update_list {
	shift;
	my ( $fetcher, $id, $name ) = @_;
	
	my $request_id = $fetcher->_request_count;
	my $v = $fetcher->js_version;
	
	return _base_request( $fetcher, [
		r => "{'action_list':[{'action_type':'update','action_id':'$request_id','id':'$id','entity_delta':{'name':'$name','entity_type':'GROUP'}}],'client_version':$v}"
	]);
}

sub _base_request {
	my ( $fetcher, $params ) = @_;
	
	my ( $base, $ajax ) = (
		$fetcher->addresses->{ base },
		$fetcher->addresses->{ ajax }
	);
	
	return POST $ajax,
		Referrer => $base,
		AT => 1,
		Content => $params;
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

