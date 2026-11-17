#!/bin/sh
# Rebuilds ForAliyah.7z from its parts. Run with:  sh join-mac-linux.sh
set -e
cd "$(dirname "$0")"
NAME='ForAliyah.7z'
EXPECTED=96326898
SHA="f0d639f680c9319c83c44171d13e554617cfffeb30f05df103bda72d3b9e4c85"
echo "Joining parts of $NAME ..."
rm -f -- "./$NAME"
LC_ALL=C cat -- "./$NAME".??? > "./$NAME"
SIZE=$(wc -c < "./$NAME" | tr -d ' ')
if [ "$SIZE" -ne "$EXPECTED" ]; then
  echo "SIZE MISMATCH: got $SIZE bytes, expected $EXPECTED. A part is missing or damaged."; exit 1
fi
echo "Size OK: $SIZE bytes."
if [ -n "$SHA" ]; then
  echo "Checking SHA-256 (this can take a while)..."
  if command -v sha256sum >/dev/null 2>&1; then GOT=$(sha256sum -- "./$NAME" | cut -d' ' -f1)
  elif command -v shasum >/dev/null 2>&1; then GOT=$(shasum -a 256 -- "./$NAME" | cut -d' ' -f1)
  else GOT=""; echo "No sha256 tool found, skipping checksum."; fi
  if [ -n "$GOT" ]; then
    if [ "$GOT" = "$SHA" ]; then echo "Checksum OK. $NAME is complete and intact."; else echo "CHECKSUM MISMATCH. The rebuilt file is damaged."; exit 1; fi
  fi
fi
echo "Done: $NAME"
