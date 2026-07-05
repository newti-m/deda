#!/usr/bin/env bash
# Fail if any matched vault file contains plaintext values (no encryption).
# Supports both fully encrypted files and inline vault (!vault |) values.
set -euo pipefail
status=0
for f in "$@"; do
  [ -f "$f" ] || continue
  # Fully encrypted file starts with $ANSIBLE_VAULT
  if head -n1 "$f" | grep -q '^\$ANSIBLE_VAULT'; then
    continue
  fi
  # Inline vault: check that !vault markers exist and contain $ANSIBLE_VAULT
  if grep -q '!vault' "$f"; then
    # Count !vault markers vs $ANSIBLE_VAULT headers — should match
    vault_count=$(grep -c '!vault' "$f" || true)
    encrypted_count=$(grep -c '\$ANSIBLE_VAULT' "$f" || true)
    if [ "$vault_count" -ne "$encrypted_count" ]; then
      echo "ERROR: $f has $vault_count !vault markers but only $encrypted_count encrypted values"
      status=1
    fi
  else
    echo "ERROR: $f is not ansible-vault encrypted (no \$ANSIBLE_VAULT or !vault found)"
    status=1
  fi
done
exit $status
