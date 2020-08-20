#!/bin/bash
set -e


####################
#
# Editable variables
#
grub_timeout=5
isolinux_timeout=50
osfamily=CentOS
operatingsystemrelease=8-2-2004
architecture=x86_64
# hostname=server001
# domainname=localdomain.local
# source_build_dir='builds/CentOS-8-2-2004-x86_64-dvd'
#
# End of editable variables
#
####################


usage(){
	# echo "Usage: $0 -n HOSTNAME -d DOMAINNAME -s SOURCE_BUILD_DIR" 1>&2
  echo "Usage: $0 -n HOSTNAME -s SOURCE_BUILD_DIR" 1>&2
  exit 1
}

while getopts "n:s:" opt; do
  case $opt in
    n)
      hostname=$OPTARG
      ;;
    # d)
    #   domainname=$OPTARG
    #   ;;
    s)
      source_build_dir=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

# if [[ -z "${hostname}" ]] || [[ -z "${domainname}" ]] || [[ -z "${source_build_dir}" ]]; then
if [[ -z "${hostname}" ]] || [[ -z "${source_build_dir}" ]]; then
    usage
    exit 1
fi

# FQDN="${hostname}.${domainname}"
OUTPUT_ISO="${osfamily}-${operatingsystemrelease}-${architecture}_${hostname}.iso"
VOLUME_LABEL="${osfamily}-${operatingsystemrelease}-${architecture}"

# TODO: check for spaces in the volume label within isolinux.cfg and grub.cfg
# echo 'RHEL-7.3 x86_64' | sed -e 's/ /\\x20/g'
# echo 'RHEL-7.3\x20x86_64' | sed -e 's/\\x20/ /g'

# Generate ${source_build_dir}/isolinux/grub.conf from template
/bin/sed -e "s/{{ grub_timeout }}/${grub_timeout}/" \
    -e "s/{{ osfamily }}/${osfamily}/" \
    -e "s/{{ operatingsystemrelease }}/${operatingsystemrelease}/" \
    -e "s/{{ hostname }}/${hostname}/" \
    templates/boot/grub.conf > "${source_build_dir}/isolinux/grub.conf"

# Generate ${source_build_dir}/isolinux/isolinux.cfg from template- MBR boot
/bin/sed -e "s/{{ isolinux_timeout }}/${isolinux_timeout}/" \
    -e "s/{{ osfamily }}/${osfamily}/g" \
    -e "s/{{ operatingsystemrelease }}/${operatingsystemrelease}/g" \
    -e "s/{{ hostname }}/${hostname}/g" \
    -e "s/{{ architecture }}/${architecture}/g" \
    templates/boot/isolinux.cfg > "${source_build_dir}/isolinux/isolinux.cfg"

# Old command - note the sqash of colon (:) in the mac address
#/bin/sed -e "s/{{FQDN}}/${FQDN}/" \
#         -e "s/{{GATEWAY}}/${GATEWAY}/" \
#         -e "s/{{IPADDRESS}}/${IPADDRESS}/" \
#         -e "s/{{NETMASK}}/${NETMASK}/" \
#         -e "s/{{NAMESERVER}}/${NAMESERVER}/" \
#         -e "s/{{MACADDRESS}}/${MACADDRESS//:}/" \
#         -e "s/{{OS}}/${OS}/" \
#         "../../isolinux.${SUFFIX}" > "isolinux/isolinux.cfg"

# Generate ${source_build_dir}/EFI/BOOT/grub.cfg from template - UEFI boot
/bin/sed -e "s/{{ grub_timeout }}/${grub_timeout}/" \
    -e "s/{{ osfamily }}/${osfamily}/g" \
    -e "s/{{ operatingsystemrelease }}/${operatingsystemrelease}/g" \
    -e "s/{{ hostname }}/${hostname}/g" \
    -e "s/{{ architecture }}/${architecture}/g" \
    templates/boot/grub.cfg > "${source_build_dir}/EFI/BOOT/grub.cfg"

# Old command - note the sqash of colon (:) in the mac address
#/bin/sed -e "s/{{FQDN}}/${FQDN}/" \
#         -e "s/{{GATEWAY}}/${GATEWAY}/" \
#         -e "s/{{IPADDRESS}}/${IPADDRESS}/" \
#         -e "s/{{NETMASK}}/${NETMASK}/" \
#         -e "s/{{NAMESERVER}}/${NAMESERVER}/" \
#         -e "s/{{MACADDRESS}}/${MACADDRESS//:}/" \
#         -e "s/{{OS}}/${OS}/" \
#         "../../grub.${SUFFIX}" > "EFI/BOOT/grub.cfg"

# Add kickstart configuration file to the source build directory
cp "${hostname}-ks.cfg" "${source_build_dir}/${hostname}-ks.cfg"

# Create the bootable bootable installation iso image
cd ${source_build_dir} && /bin/mkisofs \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -o ../${OUTPUT_ISO} \
  -V "${VOLUME_LABEL}" \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e images/efiboot.img \
  -no-emul-boot \
  -R -J -l -v .

if [[ -f ../${OUTPUT_ISO} ]]; then
  # Enable UEFI
  isohybrid --uefi ../${OUTPUT_ISO}

  # Add MD5 signature
  implantisomd5 ../${OUTPUT_ISO}
else
  echo "Cannot find the .iso image."
  exit 1
fi
