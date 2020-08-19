# EL Kickstart ISO Builder
An all-in-one Enterprise Linux installation iso image builder that performs a kickstart installation.

## PURPOSE
Create an Master Boot Record (MBR) and Unified Extensible Firmware Interface (UEFI) compatible CentOS or Red Hat Enterprise Linux installation iso image that:
- contains a bootable installation image - network or complete package index depending on source installation media
- includes a user supplied kickstart configuration file
- automatically initiates the kickstart installation after a configurable timeout period 

## REQUIREMENTS
- genisoimage
- syslinux
- isomd5sum

## USAGE
Choose an Enterprise Linux installation ISO image, depending on source installation preference - media or network.

Copy all of the files from an existing Enterprise Linux installation image to a build directory. 

```
$ sudo mount ${osfamily}-${operatingsystemrelease}-${architecture}.iso ${mount_dir}
$ mkdir ${source_build_dir}
$ sudo cp -aRv ${mount_dir}/. ${source_build_dir}
$ sudo chown -R ${user}:${group} ${source_build_dir}
$ sudo chmod u+w ${source_build_dir}
$ sudo umount ${mount_dir}
```

Template variables:

``grub_timeout = 5``

``isolinux_timeout = 50``

``osfamily``

``operatingsystemrelease``

``architecture``

``hostname``

``ipaddress``

``netmask``

``gateway``

``macaddress``

``nameserver``


From template generate ``${source_build_dir}/isolinux/grub.conf``

```
grub_timeout=5
osfamily=CentOS
operatingsystemrelease=8-2-2004
hostname=ks-test001
source_build_dir=CentOS-8-2-2004-x86_64-dvd

/bin/sed -e "s/{{ grub_timeout }}/${grub_timeout}/" \
    -e "s/{{ osfamily }}/${osfamily}/" \
    -e "s/{{ operatingsystemrelease }}/${operatingsystemrelease}/" \
    -e "s/{{ hostname }}/${hostname}/" \
    templates/boot/grub.conf > ${source_build_dir}/isolinux/grub.conf
```

From template generate ``${source_build_dir}/isolinux/isolinux.cfg`` - MBR boot

```
isolinux_timeout=50
osfamily=CentOS
operatingsystemrelease=8-2-2004
hostname=ks-test001
architecture=x86_64
source_build_dir=CentOS-8-2-2004-x86_64-dvd

/bin/sed -e "s/{{ isolinux_timeout }}/${isolinux_timeout}/" \
    -e "s/{{ osfamily }}/${osfamily}/g" \
    -e "s/{{ operatingsystemrelease }}/${operatingsystemrelease}/g" \
    -e "s/{{ hostname }}/${hostname}/g" \
    -e "s/{{ architecture }}/${architecture}/g" \
    templates/boot/isolinux.cfg > ${source_build_dir}/isolinux/isolinux.cfg
```

From template generate ``${source_build_dir}/EFI/BOOT/grub.cfg`` - UEFI boot

```
grub_timeout=5
osfamily=CentOS
operatingsystemrelease=8-2-2004
hostname=ks-test001
architecture=x86_64
source_build_dir=CentOS-8-2-2004-x86_64-dvd

/bin/sed -e "s/{{ grub_timeout }}/${grub_timeout}/" \
    -e "s/{{ osfamily }}/${osfamily}/g" \
    -e "s/{{ operatingsystemrelease }}/${operatingsystemrelease}/g" \
    -e "s/{{ hostname }}/${hostname}/g" \
    -e "s/{{ architecture }}/${architecture}/g" \
    templates/boot/grub.cfg > ${source_build_dir}/EFI/BOOT/grub.cfg
```

Add kickstart configuration file to the root of the build directory:

```
hostname=ks-test001
source_build_dir=CentOS-8-2-2004-x86_64-dvd

${source_build_dir}/ks-${hostname}.cfg
```

Create the new boot ISO image

```
osfamily=CentOS
operatingsystemrelease=8-2-2004
hostname=ks-test001
architecture=x86_64
OUTPUT_ISO=${osfamily}-${operatingsystemrelease}-${architecture}_${hostname}.iso
VOLUME_LABEL=${osfamily}-${operatingsystemrelease}-${architecture}

cd ${source_build_dir}
/bin/mkisofs \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -o ../${OUTPUT_ISO} \
  -V "${VOLUME_LABEL}" \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e images/efiboot.img \
  -no-emul-boot \
  -R -J -l -v .
```

Enable UEFI

```
osfamily=CentOS
operatingsystemrelease=8-2-2004
hostname=ks-test001
architecture=x86_64
OUTPUT_ISO=${osfamily}-${operatingsystemrelease}-${architecture}_${hostname}.iso

isohybrid --uefi ../${OUTPUT_ISO}
```

Add MD5 signature

```
osfamily=CentOS
operatingsystemrelease=8-2-2004
hostname=ks-test001
architecture=x86_64
OUTPUT_ISO=${osfamily}-${operatingsystemrelease}-${architecture}_${hostname}.iso

implantisomd5 ../${OUTPUT_ISO}
```

#### Ref: 
- https://access.redhat.com/solutions/60959
