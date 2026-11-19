#!/usr/bin/env bash
set -euo pipefail

url="$1"
expected_sha256="$2"
destination="$3"
archive="$(mktemp)"
trap 'rm -f "$archive"' EXIT

curl --fail --location --silent --show-error --output "$archive" "$url"
if command -v sha256sum >/dev/null; then
  digest="$(sha256sum < "$archive")"
else
  digest="$(shasum -a 256 < "$archive")"
fi
actual_sha256="${digest%% *}"
if [[ "$actual_sha256" != "$expected_sha256" ]]; then
  printf 'SHA-256 mismatch for %s\nExpected %s\nReceived %s\n' \
    "$url" "$expected_sha256" "$actual_sha256" >&2
  exit 1
fi

tar -xzf "$archive" -C "$destination"
