#!/bin/sh
: > manifest.txt

# normal files: size only
find cstrike/downloaded cstrike/gfx/vgui cstrike/models cstrike/sound -type f \
	-printf '%s %p\n' >> manifest.txt

# libs: size:md5
find cstrike/arm64-v8a cstrike/armeabi-v7a -type f | while IFS= read -r f
do
	echo "$(stat -c %s "$f"):$(md5sum "$f" | cut -d' ' -f1) $f" >> manifest.txt
done

git add -A
git commit -m "update resources"
git push