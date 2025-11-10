# Installation Instructions for Linux Public Workstation Computers (Network Boot)

Tested with Ubuntu / Mint based distros.

1. Install a standard Debian/Ubuntu server as boot server.
   ```
   apt install nfs-kernel-server tftp-hpa isc-dhcp-server
   ```

   Adjust your NFS config to allow write access for the reference computer, which is set up in the following steps.
   In this example, the client computer image will be copied into `/srv/tftp/linux-live/lm_x64_1` on the server.
   ```
   # r/w share for reference computer with IP 212.201.56.5
   # ro share for the entire public workplace network 212.201.56.0/24
   /srv/tftp/linux-live/lm_x64_1 212.201.56.5/255.255.255.255(rw,no_root_squash,sync,no_subtree_check) 212.201.56.0/255.255.255.0(ro,no_root_squash,async,no_subtree_check)
   ```
   Restart with `service nfs-kernel-server restart`.

   Adjust your DHCP server config `/etc/default/isc-dhcp-server`:
   ```
   ...
   INTERFACESv4="ens192 ens224" # adjust for your interface names
   INTERFACESv6=""
   ```

   And in `/etc/dhcp/dhcpd.conf`, configure your subnets and hosts ("next-server" is the IP of your boot server):
   ```
   authoritative;

   option domain-name "example.com";
   option domain-name-servers <DNS-Server-IP1>, <DNS-Server-IP2>, <DNS-Server-IP3>;

   subnet 212.201.56.0 netmask 255.255.255.0 {
     option routers 212.201.56.1;
     next-server 212.201.56.3;
     filename "pxelinux.0";
     max-lease-time 3600;
   }

   host PUBLIC111 {
     hardware ethernet ca:ff:ee:ca:ff:ee;
     fixed-address 212.201.56.111;
   }
   ... more hosts here ...
   ```
   ```
   service isc-dhcp-server restart
   ```

2. Install your desired distro for the public workstation on a reference computer.  
   - Make any system adjustment you want to have persistent on all workstations, e.g.:
     ```
     # general software installation (example)
     apt-get purge thunderbird pix simple-scan pidgin transmission-gtk rhythmbox brasero virtualbox-guest-utils celluloid warpinator hypnotix mintreport mintwelcome timeshift webapp-manager sticky mint-l-icons mint-l-theme mintchat
     apt-get install openssh-server dconf-cli dconf-editor bookletimposer htop mc xprintidle gimp inkscape audacity zenity xprintidle

     # no CUPS auto discovery
     systemctl disable cups-browsed

     # VNC remote access for support
     apt-get purge vino
     apt-get install x11vnc
     x11vnc -storepasswd /etc/x11vnc_passwd  # enter a VNC password
     systemctl enable x11vnc.service

     # create public users
     adduser www     # user for German language settings
     adduser wwwen   # user for English language settings
     groupadd publicuser
     usermod -aG publicuser www
     usermod -aG publicuser wwwen
     ```

   - Copy all scripts from this repo into `/opt/`.
   - Copy and adjust config files from this repo into `/etc/`:
     - `/etc/lightdm/`: login screen config (auto login user "www" after 30 seconds).
     - `/etc/systemd/`: DNS and NTP config, VNC and custom startup scripts service definition.
     - `/etc/environment`: system-wide proxy configuration (for captive portal, users need to log in before they can access the internet).
     - `/etc/fstab`: add necessary RAM disks in `/etc/fstab` to make the system successfully boot from a read-only file system (NFS share).
     - `/etc/sudoers`: allow the public users to (un)mount a temporary RAM disk on their home dir for automatic profile reset.

   - Copy and adjust OPTIONAL/recommended config files from this repo into `/etc`:
     - `/etc/acpi/acpi/events/`: for the hardware used in the SLUB, this small fix for Pulse audio server is necessary to make plugged in headsets work automatically.
     - `/etc/dconf/db/local.d/`: use this to set any dconf defaults you like. Currently we only define the default mouse pointer.
     - `/etc/firefox/policies/`: policies for the Firefox browser.
     - `/opt/chrome/policies/`: policies for the Google Chrome browser.
     - `/etc/polkit-1/rules.d/`: Polkit rules (allow all users to format USB drives and disallow shutting down the computers).
     - `/etc/ssh/`: proxy config for SSH.

   - Log in into the user accounts (www, wwwen) and make any adjustments you want to have persistent for the public users, e.g. language settings, browser bookmarks, home page etc. After that, log out and create the profile skeletons from the current home dirs:
     ```
     makeskel.sh /
     ```
     This will copy the home dirs into `/etc/skel.$user`. The automatic profile reset will copy the profile from there every time when logging in (automatic profile reset).

   - You may also want to disable the execution of some applications for the unprivileged users, e.g.:
     ```
     chmod 0754 /usr/bin/gnome-terminal
     chmod 0754 /usr/bin/gnome-terminal.real
     chmod 0754 /usr/bin/gnome-terminal.wrapper
     chmod 0754 /usr/bin/cinnamon-menu-editor
     ```

3. (Reference Computer) add NFS boot modules to initramfs `/etc/initramfs-tools/initramfs.conf`:
   ```
   #MODULES=most # this is the default value - comment it out and replace with the following lines:
   BOOT=nfs
   MODULES=netboot
   ```
   Generate new initramfs for netboot:
   ```
   mkinitramfs -o /boot/initrd.img-x.x.x-xx-netboot

   # make readable for TFTP server later
   chmod 0644 /boot/initrd.img-x.x.x-xx-netboot
   chmod 0644 /boot/vmlinux-x.x.x-xx-generic
   ```

4. (Reference Computer) add network config `/etc/network/interfaces` to disallow changing IP address via GUI:
   ```
   iface enp1s0 inet manual
   ```

5. (Reference Computer) adjust the X session:
   - Copy modified xsession files from this repo into `/usr/share/xsessions/`.
     - This enables the automatic profile reset. The modified session will call `/opt/slub/session.sh`, which resets the profile and then start the Cinnamon desktop.
     - A temporary ramdisk will be mounted on the home dir with the "noexec" parameter in order to disallow execution of downloaded (portable) executables.
     - The content of `/etc/skel.$user` will be copied into the new, empty ramdisk home dir.
   - Remove `/usr/share/wayland-sessions/cinnamon-wayland.desktop` to disable Wayland (for now).

6. (Reference Computer) copy the reference system onto your boot server.  
   ```
   # install NFS client packages
   apt-get install nfs-common cifs-utils portmap

   # mount NFS share of the boot server and copy the entire client root fs
   mount -tnfs -onolock <IP-ADDRESS-OF-NFS-SERVER>:/srv/tftp/linux-live/lm_x64_1 /mnt
   cp -axv /. /mnt/.
   cp -axv /dev/. /mnt/dev/. 
   ```

   After successful copying, you should revoke the write permission of the reference computer to the NFS share by changing the `rw` parameter to `ro` in `/etc/exports` on the server.

7. (Boot Server) set up network bootloader:
   - Download [PXELINUX](https://wiki.syslinux.org/wiki/index.php?title=Download) and extract `/bios/core/pxelinux.0` and `/bios/com32/menu/vesamenu.c32` into your TFTP root `/srv/tftp/`.
   - Create netboot boot menu definition file `/srv/tftp/pxelinux.cfg/default` (replace kernel, initrd and server IP accordingly):
   ```
   INCLUDE /boot/graphics.cfg

   UI         vesamenu.c32
   MENU TITLE Network Boot Public Workstation
   TIMEOUT    5

   LABEL      lm_x64_1
   MENU LABEL Linux Mint 22
   TEXT HELP
   Start Public Workstation via Network Boot
   ENDTEXT
   KERNEL     linux-live/lm_x64_1/boot/vmlinuz-x.x.x-xx-generic
   APPEND     root=/dev/nfs netboot=nfs nfsroot=<IP-ADDRESS-OF-NFS-SERVER>:/srv/tftp/linux-live/lm_x64_1/ initrd=linux-live/lm_x64_1/boot/initrd.img-x.x.x-xx-netboot

   #LABEL      localboot
   #MENU LABEL Boot From Local Disk
   #LOCALBOOT  0

   #LABEL memtest
   #MENU label Memtest86+
   #KERNEL /special/memtest
   ```

8. Boot your client from network (you may need to enable network boot in the BIOS). Make sure it boots in legacy mode (enable CSM). UEFI mode boot support is possible too but currently not part of this guide.
   - Your client should get an address from your DHCP server with the info to download the network bootloader (pxelinux.0) via TFTP. Then, kernel and initramfs will be downloaded as defined in pxelinux.cfg.
   - After loading kernel and initramfs, the client will mount your NFS share with the root file system.
   - The system will now boot further into graphical user interface.

# Resources
- [Syslinux/PXELINUX configuration](https://wiki.syslinux.org/wiki/index.php?title=PXELINUX)
