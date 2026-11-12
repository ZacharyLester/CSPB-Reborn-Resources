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

# case-insensitive duplicates break on Android storage
dups=$(cut -d' ' -f2- manifest.txt | tr 'A-Z' 'a-z' | sort | uniq -d)
if [ -n "$dups" ]; then
	echo "case duplicates, fix these first:"
	echo "$dups"
	exit 1
fi

git add -A
git commit -m "update resources"
git push