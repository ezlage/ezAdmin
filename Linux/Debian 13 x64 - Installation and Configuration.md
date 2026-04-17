# Debian 13 x64 - Installation and Configuration

Follow the **Installation** and **Configuration** steps and you'll have a ready-to-use Debian 13 x64 server or template!

Developed by [Ezequiel Lage](https://github.com/ezlage) *et al*. Sponsored by [Lagecorp](https://lagecorp.com) and its subsidiaries. Published under the [MIT License](./LICENSE).

This material is part of the [ezAdmin](https://github.com/ezlage/ezAdmin) repository.

### Installation

1. Make sure the target computer, even virtual, is in UEFI mode, with Secure Boot enabled and in factory settings (i.e. allowing new OS installations).

2. Boot from an installation media.

    Recommended: The complete and stable installation image, the DVD-1 ISO.

    You can download it from [here (13.2)](https://cdimage.debian.org/debian-cd/13.2.0/amd64/iso-dvd/) or [here (current)](https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/).

    This tutorial was made using the Debian 13.2 DVD-1 ISO image.

3. Choose `Advanced options`, then `Graphical expert install`.

4. Go to `Choose a language`.

    - Always select `English` for better compatibility with tutorials, documentation and scripts.

    - When asked for location and locale, select `United States` and `en_US.UTF-8` respectively.

5. Go to `Configure the keyboard` and select the layout that matches your physical keyboard.

6. Go to `Detect and mount installation media`.

    - If the Setup offers to load kernel modules, evaluate and do accordingly.

7. Go to `Load installer components from installation media`.

    - Check if you need any of the offered components and do accordingly.

8. Go to `Detect network hardware` and wait until the process finishes.

9. Go to `Configure the network`.

    - Choose to auto-configure network or set up manually, according to your local environment.

    - Choose a hostname for the system.

        Recommended: A unique lowercase name that identifies the server in your network.

    - Set a domain name for the system.

        Recommended: The same domain used in your network (lowercase).

10. Go to `Set up users and passwords`.

    - Allow login as root?
    
        Recommended: No.

    - Create another administrative user.

        Example name: `Administrator`  
        Example user: `administrator`  
        Password: (create a strong password)  

11. Goto `Configure the clock`.

    - Set the clock using NTP?

        Recommended: Yes.

    - NTP server:
    
        `pool.ntp.org` instead of the default (the fewer different NTP servers in use in the environment, the fewer hosts will need to be allowed through the perimeter firewall).

    - Time zone:
    
        `Coordinated Universal Time (UTC)`. Avoid using other time zones!

12. Go to `Detect disks` and wait until the process finishes.

13. Go to `Partition disks`.

	First of all: in this context, MiB and GiB are different from MB and GB, respectively.

    - Choose `Manual` partitioning method.
    - Select the target disk.
    - Tell that you want to create a new partition table on the disk.
    - Choose GPT partitioning scheme.
    - Create a new partition with `128 MiB` at the beginning, name it `bios`, use it as `Reserved BIOS boot area` and keep the `bootable` flag off.
    - Create a new partition with `2 GiB` at the beginning, name it as `uefi`, use it as `EFI System Partition (ESP)` and turn the `bootable` flag on.
    - Create a new partition with `2 GiB` at the beginning, name it and label it as `boot`, use it as `EXT4 jornaling file system`, mount it at `/boot` and keep the `bootable` flag off.
    - If you need to hibernate your device or have low RAM, create a swap partition that is the same size or larger than your RAM, name it as `swap` and use it as `swap area`.
    - Create a new partition with the remaining space, name it and label it as `root`, use it as `BTRFS journaling file system` and mount it at `/`.
    - If you haven't created a swap partition, accept the warning about its absence.
    - Finish partitioning and write changes to disk.

14. Go to `Install the base system`.

    - Choose the kernel to be installed.

        Recommended: The default one (`linux-image-amd64`).

    - Choose the generic option, which includes all available drivers.

15. Go to `Configure package manager`.

    - Select `no` for scanning additional installation media.
    - Select `yes` for using a network mirror and choose `http`.
    - Choose `United States` or a mirror close to your location.
    - Select `deb.debian.org` as the mirror server.
    - If you use a proxy for internet access, enter its details, otherwise leave it blank.
    - Choose `yes` for using non-free firmware.
    - Choose `yes` for using non-free software.
    - Choose `no` for enabling source repositories.
    - Enable security updates and release updates.

16. Go to `Select and install software`.

    - Select `no` for automatic updates.
    - Select whatever you want for participating in the package usage survey.
    - Select only `SSH server` and/or `standard system utilities`.
    - Do not select any desktop environment.

17. Go to `Install the GRUB boot loader`.

    - Select `yes` for forcing GRUB installation to the EFI removable media path.
    - Choose `yes` for updating NVRAM variables to automatically boot Debian.
    - Choose `no` for running `os-prober` to detect other operating systems.

18. Go to `Finish the installation`.

    - Select `yes` for `Is the system clock set to UTC?` question.

19. Eject the installation media and reboot.

### Configuration

Not necessarily for a system installed as instructed above.

1. If you don't have `sudo`, do the following.

    The CD-ROM repository can display errors, but ignore them for now.

    ```sh
    su -
    apt update
    apt install sudo
    exit
    ```

2. If you don't have access via SSH, do the following.

    ```sh
    sudo apt update
    sudo apt install openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
    ```

3. If you don't have the Nano Editor, do the following.

    ```sh
    sudo apt update
    sudo apt install nano
    nano
    # Use Ctrl+X to exit!
    ```

4. If not done yet, set up an account for future administration with a strong password.

    ```sh
    sudo useradd administrator -m -s /bin/bash
    sudo usermod -aG sudo administrator
    sudo passwd administrator
    ```

5. Don't forget to set a strong password for the root user too.
    
    ```sh
    sudo passwd root
    ```

6. Set the timezone to UTC (Avoid using other time zones!).

    ```sh
    sudo timedatectl set-timezone UTC
    ```

7. Configure network and internet access when needed.
    
    ```sh
    sudo nano /etc/network/interfaces
    ```

    ```sh
    sudo nano /etc/resolv.conf
    ```

    ```sh
    sudo nano /etc/hosts
    ```
    
    ```sh
    sudo hostnamectl set-hostname <a-chosen-server-name>
    ```

8. Adjust the APT repository list.

    ```sh
    sudo nano /etc/apt/sources.list
    # Use Ctrl+K to cut lines!
    ```

    Clear pre-existing content, especially the line mentioning CD-ROM, copy the block below and paste there. Uncomment as needed if you wish to use backports, test or unstable software, as well as source code repositories.
    
    ```
    deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
    deb http://deb.debian.org/debian-security/ trixie-security main contrib non-free non-free-firmware
    deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
    #deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware
    #deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
    #deb http://deb.debian.org/debian unstable main contrib non-free non-free-firmware

    #deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
    #deb-src http://deb.debian.org/debian-security/ trixie-security main contrib non-free non-free-firmware
    #deb-src http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
    #deb-src http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware
    #deb-src http://deb.debian.org/debian testing main contrib non-free non-free-firmware
    #deb-src http://deb.debian.org/debian unstable main contrib non-free non-free-firmware
    ```

9. Do the first system update.

    ```sh
    sudo apt update
    sudo apt full-upgrade
    ```

10. Install some basic packages.

    ```sh
    sudo apt install apt-transport-https ca-certificates openssl lsb-release locales plocate ufw unzip curl wget net-tools bind9-dnsutils git
    ```

    In the case of an on-premises virtual machine.

    ```sh
    # Promxmox, Nutanix or KVM/QEMU
    sudo apt install qemu-guest-agent
    # VMware
    sudo apt install open-vm-tools
    # XCP-NG, Citrix/XenServer
    sudo apt install xe-guest-utilities
    ```

    In the case of Google Cloud Platform Compute Engine.

    ```sh
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh && sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    rm add-google-cloud-ops-agent-repo.sh
    ```

11. Add Ondřej Surý repositories for Debian, if you want to.

    Uncomment only the desired lines, copy, paste and run.

    ```sh
    #curl -sSL https://packages.sury.org/apache2/README.txt | sudo bash -x
    #curl -sSL https://packages.sury.org/bind/README.txt | sudo bash -x
    #curl -sSL https://packages.sury.org/bind-esv/README.txt | sudo bash -x
    #curl -sSL https://packages.sury.org/nginx/README.txt | sudo bash -x
    #curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
    sudo apt update
    ```

12. Setting proper boot for both BIOS and UEFI modes.

    ```sh
    sudo apt update
    sudo apt install grub-pc-bin grub-efi-amd64-bin
    sudo grub-install --force --removable --target=x86_64-efi --efi-directory=/boot/efi
    # identify the ~128 MB BIOS boot partition, e.g. /dev/sda1
    lsblk
	# below, replace *null* with the same value you see in *lsblk*, but removing the final number, e.g. /dev/sda1 becomes /dev/sda.
    sudo grub-install /dev/null --target=i386-pc
    sudo update-grub
    ```

13. Disable IPv6 if it's not needed, and only if there's no swap partition, also disable swappiness.

    ```sh
    sudo touch /etc/sysctl.conf
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 # only if IPv6 is not required
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 # only if IPv6 is not required
    sudo sysctl -w vm.swappiness=0 # only if there's no swap partition
    sudo sysctl -p
    ```

    Even at UFW (only if IPv6 is not required).

    ```sh
    sudo nano /etc/default/ufw
    ```

    Change the IPV6 setting to `no`.

    ```sh
    IPV6=no
    ```

- Do the initial setup of UFW.

    ```sh
    sudo ufw allow 22/tcp
    sudo ufw enable
    ```

- Configure culture, language, etc.

    ```sh
    sudo dpkg-reconfigure locales
    ```

    When prompted, select and set:  
    
    \- Locales to be generated: en* (all options starting with **en**).  
    \- Default locale for the system environment: en_US.UTF-8.  

    Set system defaults.

    ```sh
    sudo nano /etc/default/locale
    ```

    Clear pre-existing content, copy the block below and paste there.

    ```sh
    LANG=en_US.UTF-8
    LC_CTYPE=en_US.UTF-8
    LC_NUMERIC=en_US.UTF-8
    LC_TIME=en_DK.UTF-8
    LC_COLLATE=en_US.UTF-8
    LC_MONETARY=en_US.UTF-8
    LC_MESSAGES=en_US.UTF-8
    LC_PAPER=en_DK.UTF-8
    LC_NAME=en_US.UTF-8
    LC_ADDRESS=en_US.UTF-8
    LC_TELEPHONE=en_US.UTF-8
    LC_MEASUREMENT=en_DK.UTF-8
    LC_IDENTIFICATION=en_US.UTF-8
    ```

- Finishing up.

    ```sh
    sudo apt autoremove --purge
	test -f ~/.bash_history && rm ~/.bash_history
    sudo test -f /root/.bash_history && sudo rm /root/.bash_history
    sudo updatedb
    history -c
    sudo systemctl reboot
    ```
