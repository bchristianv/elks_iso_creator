#!/bin/env python3

import argparse
import json
import jinja2 as j2
import yaml


def _parse_arguments():
    """Get command line arguments and retrieve Jinja template variables."""

    parser = argparse.ArgumentParser(description='Render Jinja2 template')
    parser.add_argument('CONFIG',
        help='YAML formatted file containing Jinja template variables.')
    parser.add_argument('TEMPLATE', help='Jinja template name.')
    parser.add_argument('-t', '--template-dir', dest='template_dir',
        help='Additional templates directory to search.')
    parser.add_argument('-d', '--debug', default=False, action='store_true',
        help='Enable verbose output.')
    args = parser.parse_args()

    with open(args.CONFIG, 'r') as yml:
        tmplt_vars = yaml.safe_load(yml)

    return tmplt_vars, args.TEMPLATE, args.template_dir, args.debug

def main():
    """Main program entrypoint."""

    template_vars, j2_template, template_dir, debug_enabled = _parse_arguments()

    # Setup Jina2 environment
    j2_tmplt_dirs = ['./templates/boot', 'templates/kickstart']
    j2env = j2.Environment(loader=j2.FileSystemLoader(j2_tmplt_dirs))

    if template_dir:
        j2env.loader.searchpath.append(template_dir)
    
    if debug_enabled:
        print("\nTemplates available:")
        for t in j2env.list_templates():
            print(f"    {t}")
        print(f"\nTemplate selected:\n    {j2_template}\n")
        print(f"\nTemplate variables:\n{json.dumps(template_vars, indent=4)}\n")

    # Render template to stdout
    try:
        template = j2env.get_template(j2_template)
        print(template.render(template_vars))
    except j2.exceptions.TemplateError as te:
        print(f"Could not load template: {template}.\n{te}")
        raise SystemExit()


if __name__ == "__main__":
    # Run main program 
    main()
