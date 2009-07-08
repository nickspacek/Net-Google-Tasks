package Net::Google::Tasks::Fetcher;

=head1 NAME

Net::Google::Tasks::Fetcher - Manages a connection to Google Tasks.

=head1 DESCRIPTION

This module handles the interaction with Google Tasks, using HTTP::Requests
and parsing HTTP::Responses for JSON information.

=cut

use Moose;

use LWP;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTML::Form;
use HTML::Parser;
use JSON;
use URI::Escape;
use Data::Dumper;

use Net::Google::Tasks::Fetcher::Request;

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
has 'addresses' => (
	is => 'rw',
	isa => 'HashRef',
	default => sub {{
		base => 'http://mail.google.com/tasks/ig',
		ajax => 'http://mail.google.com/tasks/r/ig'
	}} # TODO: Defaults
);
has 'js_version' => (
	is => 'rw',
	isa => 'Str',
);
has 'connected' => (
	is => 'rw',
	isa => 'Bool'
);
has '_request_count' => (
	is => 'rw',
	isa => 'Int',
	required => 1,
	default => 0
);
has '_initial_json' => (
	is => 'rw',
	isa => 'HashRef',
	predicate => 'has_initial_json'
);
has '_ua' => (
	is => 'rw',
	isa => 'LWP::UserAgent',
	required => 1,
	builder => '_build_useragent'
);

=head1 METHODS

=head2 connect

Perform the initial connect:

=over
=item GET the base page (usually http://mail.google.com/tasks/ig)
=item Process the login form here.
=item Handles the redirects.
=item Parse the final page and the JSON.
=back

=cut

sub connect {
	my ( $self ) = @_;
	
	return 1 if $self->connected;
	
	my $ua = $self->_ua;

	my $req = HTTP::Request->new(GET => $self->addresses->{ base });
	my $res = $ua->request($req);

	my @forms = HTML::Form->parse( $res );
	my $form = $forms[0];

	$form->value('Email', $self->login);
	$form->value('Passwd', $self->password);

	my $freq = $form->click;
	my $fres = $ua->request($freq);
	
	# parse with HTML::Parser to go to the META refresh
	our $redirect;
	my $parser = HTML::Parser->new( api_version => 3,
		start_h => [ \&get_meta, "tagname, attr" ]
	);

	$parser->parse( $fres->content );

	die "Couldn't get redirect." unless $redirect;

	$req = HTTP::Request->new( GET => $redirect );
	$res = $ua->request( $req );

	die "Couldn't load tasks page." unless $res;
	die "Page content fishy." unless $res->content =~ /\{_setup\((.*)\)\}/;
	
	my $json_hash = decode_json( $1 );

	$self->js_version( $json_hash->{ v } );
	$self->_initial_json( $json_hash );
	
	$self->connected( 1 );
	
	return 1;

	sub get_meta {
		my ( $tagname, $attr ) = @_;
		return unless $tagname =~ /meta/i;

		if( $attr->{ content } =~ /url='(.*)'/ ) {
			$redirect = uri_unescape $1;
		}
	}
}

=head2 request_lists

(Should) perform a request to retrieve the lists (currently uses the lists
from the initial page, which means it never gets updated).

Returns a reference to an array straight from the decoded JSON.

=cut

sub request_lists {
	my ( $self ) = @_;
	# TODO: Have some POST request logic
	return $self->_initial_json->{ t }->{ lists };
}

=head2 request_update_list( $list_obj )

Perform a request to update the list, given a List object.

(Originally I intended the Fetcher to be apart from the List and Task
objects and only deal with the JSON. Not sure what to do.)

=cut

sub request_update_list {
	my ( $self, $list ) = @_;
	
	my $res = $self->_make_request(
		Net::Google::Tasks::Fetcher::Request->request_update_list(
			$self, $list->id, $list->name
		)
	);
	
	die 'Bad response: ' . $res->code if $res->is_error;

	return 1;
}

=head2 request_tasks_for_list

Perform a request to retrieve the tasks for a list, given the list ID.

Returns a reference to an array straight from the decoded JSON.

=cut

sub request_tasks_for_list {
	my ( $self, $list_id ) = @_;
	
	my $res = $self->_make_request(
		Net::Google::Tasks::Fetcher::Request->request_tasks_for_list(
			$self, $list_id
		)
	);

	my $hash = decode_json( $res->content );
	return $hash->{ tasks };
}

sub _build_useragent {
	my $self = shift;
	
	my $ua = LWP::UserAgent->new;
	$ua->agent('Net::Google::Tasks::Fetcher/0.1');
	push @{ $ua->requests_redirectable }, 'POST';
	$ua->cookie_jar({ file => "$ENV{HOME}/.cookies.txt" });
	
	return $ua;
}

sub _make_request {
	my ( $self, $req ) = @_;
	
	my $res = $self->_ua->request( $req );
	
	$self->_request_count( $self->_request_count + 1 ); # TODO: Should we set regardless of error?-
	
	die 'Bad response: ' . $res->code if $res->is_error;
	
	return $res;
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

