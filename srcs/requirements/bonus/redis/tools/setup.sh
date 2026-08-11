#!/bin/bash

# Run Redis in the foreground
# listening on all interfaces so WP can reach it
exec redis-server --bind 0.0.0.0 --protected-mode no