#!/bin/bash
echo "listening on 0.0.0.0:31337"
socat TCP-LISTEN:31337,reuseaddr,fork EXEC:"/app/request-handler.sh"