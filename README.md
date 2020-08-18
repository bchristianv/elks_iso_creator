# el_ks_iso_builder
Custom .ISO install disk builder that performs a network kickstart installation of a base Enterprise Linux OS

Choose an Enterprise Linux installation ISO image, depending on source
installation preference - media or network.


```
$ sudo mount ${osfamily}-${operatingsystemrelease}-${architecture}.iso ${mount_dir}
$ mkdir ${source_build_dir}
$ sudo cp -aRv ${mount_dir}/. ${source_build_dir}
$ sudo chown -R ${user}:${group} ${source_build_dir}
$ sudo umount ${mount_dir}
```

Template variables:

``grub_timeout = 5``

``isolinux_timeout = 50``

``osfamily``

``operatingsystemrelease``

``hostname``

``architecture``

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
    templates/grub.conf > ${source_build_dir}/isolinux/grub.conf
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
    templates/isolinux.cfg > ${source_build_dir}/isolinux/isolinux.cfg
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
    templates/grub.cfg > ${source_build_dir}/EFI/BOOT/grub.cfg
```

Add kickstart configuration file to the root of the `${source_build_dir}` as:

```
${source_build_dir}/ks-${hostname}.cfg
```

Create the new boot ISO

Enable UEFI

Add MD5 signature
