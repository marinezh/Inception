# Inception
This project has been created as part of the 42 curriculum by mzhivoto / Marina Zhivotova

## first steps after Debian installation
```bash
su-
```
If login succeeds, your prompt will change to something like:
root@Inception:~#
- Once you are logged in as root, run:
```bash
usermod -aG sudo mzhivot
reboot
```
- after rebooting:
```bash
sudo ls
```
will ask for the password, and when it shows the directories


//////////////////////////////////////////////////
✅ STEP 1 — Open the sources file

Type exactly:
sudo nano /etc/apt/sources.list

Press Enter.

✅ STEP 2 — Disable the DVD repository

Inside nano, you will see a line similar to:
deb cdrom:[Debian GNU/Linux 12.12.0 Bookworm ...]


👉 Do ONE thing:

Move the cursor to the beginning of that line
Add a # at the start
It should become:

# deb cdrom:[Debian GNU/Linux 12.12.0 Bookworm ...]

(Just ONE #)

✅ STEP 3 — Add internet repositories (ONLY 3 short lines)

If the file is now empty or almost empty, add these 3 lines:

deb http://deb.debian.org/debian bookworm main
deb http://deb.debian.org/debian bookworm-updates main
deb http://security.debian.org/debian-security bookworm-security main

Nothing else.

✅ STEP 4 — Save and exit nano

Press Ctrl + O → Enter
Press Ctrl + X

✅ STEP 5 — Update again (this should FIX IT)

Type:
sudo apt update

✅ Correct result:

NO request for DVD
Packages download from the internet
No red errors
///////////////////////////////////////////////////////
 ## Set up shared folder

#install:
 ```bash
 sudo apt install build-essential dkms linux-headers-$(uname -r)
```
✅ STEP 1 — Insert Guest Additions ISO (again)

In the VM window menu (top of the VM window):

Devices → Insert Guest Additions CD Image


⚠️ No popup is OK.

✅ STEP 2 — Mount the CD manually

In the VM terminal, type:

sudo mount /dev/cdrom /media


If that gives an error, try:

sudo mount /dev/sr0 /media


Now check:

ls /media


👉 You should see files, especially:

VBoxLinuxAdditions.run

✅ STEP 3 — Run the installer

Type:

sudo sh /media/VBoxLinuxAdditions.run


Wait until it finishes (1–2 minutes).

⚠️ If you see warnings — OK
❌ If you see errors — tell me the last 2 lines only

✅ STEP 4 — Reboot
sudo reboot

✅ STEP 5 — Enable shared folder access

After reboot:

sudo usermod -aG vboxsf mzhivoto
sudo reboot

✅ STEP 6 — Check shared folder

After reboot:

ls /media

You should now see:
sf_shared