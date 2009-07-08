use 5.010000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Net::Google::Tasks',
    VERSION_FROM      => 'lib/Net/Google/Tasks.pm', # finds $VERSION
    PREREQ_PM         => {
        Moose => 0,
        LWP => 0,
        LWP::UserAgent => 0,
        HTTP::Request::Common => 0,
        HTML::Form => 0,
        HTML::Parser => 0,
        JSON => 0,
        URI::Escape => 0,
        Data::Dumper => 0
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Net/Google/Tasks.pm', # retrieve abstract from module
       AUTHOR         => 'Nick Spacek <nick.spacek@gmail.com>') : ()),
);
