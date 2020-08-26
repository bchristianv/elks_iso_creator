#!/bin/env python3

import argparse
import jinja2 as j2
import subprocess
import yaml


def _parse_arguments():
    """Get command line arguments and retrieve Jinja template variables.

    - YAML formatted Jinja template variable file
    - Kickstart Jinja template name: from templates/kickstart directory
    - ISO image source directory
    """

    parser = argparse.ArgumentParser(description=
        'Create an Enterprise Linux kickstart ISO image')
    parser.add_argument('CONFIG',
        help='YAML formatted file containing Jinja template variables.')
    parser.add_argument('TEMPLATE',
        help='Kickstart Jinja template name.')
    parser.add_argument('SOURCE',
        help='Directory containing iso image source files.')
    parser.add_argument('-k', '--ks-dir', dest='ks_dir',
        help='Additional Kickstart templates directory to search.')
    args = parser.parse_args()

    with open(args.CONFIG, 'r') as yml:
        tmplt_vars = yaml.safe_load(yml)

    return tmplt_vars, args.TEMPLATE, args.SOURCE, args.ks_dir

def _write_file(j2_template, j2_vars, outfile):
    """Write a Jinja2 template to a file."""

    try:
        template = j2env.get_template(j2_template)
        template.stream(j2_vars).dump(outfile)
        # to stdout
        # print(template.render(j2_vars))
    except j2.exceptions.TemplateError as te:
        print(f"Could not load template: {template}.\n{te}")
        raise SystemExit()
    except FileNotFoundError as we:
        print(f"Could not write file: ./{outfile}.\n{we}")
        raise SystemExit()

def main():
    """Main program entrypoint."""

    template_vars, ks_template, source_dir, ks_dir = _parse_arguments()

    # Setup Jina2 environment
    j2_tmplt_dirs = ['./templates/boot', 'templates/kickstart']
    global j2env
    j2env = j2.Environment(loader=j2.FileSystemLoader(j2_tmplt_dirs))

    if ks_dir:
        j2env.loader.searchpath.append(ks_dir)

    # Write boot and kickstart files
    template_vars['kickstart_template'] = ks_template
    for t in (GRUB_CONF_J2, ISOLINUX_CFG_J2, GRUB_CFG_J2, ks_template):
        dest_file = f"{source_dir}/{t.strip('.j2')}"
        _write_file(t, template_vars, dest_file)

    # Create iso image
    outiso = (f"../{template_vars['hostname']}-{template_vars['osfamily']}-"
              + f"{template_vars['operatingsystemrelease']}-"
              + f"{template_vars['architecture']}.iso")
    volume_label = (f"{template_vars['osfamily']}-"
              + f"{template_vars['operatingsystemrelease']}-"
              + f"{template_vars['architecture']}")
    mkisofs_cmd = ['/bin/mkisofs', '-b', 'isolinux/isolinux.bin', '-c',
        'isolinux/boot.cat', '-o', outiso, '-V', volume_label, '-no-emul-boot',
        '-boot-load-size', '4', '-boot-info-table', '-eltorito-alt-boot', '-e',
        'images/efiboot.img', '-no-emul-boot', '-R', '-J', '-l', '-v', '.']
    subprocess.run(mkisofs_cmd, cwd=source_dir)

    # Enable UEFI boot and add MD5 signature to iso image
    subprocess.run(['/bin/isohybrid', '--uefi', outiso], cwd=source_dir)
    subprocess.run(['/bin/implantisomd5', outiso], cwd=source_dir)


if __name__ == "__main__":
    GRUB_CONF_J2 = 'isolinux/grub.conf.j2'
    ISOLINUX_CFG_J2 = 'isolinux/isolinux.cfg.j2'
    GRUB_CFG_J2 = 'EFI/BOOT/grub.cfg.j2'

    # Run main program 
    main()
