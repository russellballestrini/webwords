#!/bin/bash

echo "listening on 0.0.0.0:31337"

# Use socat to create HTTP server
socat TCP-LISTEN:31337,fork,reuseaddr SYSTEM:"/app/request-handler.sh"