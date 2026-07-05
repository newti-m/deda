#!/usr/bin/env bash
# Block any file containing private key headers.
set -euo pipefail
status=0
for f in "$@"; do
  [ -f "$f" ] || continue
  if grep -qE 'BEGIN (RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY' "$f"; then
    echo "ERROR: $f contains a PRIVATE KEY block — refusing commit"
    status=1
  fi
done
exit $status
