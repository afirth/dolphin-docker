#!/usr/bin/perl
use strict; use warnings;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;

use IPC::ConcurrencyLimit;
use File::Path qw(make_path);

my %args = (
	'concurrent' => 10,
	'lockpath'   => '/tmp/locks',
	'sleep'      => 1,
	'verbose'    => 0,
);

getoptions();
main();

sub main {
  make_path( $args{lockpath} );
	my $cmd = $args{command};

	my $limit = IPC::ConcurrencyLimit->new(
		type      => 'Flock', # that's also the default
		max_procs => $args{concurrent},
		path      => $args{lockpath}, # an option to the locking strategy
	);
	
	# NOTE: when $limit goes out of scope, the lock is released
	do {
		my $id = $limit->get_lock();
		if ( $id ) {
			# Got one of the worker locks (ie. number $id)
			warn "PID $PID executing command: $cmd\n" if $args{verbose};
			system($cmd) or {
				$limit->release_lock();
				die "COMMAND: $cmd\n Returned failure: $?\n"
			}
		}
		else {
			warn "PID $PID got none of the worker locks. Sleeping." if $args{verbose};
			sleep($args{sleep});
		}
	# lock released with $limit going out of scope here
	} until ( $id );
}

sub getoptions {
	GetOptions(\%args,
		'command=s'
		'concurrent:i',
		'lockpath:s',
		'sleep:i',
		'verbose'
	) or pod2usage(1);
	pod2usage(1) unless @ARGV;
}

=head1 NAME

runparallel 

=head1 DESCRIPTION

Runs command in parallel with other commands, up to n concurrently. Sleeps until a slot is available.

=head1 SYNOPSIS

runparallel.pl --command='echo foo bar'

runparallel.pl [--sleep=1] [--verbose] [--lockpath=/tmp/locks] [--concurrent=10] <--command=COMMAND>

--command	command to execute
--concurrent	maximum procs to run. Default 10. Multiple scripts using different MAX_PROCS on the same lock dir is NOT supported.
--lockpath	where to create the lock file. Default /tmp/locks 
--sleep	seconds to sleep before trying to obtain a lock again. Default 1
--verbose	print basic status messages to STDERR. Default False

Use the IPC::ConcurrencyLimit module to run at most --concurrent worker processes. Executes arguments as a call to system().

The STDOUT and STDERR of COMMAND is discarded

=head1 AUTHOR

Alastair Firth github:@afirth

=cut
