#!/bin/sh
: > manifest.txt

# every file: size:md5
find cstrike/downloaded cstrike/gfx/vgui cstrike/models cstrike/sound \
	cstrike/arm64-v8a cstrike/armeabi-v7a -type f | while IFS= read -r f
do
	h=$(md5sum "$f")
	echo "$(stat -c %s "$f"):${h%% *} $f" >> manifest.txt
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