package Net::Google::Tasks::Fetcher::Request;

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


1;

