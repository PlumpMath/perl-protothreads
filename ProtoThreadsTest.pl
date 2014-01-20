# Perl Protothreads
# 
# a lightwight pseudo-threading framework for perl that is
# heavily inspired by Adam Dunkels protothreads for the c-language
# 
# LICENSE AND COPYRIGHT
#
# Copyright (C) 2014 ntruchsess (norbert.truchsess@t-online.de)
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either: the GNU General Public License as published
# by the Free Software Foundation; or the Artistic License.
#
# See http://dev.perl.org/licenses/ for more information.
#
#PT_THREAD(sub)
#Declare a protothread
#
#PT_INIT(thread)
#Initialize a thread
#
#PT_BEGIN(thread);
#Declare the start of a protothread inside the sub implementing the protothread.
#
#PT_WAIT_UNTIL(condition);
#Block and wait until condition is true.
#
#PT_WAIT_WHILE(condition);
#Block and wait while condition is true.
#
#PT_WAIT_THREAD(thread);
#Block and wait until another protothread completes.
#
#PT_SPAWN(thread);
#Spawn a child protothread and wait until it exits.
#
#PT_RESTART;
#Restart the protothread.
#
#PT_EXIT;
#Exit the protothread.
#
#PT_END;
#Declare the end of a protothread.
#
#PT_SCHEDULE(protothread);
#Schedule a protothread.
#
#PT_YIELD;
#Yield from the current protothread.
#
#PT_YIELD_UNTIL(condition);
#Yield from the current protothread until the condition is true.

use strict;
use warnings;
use ProtoThreads;

my $continue = time+3;

my $text = "test";
my $start = time;

my $child=PT_THREAD(sub {
  my $thread = shift;
  PT_BEGIN($thread);
  print time-$start." childthread of $text\n";
  PT_END;
});

sub thread(@) { 
  my ($thread,$mode) = @_;
  PT_BEGIN($thread);
  print time-$start." thread-$mode first\n";
  PT_YIELD;
  print time-$start." thread-$mode second\n";
  PT_YIELD_UNTIL(($continue - time)<0);
  print time-$start." thread-$mode third\n";
  if ($mode == 1) {
    PT_EXIT(1) if 1;
  };
  if ($mode == 2) {
    $text = "thread-2";
    PT_SPAWN($child);
  };
  if ($mode == 3) {
    $thread->{numruns} = 0 unless defined $thread->{numruns};
    $thread->{numruns}++;
    print time-$start." thread-$mode run: $thread->{numruns}\n";
    if ($thread->{numruns} < 3) {
      $continue = time+2;
      PT_RESTART;
    } 
  }
  print time-$start." thread-$mode forth\n";
  PT_END;
};

my $thread1 = PT_THREAD(\&thread);
my $thread2 = PT_THREAD(\&thread);
my $thread3 = PT_THREAD(\&thread);

my $running1 = 1;
my $running2 = 1;
my $running3 = 1;

do {
  $running1 = $thread1->PT_SCHEDULE(1) if $running1; 
  $running2 = $thread2->PT_SCHEDULE(2) if $running2; 
  $running3 = $thread3->PT_SCHEDULE(3) if $running3; 
} while ($running1 || $running2 || $running3);
if ($thread1->PT_RETVAL()) {print "exitval1: ".$thread1->PT_RETVAL()."\n";};
if ($thread2->PT_RETVAL()) {print "exitval2: ".$thread2->PT_RETVAL()."\n";};
if ($thread3->PT_RETVAL()) {print "exitval3: ".$thread3->PT_RETVAL()."\n";};
1;
