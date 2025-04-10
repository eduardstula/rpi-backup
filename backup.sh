#!/bin/bash

# === NASTAVENÍ ===
NAS_SERVER="192.168.0.10" # IP address of your NAS server
NAS_SHARE="rpi-backup" # Name of the shared folder on the NAS
NAS_USER="" # Username for NAS access
NAS_PASS="" # Password for NAS access
DISK_DEVICE="/dev/mmcblk0"     # nebo např. /dev/sda pro SSD
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$NAS_MOUNT/rpi1-$DATE.img.gz"
RETENTION_DAYS=30
LOG_FILE="/var/log/rpi-backup-dd.log"
MARKER_FILE=".backup-marker"   # můžeš vytvořit ručně na NASu pro validaci mountu

# === PŘIPOJENÍ NAS ===
mkdir -p "$NAS_MOUNT"
if ! mountpoint -q "$NAS_MOUNT"; then
    mount -t cifs "//$NAS_SERVER/$NAS_SHARE" "$NAS_MOUNT" \
        -o username=$NAS_USER,password=$NAS_PASS,iocharset=utf8,file_mode=0770,dir_mode=0770,vers=3.0
    if [ $? -ne 0 ]; then
        echo "[$(date)] CHYBA: Nepodařilo se připojit NAS $NAS_SERVER/$NAS_SHARE" >> "$LOG_FILE"
        exit 1
    fi
fi

# === OVĚŘENÍ MOUNTU ===
if [ ! -f "$NAS_MOUNT/$MARKER_FILE" ]; then
    echo "[$(date)] CHYBA: NAS mount neobsahuje marker – pravděpodobně mount selhal!" >> "$LOG_FILE"
    umount "$NAS_MOUNT"
    exit 1
fi

# === VYTVÁŘENÍ ZÁLOHY ===
echo "[$(date)] Spouštím zálohu $DISK_DEVICE do $BACKUP_FILE" >> "$LOG_FILE"
dd if="$DISK_DEVICE" bs=4M status=progress conv=fsync | gzip > "$BACKUP_FILE"
EXIT_CODE=$?

# === VYHODNOCENÍ ===
if [ $EXIT_CODE -eq 0 ]; then
    echo "[$(date)] Záloha úspěšná." >> "$LOG_FILE"
else
    echo "[$(date)] CHYBA: Záloha selhala s kódem $EXIT_CODE" >> "$LOG_FILE"
    rm -f "$BACKUP_FILE"
    umount "$NAS_MOUNT"
    exit 2
fi

# === ÚKLID STARÝCH ZÁLOH ===
find "$NAS_MOUNT" -type f -name "*.img.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

# === ODPOJENÍ NAS ===
umount "$NAS_MOUNT"
