# Uptime Kuma Backup

Uptime Kuma Backup is a tool for backing up and restoring Uptime Kuma data.

## Walkthrough Video

[![Uptime Kuma Backup Walkthrough Video](https://img.youtube.com/vi/grUB1euIwEo/0.jpg)](https://www.youtube.com/watch?v=grUB1euIwEo)

## Need Help or have an issue?

Please post in the [BigBearCommunity](https://community.bigbeartechworld.com/c/big-bear-scripts/9) with your issue. Try to be detailed in your issue.

If you have a feature request please post in the [BigBearCommunity](https://community.bigbeartechworld.com/c/big-bear-scripts/bigbearscript-suggestions/42).

## Using Proxmox

So if you're using Proxmox you need to open up ssh and run the following commands:

1. Setup a root password

```bash
sudo passwd root
```

2. Enable ssh

```bash
nano /etc/ssh/sshd_config
```

3. Change the following line:

```bash
PermitRootLogin without-password
```

to

```bash
PermitRootLogin yes
```

4. Restart ssh

```bash
systemctl restart sshd
```

# Install Uptime Kuma Backup

1. Install git on your OS

2. Clone the repo

```bash
git clone https://github.com/bigbeartechworld/uptime-kuma-backup.git uptime-kuma-backup
```

3. Change directory

```bash
cd uptime-kuma-backup
```

4. Run the backup script

```bash
sh ./backup.sh
```

5. Run the restore script

```bash
sh ./restore.sh
```
