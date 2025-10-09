#!/usr/bin/env tclsh

# Tcl WebWords Implementation
# This uses the built-in Tcl HTTP server capabilities

package require http

# Global variables
set server_socket ""
set port 31337

# Simple URL decode function
proc url_decode {str} {
    regsub -all {\+} $str { } str
    regsub -all {%([0-9A-Fa-f][0-9A-Fa-f])} $str {[format %c 0x\1]} str
    return [subst $str]
}

# Parse query string manually
proc parse_query {query} {
    array set params {}
    foreach pair [split $query "&"] {
        set eq_pos [string first "=" $pair]
        if {$eq_pos >= 0} {
            set key [string range $pair 0 [expr $eq_pos - 1]]
            set value [string range $pair [expr $eq_pos + 1] end]
            set params([url_decode $key]) [url_decode $value]
        }
    }
    return [array get params]
}

# Procedure to handle HTTP requests
proc handle_request {sock} {
    # Read the request line
    if {[gets $sock request_line] < 0} {
        close $sock
        return
    }
    
    # Parse the request line
    set request_parts [split $request_line " "]
    set method [lindex $request_parts 0]
    set path_query [lindex $request_parts 1]
    
    # Skip headers
    while {[gets $sock line] > 0} {
        # Continue reading until empty line
    }
    
    set found "false"
    
    if {$method eq "GET" && [string match "/*" $path_query]} {
        # Parse query parameters
        set query_start [string first "?" $path_query]
        if {$query_start >= 0} {
            set query [string range $path_query [expr $query_start + 1] end]
            array set params [parse_query $query]
            
            if {[info exists params(keyword)] && [info exists params(target)]} {
                set keyword $params(keyword)
                set target $params(target)
                
                # Make HTTP/HTTPS request to target using curl for HTTPS support
                if {[catch {
                    if {[string match "https://*" $target]} {
                        # Use curl for HTTPS requests
                        set body [exec curl -s -m 10 $target]
                    } else {
                        # Use built-in HTTP for HTTP requests
                        set token [http::geturl $target -timeout 10000]
                        set body [http::data $token]
                        http::cleanup $token
                    }
                    
                    # Check if keyword exists in body
                    if {[string first $keyword $body] >= 0} {
                        set found "true"
                    }
                    
                    puts "found=$found, keyword=$keyword, uri=$target"
                } error]} {
                    puts "Error: $error"
                }
            }
        }
    }
    
    # Send HTTP response
    set response "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: [string length $found]\r\n\r\n$found"
    puts -nonewline $sock $response
    flush $sock
    close $sock
}

# Procedure to accept connections
proc accept_connection {sock addr port} {
    fconfigure $sock -blocking 0 -buffering line
    fileevent $sock readable [list handle_request $sock]
}

# Start the server
proc start_server {port} {
    global server_socket
    
    set server_socket [socket -server accept_connection $port]
    puts "listening on 0.0.0.0:$port"
    
    # Keep the server running
    vwait forever
}

# Main execution
if {[info script] eq $argv0} {
    start_server $port
}