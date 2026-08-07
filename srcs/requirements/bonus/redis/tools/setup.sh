#!/bin/bash
# Run Redis in the foreground (--daemonize no is default),
# listening on all interfaces so WordPress (another container) can reach it
exec redis-server --bind 0.0.0.0 --protected-mode no