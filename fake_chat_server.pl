#!/usr/bin/perl

# This script expects to be run inside this apns-push-cmd git repo:
#
# git clone https://github.com/petarov/apns-push-cmd.git
#
# Before you can run this, make sure you have 'go' instealled:
#
# export HOMEBREW_TEMP="/some_path_that_you_have_access_to"
# brew install go
#
# run it like this:
#
# perl fake_chat_server.pl AuthKey_7P5G34J26H.p8 7P5G34J26H FZXCUUS8M8 com.augmedix.Lynx.staging 733c35cbe45a6de83a17ca61b8aad8938e8e15b454fc125216e33d0e4e67a6c3
#
# The last two args are the bundle id you're running with, and your APNS token.
# The apns token is specific to the device you're running on.
# To get it, search for 'apns token' in the device longs.
#
# After successfully running this fake chat server, interact with it by typing one of the commands it supports.
#

use strict;

my $apns_auth_key = shift || usage();
my $apns_key_id = shift || usage();
my $team_id = shift || usage();
my $bundle_id = shift || usage();
my $apns_token = shift || usage();

my $info_string = <<'END';
USAGE:
 - m message text
   send a message with the given text
 - t 1
   send a message saying the MDS is typing
 - t 0
   send a message saying the MDS is not typing
 - o 1
   send a message saying the MDS is online
 - o 0
   send a message saying the MDS is not online
 - q
   quit
END

print $info_string;

while (<>) {
  chomp;
  my $command = $_;
  if ($command =~ /^m (.*)$/) {
    sendMessage($1);
  } elsif ($command =~ /^t (.*)$/) {
    sendMdsTyping($1);
  } elsif ($command =~ /^o (.*)$/) {
    sendMdsOnline($1);
  } elsif ($command =~ /^q$/) {
    exit(0);
  } else {
    print $info_string;
  }
}

sub usage {
  die "usage: $0 bundle_id apns_auth_key apns_key_id team_id apns_token\n";
}

sub sendMessage($) {
  my ($text) = (@_);

  my $message_command = "\"eventName\": \"NEW_CHAT_MESSAGE\", \"eventText\" : \"$text\"";

  sendPush($message_command);
}

sub sendMdsOnline($) {
  my ($mds_is_online) = (@_);

  if($mds_is_online) {
    sendPush("\"eventName\": \"MDS_ONLINE\", \"mdsIsOnline\": true")
  } else {
    sendPush("\"eventName\": \"MDS_ONLINE\", \"mdsIsOnline\": false")
  }
}

sub sendMdsTyping($) {
  my ($mds_is_typing) = (@_);

  if($mds_is_typing) {
    sendPush("\"eventName\": \"MDS_TYPING\", \"mdsIsTyping\": true")
  } else {
    sendPush("\"eventName\": \"MDS_TYPING\", \"mdsIsTyping\": false")
  }
}

sub sendPush($) {
  my ($content) = (@_);

  my $typing_command = "\"eventName\": \"MDS_TYPING\, \"mdsIsTyping\": false";

  my $command = "go run main.go -type alert -sandbox -auth-token $apns_auth_key -key-id $apns_key_id  -team-id $team_id -token $apns_token  -topic $bundle_id -alert-json '{ \"eventData\": {\"noteId\":\"c99f0ce5-ebac-46ac-bb24-09b3af503e10\"}, \"timestamp\": 1723828174, $content, \"google.c.fid\": \"dusMwTJZc0yygaWRyzPrtc\", \"google.c.sender.id\": \"275532120624\", \"aps\": {    \"badge\": 0 }, \"gcm.message_id\": 1723828174396452, \"eventId\": \"68f319ff-ea24-411a-a3ae-439fded6c518\", \"source\": \"ML\", \"userIdentifiers\": [\"c99f0ce5-ebac-46ac-bb24-09b3af503e10\"], \"google.c.a.e\": 1}' > /dev/null 2>&1";

  system($command);// or die "cannot run command: $!\n";
}


