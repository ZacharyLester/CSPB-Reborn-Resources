#!/bin/sh
find cstrike/downloaded cstrike/gfx/vgui cstrike/models cstrike/sound \
	cstrike/arm64-v8a cstrike/armeabi-v7a -type f \
	-printf '%s %p\n' > manifest.txt
git add -A
git commit -m "update resources"
git push