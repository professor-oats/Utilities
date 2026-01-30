#!/bin/bash
set -euo pipefail

export TPM2TOOLS_TCTI=device:/dev/tpmrm0

BLOB="/opt/vault/unseal/unseal.blob"
IV="/opt/vault/unseal/iv.bin"
HANDLE="0x81010001"

# If Vault is already unsealed, exit cleanly
if vault status -format=json 2>/dev/null | grep -q '"sealed":false'; then
  exit 0
fi

TMP=$(mktemp /run/vault/vault-unseal.XXXXXX)

tpm2_encryptdecrypt \
  -d \
  -c "$HANDLE" \
  -G cfb \
  -t "$IV" \
  -o "$TMP" \
  "$BLOB"

# Unseal using each line (supports multi-key threshold)
while IFS= read -r key; do
  [ -z "$key" ] && continue
  vault operator unseal "$key"
done < "$TMP"

shred -u "$TMP"
