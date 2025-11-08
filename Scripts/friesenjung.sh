###
### Just a pleb script to do a vzdump to a pbs data store and tell the idiot how to restore
### Grabs the latest snapshot via ssh 
### Could patch the label set later on since it doesn't apply currently and is just used as a confirmation prompt

#!/usr/bin/env bash

set -euo pipefail

# -----------------------------
# osism-checkpoint-wrapper.sh
# -----------------------------

LABEL="${1:-}"

if [[ -z "$LABEL" ]]; then
    echo "Usage: $0 <label>"
    exit 1
fi

VMID=100
STOR=pbs-ds1
SSH_KEY="/root/.ssh/id_ed25519_patricja"
SSH_USER="patricja"
PBS_SERVER="192.168.1.96"
PBS_VM_PATH="/mnt/datastore/${STOR}/vm/${VMID}"

echo "[*] Creating checkpoint for VM $VMID → $STOR (label: $LABEL)"

# Run vzdump backup in snapshot mode
vzdump "$VMID" \
    --storage "$STOR" \
    --mode snapshot \
    --compress zstd \
    --quiet 0 \
    --tmpdir /var/tmp 

echo
echo "[✓] Backup complete!"
echo 
echo "Getting TIMESTAMP and name for the snapshot created"
echo

TIMESTAMP=$(ssh -i "$SSH_KEY" "$SSH_USER@$PBS_SERVER" "ls -1t ${PBS_VM_PATH} | head -n 1")

if [[ -z "$TIMESTAMP" ]]; then
    echo "[!] Could not detect backup folder on PBS server $PBS_SERVER"
    exit 1
fi

echo "Snapshot created successfully with the timestamp ${TIMESTAMP}"

# Print exact qmrestore command for convenience
echo
echo "To make restoring possible shutdown the 100 (osism-cloud-in-a-box) in Proxmox GUI"
echo 
echo "[i] To restore this backup, run:"
echo "qmrestore ${STOR}:backup/vm/${VMID}/${TIMESTAMP} 100 --force"
echo
echo "You can also add a Note in PBS: '$LABEL' and mark Protected = ON to prevent pruning."
echo
echo "Start the 100 (osism-cloud-in-a-box) in Proxmox GUI"
echo
