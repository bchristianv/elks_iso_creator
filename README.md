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


`` ipaddress``

`` netmask``

`` gateway``

`` macaddress``

`` nameserver``

From template generate ``${source_build_dir}/isolinux/grub.conf``

From template generate ``${source_build_dir}/isolinux/isolinux.cfg`` - MBR boot

From template generate ``${source_build_dir}/EFI/BOOT/grub.cfg`` - UEFI boot

Add kickstart configuration file to the root of the ``${source_build_dir}`` as:
```
${source_build_dir}/ks-${hostname}.cfg
```

Create the new boot ISO
Enable UEFI
Add MD5 signature
