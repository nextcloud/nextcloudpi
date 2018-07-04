# Installation instructions for NextCloudPi on BerryBoot

### Items Required:

- Linux System with USB Ports (optional SD Card Slot)
- micro SD Card with SD Adapter (with USB adapter if system doesn’t have SD Slot)
- USB Flash Drive
- Raspberry Pi connected to a video screen (usually HDMI)


### Notes:

- The Flash Drive and the SD card must be 32GB or less
- FAT32 file system is limited to 32GB
- The Berryboot application is a GUI. So, it must be used with an HDMI TV/Monitor
- Do NOT untar the berryboot files from berryterminal until they are on the SD Card



### Creating and copying NextCloudPi image to the USB Flash Drive:

1. On a Linux System copy the following files (latest):
    - ‘build-SD-berryboot.sh’ script
    - ‘buildlib.sh’ script
    - ‘NextCloudPi_Rpi_xx-xx-xx.tar.bz2’ (xx-xx-xx = mm-dd-yy)
1. Install squashfs-tools if it is not installed
1. Unzip, then Untar the ‘NextCloudPi_Rpi_xx-xx-xx.tar.bz2’ file
1. Run ‘build-SD-berryboot.sh NextCloudPi_Rpi_xx-xx-xx.tar.bz2’
1. Copy ‘NextCloudPi_Rpi_Berryboot_xx-xx-xx.img’ to the USB Flash Drive
1. Eject the USB Flash Drive

### Install BerryBoot on micro SD Card (Only needs to be performed once):<br>
<b>Note:</b> Refer to [https://www.berryterminal.com/doku.php/berryboot](URL)

1. Download the proper Berryboot zip file for your Raspberry Pi from the website listed above
1. Put the SD Card in your Linux System
1. Wait for the SD Card to mount
1. Verify that it is a FAT32 file system using ‘mount’ (should have ‘type vfat’ for SD)
1. Copy the Berryboot zip to the SD Card
1. CD to the SD Card
1. Unzip the Berryboot zip file
1. Remove the zip file (if you don’t the Raspberry Pi will error on boot)
1. CD to an alternate directory as to unmount the SD Card
1. ‘umount’ (or eject) the SD Card
1. Put the SD Card in your Raspberry Pi.
1. Start your Pi with a Keyboard and a Mouse connected
1. Wait for the ‘Welcome’ screen to appear (Berryboot installer):
    - Set Video
    - Set Network Connection
    - If network settings is correct, the proper Locale settings should be made. If not, select the proper Locale settings.
1. If you selected a ‘Wireless’ connection:
    - Select Wireless Connection to use
    - Provide password if needed
    - Select ‘Ok’
1. ‘Select destination drive’ screen:
    - Select the SD Card (usually starts with mmc)
    - Select File system (usually ext4)
    - Click ‘Format’
1. It will now Re-partition the Berryboot SD Card and format it
1. Select cancel on the ‘Add OS’ screen
1. Wait for the Raspberry Pi to reboot after selecting “Ok” for reboot
1. If the USB Flash Drive is already connected to a USB Port, continue to ‘Install the NextCloudPi on the SD Card’


### Install the NextCloudPi on the SD Card:

1. Connect the USB Flash Drive (with ‘NextCloudPi_Rpi_Berryboot_xx-xx-xx.img’) to the Pi
1. Install the Berryboot SD Card from above
1. Power on the Pi if it is off
1. Wait for the ‘BerryBoot menu editor’ screen to display
1. Click & HOLD the ‘Add OS’ button
1. Select ‘Copy OS from USB stick’
1. The ‘Select image file’ should be displayed
1. Select the OS image to add to the SD Card it should be: <b>‘NextCloudPi_Rpi_Berryboot_xx-xx-xx.img’</b>
1. Click on ‘Open’
1. Wait for it to copy the image to the micro SD Card
1. To make it the default image to boot, select it and click on ‘Set Default’
1. Click on ‘Exit’
1. The Pi should reboot
1. Start configuring and using your new NextCloudPi image...
