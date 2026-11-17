#!/bin/sh
# 0 = don't force anything
# set to the CS_APK_BUILD of the newest APK only when xash.so changed
APK_BUILD=6
APK_URL="https://github.com/ZacharyLester/CSPB-Reborn-Resources/releases/latest"

mkdir -p cstrike/downloaded

# apkreq.txt = "<build> <build spaces><url>"
# The padding changes the file size for every build number,
# so the updater's size check always re-downloads it.
if [ "$APK_BUILD" -gt 0 ]; then
	pad=""
	i=0
	while [ "$i" -lt "$APK_BUILD" ]; do
		pad="$pad "
		i=$((i + 1))
	done
	printf '%s %s%s\n' "$APK_BUILD" "$pad" "$APK_URL" > cstrike/downloaded/apkreq.txt
else
	rm -f cstrike/downloaded/apkreq.txt
fi

# manifest: optional #apk line, then "size:md5 path" for every file
: > manifest.txt
if [ "$APK_BUILD" -gt 0 ]; then
	echo "#apk $APK_BUILD $APK_URL" >> manifest.txt
fi

{
	find cstrike/downloaded cstrike/gfx/vgui cstrike/models cstrike/sound cstrike/sprites \
		cstrike/arm64-v8a cstrike/armeabi-v7a -type f 2>/dev/null
	find cstrike -maxdepth 1 -type f -name '*.pak'
} | sort | while IFS= read -r f
do
	h=$(md5sum "$f")
	echo "$(stat -c %s "$f"):${h%% *} $f" >> manifest.txt
done

# case-insensitive duplicates break on Android storage
dups=$(grep -v '^#' manifest.txt | cut -d' ' -f2- | tr 'A-Z' 'a-z' | sort | uniq -d)
if [ -n "$dups" ]; then
	echo "case duplicates, fix these first:"
	echo "$dups"
	exit 1
fi

# the updater's manifest format can't handle spaces in paths
spaces=$(grep -v '^#' manifest.txt | cut -d' ' -f2- | grep ' ')
if [ -n "$spaces" ]; then
	echo "paths with spaces, rename these first:"
	echo "$spaces"
	exit 1
fi

# sanity check: file size must match the manifest entry
real=$(wc -c < cstrike/downloaded/apkreq.txt 2>/dev/null | tr -d ' ')
listed=$(grep ' cstrike/downloaded/apkreq.txt$' manifest.txt | cut -d: -f1)
echo "apkreq.txt real=$real manifest=$listed"
if [ "$APK_BUILD" -gt 0 ] && [ "$real" != "$listed" ]; then
	echo "size mismatch, not pushing"
	exit 1
fi

git add -A
git commit -m "update resources" || echo "nothing to commit"
git push
