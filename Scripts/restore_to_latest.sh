#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# restore-to-latest.sh
# -----------------------------

VMID=100
STOR="pbs-ds1"
SSH_KEY="/root/.ssh/id_ed25519_patricja"
SSH_USER="patricja"
PBS_SERVER="192.168.1.96"
PBS_VM_PATH="/mnt/datastore/${STOR}/vm/${VMID}"

echo "[*] This will restore your VM $VMID to the latest snapshot."
echo

echo "[*] Getting latest snapshot timestamp from PBS..."
TIMESTAMP=$(ssh -i "$SSH_KEY" "$SSH_USER@$PBS_SERVER" "ls -1t ${PBS_VM_PATH} | head -n 1")

if [[ -z "$TIMESTAMP" ]]; then
    echo "[!] Could not detect a backup folder on PBS server $PBS_SERVER"
    exit 1
fi

echo "[✓] Found latest snapshot timestamp: ${TIMESTAMP}"
echo
echo "To make restoring possible, shutdown the VM (${VMID}) in the Proxmox GUI first."
echo

read -rp "Do you want to proceed with restoring snapshot '${TIMESTAMP}' to VM ${VMID}? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "[*] Restoration cancelled by user."
    exit 0
fi

echo
echo "[*] Starting restore process..."
echo "Executing: qmrestore ${STOR}:backup/vm/${VMID}/${TIMESTAMP} ${VMID} --force"
echo

# Actually perform the restore
qmrestore "${STOR}:backup/vm/${VMID}/${TIMESTAMP}" "${VMID}" --force

echo
echo "[✓] Restore completed successfully!"
echo "You can now start the VM (${VMID}) in the Proxmox GUI."
echo
