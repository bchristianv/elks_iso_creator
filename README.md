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

Install required python modules by running:

```
pip install -r requirements.txt
```

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
See the example files, `example.yaml` (configuration variables) and `templates/anaconda-ks.cfg.j2` (Jinja template), for information on required and optional template variables.

For usage and command arguments run:

```
elks_iso_creator.py -h
```


#### Ref: 
- https://access.redhat.com/solutions/60959
