# Upgrade the Netboot Image for Public Workstations

Updates to the network boot image can be applied comfortably on the server shell.

1. Make a copy of the image:
   ```
   cd /srv/tftp/linux-live
   cp -Ra m_x64_1 lm_x64_2
   ```

2. Update via chroot:
   ```
   # go into image dir
   cd lm_x64_2

   # bind-mount /dev und /sys from host to image
   # (required by apt)
   mount -o bind /dev dev
   mount -o bind /dev/pts dev/pts
   mount -o bind /sys sys

   # dive into image
   chroot .

   # temporary entry: nameserver <IP-of-your-DNS-server>
   nano /etc/resolv.conf
   # uncomment proxy server temporarily
   nano /etc/environment

   # do your adjustments, e.g.
   apt update
   apt upgrade
   gdebi google-chrome.deb

   # reverse temporary changes!
   nano /etc/resolv.conf
   nano /etc/environment

   # exit chroot
   exit

   # unmount
   umount dev/pts
   umount dev
   umount sys
   ```

3. Boot from the new image.
   - Start with one single test computer by creating `/srv/tftp/pxelinux.cfg/01-ca-ff-ee-ca-ff-ee` from `/srv/tftp/pxelinux.cfg/default` where ca-ff-ee-ca-ff-ee is the MAC address of the test computer. Adjust the path to the NFS mount (`lm_x64_2`). Do not forget to allow NFS read access to the new image in `/etc/exports`.
   - If everything works well, adjust `/srv/tftp/pxelinux.cfg/default` accordingly.
