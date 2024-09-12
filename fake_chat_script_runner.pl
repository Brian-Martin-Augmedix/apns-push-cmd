#!/usr/bin/perl

use strict;
use IO::Handle;

my $apns_auth_key = shift || usage();
my $apns_key_id = shift || usage();
my $team_id = shift || usage();
my $bundle_id = shift || usage();
my $apns_token = shift || usage();
my $script_filename = shift || usage();

$| = 0;

open my $script, $script_filename or die "can't open script filename $script_filename: $!\n";
open my $fake_server, "| perl fake_chat_server.pl $apns_auth_key $apns_key_id $team_id $bundle_id $apns_token"
  or die "can't run fake chat server: $!\n";

$fake_server->autoflush;

#foreach (split(/\n/, $script)) {
while(<$script>) {
  next if(/^#/);
  chomp;
  print("command: $_\n");
  if(/^s (.*)$/) {
    sleep($1);
  } else {
    print $fake_server "$_\n";
  }
}

sub usage {
  die "usage: $0 bundle_id apns_auth_key apns_key_id team_id apns_token script.txt\n";
}

close $fake_server;
close $script;
