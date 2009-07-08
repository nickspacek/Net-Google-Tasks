package Net::Google::Tasks::Fetcher;

use Moose;

use LWP;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTML::Form;
use HTML::Parser;
use JSON;
use URI::Escape;
use Data::Dumper;

use Net::Google::Tasks::Task;

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

sub request_lists {
	my ( $self ) = @_;
	# TODO: Have some POST request logic
	return $self->_initial_json->{ t }->{ lists };
}

sub request_tasks_for_list {
	my ( $self, $list_id ) = @_;
	
	my $ua = $self->_ua;
	my $v = $self->js_version;
	my $id = $self->_request_count;
	
	my $res = $ua->request(
		POST $self->addresses->{ ajax },
		Referer => $self->addresses->{ base },
		AT => 1,
		Content => [
			r => "{'action_list':[{'action_type':'get_all','action_id':'$id','list_id':'$list_id','get_deleted':false}],'client_version':$v}"
		]
	);

	$self->_request_count( $id + 1 ); # TODO: Should we set regardless of error?
	
	die 'Bad response: ' . $res->code if $res->is_error;

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

1;

