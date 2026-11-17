#!/bin/sh
# 0 = don't force anything
# set to the CS_APK_BUILD of the newest APK only when xash.so changed
APK_BUILD=2
APK_URL="https://github.com/ZacharyLester/CSPB-Reborn-Resources/releases/latest"

if [ "$APK_BUILD" -gt 0 ]; then
	echo "$APK_BUILD $APK_URL" > cstrike/downloaded/apkreq.txt
else
	rm -f cstrike/downloaded/apkreq.txt
fi

: > manifest.txt

# every file: size:md5
{
	find cstrike/downloaded cstrike/gfx/vgui cstrike/models cstrike/sound cstrike/sprites \
		cstrike/arm64-v8a cstrike/armeabi-v7a -type f
	find cstrike -maxdepth 1 -type f -name '*.pak'
} | while IFS= read -r f
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
