# Raspberry Pi to NAS backup

This script provides a **safe and automated way to back up your Raspberry Pi** to a **SMB (CIFS) NAS share** using the `dd` command. It includes built-in checks to avoid common pitfalls and ensures old backups are cleaned up automatically.

## How it works

There are several methods to back up a Raspberry Pi to a NAS. This script uses the `dd` command to create a full disk image of your Raspberry Pi and stores it directly on a mounted NAS share.

✅ **Benefits:**
- Creates a complete image of your Raspberry Pi (bootloader, partitions, OS, all files)
- Easy to restore by writing the image back to an SD card or SSD
- Works well as a part of a homelab backup strategy

⛔ **Drawbacks:**
- Image creation takes time and requires significant NAS storage space
- Not ideal for frequent backups (recommended for weekly/monthly snapshots)

## Features

- ✅ Automatically mounts the NAS share before backup
- ✅ Verifies that the NAS is properly mounted (avoids writing to local filesystem)
- ✅ Creates backups with date-based filenames
- ✅ Cleans up old backups (e.g. older than 30 days)
- ✅ Automatically unmounts the NAS after backup
- ✅ Logs each backup run with timestamps and status messages

## Requirements

- SMB (CIFS) share on a NAS server
- Raspberry Pi running Linux (tested on Raspberry Pi OS)
- Root access (`sudo`) for accessing raw disk device
- Enough free space on the NAS for full disk images

## Installation

### 1. download the script from the repository:

```bash
curl -L https://raw.githubusercontent.com/yourusername/rpi-backup-dd/main/rpi-backup-dd.sh -o rpi-backup-dd.sh
```
or download the file manually from the repository.

Copy the script to your Raspberry Pi, for example to `~/rpi-backup-dd.sh`.

Make it executable:
```bash
chmod +x ~/rpi-backup-dd.sh
```
### 2. Configure the script
Edit the script to set your NAS share details and backup preferences. Open the script in a text editor:

```bash
nano ~/rpi-backup-dd.sh
```
Set the following variables in the script to match your NAS configuration:

```bash
NAS_SERVER="192.168.0.10" # IP address of your NAS server
NAS_SHARE="rpi-backup" # Name of the shared folder on the NAS
NAS_USER="" # Username for NAS access
NAS_PASS="" # Password for NAS access
RETENTION_DAYS=30 # Number of days to keep backups
```

### 3. Create a marker file

Create a file like .backup-marker on the NAS share to verify proper mount.

## Run the script
You can run the script manually or set it up as a cron job for automatic backups.
To run the script manually, execute the following command:

```bash
sudo ~/rpi-backup-dd.sh
```

or automatically via cron job:

```bash
sudo crontab -e
```
Add the following line to run the script every monday at 2 AM:

```bash
0 2 * * 1 /path/to/rpi-backup-dd.sh
```

Make sure to replace `/path/to/rpi-backup-dd.sh` with the actual path to the script.

## View logs
The script logs its activity to a log file located at `/var/log/rpi-backup-dd.log`. You can view the log file using:

```bash
cat /var/log/rpi-backup-dd.log
```

or tail it to see the latest entries:

```bash
tail -f /var/log/rpi-backup-dd.log

```
## 🫂 Contributing

If you want to contribute to this project, you can create a pull request with your changes. I will be happy to review and merge them.

## 🧪 Tested on
- Ubuntu 24.x

## 📒 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 😶 Disclaimer
This script is provided "as-is" without any warranties. Use it at your own risk. Always test backups and restores in a safe environment before relying on them for critical data.