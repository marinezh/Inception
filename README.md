# Inception

**Project:** Part of the 42 curriculum  
**Author:** mzhivoto / Marina Zhivotova

This README documents the initial setup steps for the Inception project, including Debian system configuration, package management, and VirtualBox shared folder setup.

---

## 1. Initial Steps After Debian Installation

### Gain Root Access and Set up Sudo

Begin by switching to the root user:

```bash
su -
```

When successfully logged in as root, your prompt will change to:
```
root@Inception:~#
```

Once logged in as root, add your user to the sudo group and reboot:

```bash
usermod -aG sudo mzhivoto
reboot
```

### Verify Sudo Access

After rebooting, test that sudo works correctly:

```bash
sudo ls
```

You'll be prompted for your password on the first use.

---

## 2. Configure APT Package Manager

### Overview
Configure the APT sources to ensure packages are downloaded from internet repositories rather than a local DVD.

### Step 1: Open the Sources File

Open the APT sources configuration:

```bash
sudo nano /etc/apt/sources.list
```

### Step 2: Disable the DVD Repository

Inside the nano editor, locate the line starting with `deb cdrom:`:

```
deb cdrom:[Debian GNU/Linux 12.12.0 Bookworm ...]
```

Add a `#` at the beginning to comment it out:

```
# deb cdrom:[Debian GNU/Linux 12.12.0 Bookworm ...]
```

### Step 3: Add Internet Repositories

If the file is mostly empty after disabling the DVD source, add these three repository lines:

```
deb http://deb.debian.org/debian bookworm main
deb http://deb.debian.org/debian bookworm-updates main
deb http://security.debian.org/debian-security bookworm-security main
```

### Step 4: Save and Exit

In nano:
- Press `Ctrl + O` then `Enter` to save
- Press `Ctrl + X` to exit

### Step 5: Update Package Lists

Update APT to refresh the package index:

```bash
sudo apt update
```

### Expected Result

- ✅ No requests for DVD
- ✅ Packages download from internet repositories
- ✅ No error messages (warnings are acceptable)

---

## 3. Set Up VirtualBox Shared Folder

### Overview
Enable shared folder functionality in VirtualBox by installing Guest Additions and configuring folder permissions.

### Prerequisites

First, install build tools required for Guest Additions:

```bash
sudo apt install build-essential dkms linux-headers-$(uname -r)
```

### Step 1: Insert Guest Additions ISO

From the VirtualBox VM menu (top of the VM window):

```
Devices → Insert Guest Additions CD Image
```

> **Note:** It's normal if no popup appears.

### Step 2: Mount the CD

Mount the Guest Additions CD:

```bash
sudo mount /dev/cdrom /media
```

If this fails, try the alternative device:

```bash
sudo mount /dev/sr0 /media
```

Verify the mount was successful:

```bash
ls /media
```

You should see files including `VBoxLinuxAdditions.run`.

### Step 3: Run the Guest Additions Installer

Execute the installer:

```bash
sudo sh /media/VBoxLinuxAdditions.run
```

Allow 1-2 minutes for completion.

> **Note:** Warnings are acceptable; errors should be reported.

### Step 4: Reboot

Restart the system:

```bash
sudo reboot
```

### Step 5: Configure Shared Folder Permissions

After reboot, add your user to the VirtualBox shared folder group:

```bash
sudo usermod -aG vboxsf mzhivoto
sudo reboot
```

### Step 6: Verify Shared Folder Access

After the final reboot, verify the shared folder is accessible:

```bash
ls /media
```

You should see:
```
sf_shared
```

---

## Summary

These steps complete the essential setup for your Inception project environment:
1. Root access and sudo privileges are configured
2. APT package manager is properly configured for internet repositories
3. VirtualBox Guest Additions and shared folder access are enabled

Your system is now ready for further Inception project development.
