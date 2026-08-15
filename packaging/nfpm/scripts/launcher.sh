#!/bin/sh
APPDIR="/usr/share/mechanix/mechanix-camera"
exec "$APPDIR/mechanix_camera" --bundle="$APPDIR" "$@"
