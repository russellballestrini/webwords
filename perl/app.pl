#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Daemon;
use HTTP::Status;
use LWP::UserAgent;
use URI::Escape;
use URL::Encode qw(url_decode);

my $daemon = HTTP::Daemon->new(
    LocalAddr => '0.0.0.0',
    LocalPort => 31337,
    ReuseAddr => 1
) or die "Cannot start daemon: $!";

print "listening on 0.0.0.0:31337\n";

while (my $client = $daemon->accept) {
    while (my $request = $client->get_request) {
        if ($request->method eq 'GET' && $request->uri->path eq '/') {
            my %query = $request->uri->query_form;
            my $keyword = $query{keyword} || '';
            my $target = $query{target} || '';
            my $found = 'false';
            
            if ($keyword && $target) {
                my $ua = LWP::UserAgent->new(timeout => 10);
                my $response = $ua->get($target);
                
                if ($response->is_success) {
                    my $body = $response->content;
                    if (index($body, $keyword) != -1) {
                        $found = 'true';
                    }
                }
                
                print "found=$found, keyword=$keyword, uri=$target\n";
            }
            
            $client->send_response(HTTP::Response->new(
                RC_OK,
                'OK',
                ['Content-Type' => 'text/plain'],
                $found
            ));
        } else {
            $client->send_error(RC_NOT_FOUND);
        }
    }
    $client->close;
    undef($client);
}