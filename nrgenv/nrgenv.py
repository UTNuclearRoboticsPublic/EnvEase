#! /usr/bin/python3
############################################################################################
#      Copyright : Copyright© The University of Texas at Austin, 2022. All rights reserved.
#                
#          All files within this directory are subject to the following, unless an alternative
#          license is explicitly included within the text of each file.
#
#          This software and documentation constitute an unpublished work
#          and contain valuable trade secrets and proprietary information
#          belonging to the University. None of the foregoing material may be
#          copied or duplicated or disclosed without the express, written
#          permission of the University. THE UNIVERSITY EXPRESSLY DISCLAIMS ANY
#          AND ALL WARRANTIES CONCERNING THIS SOFTWARE AND DOCUMENTATION,
#          INCLUDING ANY WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#          PARTICULAR PURPOSE, AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY
#          THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF TRADE.
#          NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO THE USE OF
#          THE SOFTWARE OR DOCUMENTATION. Under no circumstances shall the
#          University be liable for incidental, special, indirect, direct or
#          consequential damages or loss of profits, interruption of business,
#          or related expenses which may arise from use of software or documentation,
#          including but not limited to those resulting from defects in software
#          and/or documentation, or loss or inaccuracy of data of any kind.
#
############################################################################################

import argparse
import argcomplete

import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from typing import List

env_dir = Path.home() / '.nrg_env'
configs_dir = env_dir / 'configs'

def create_parser() -> argparse.ArgumentParser:
  """ Parses the command line args. """
  parser = argparse.ArgumentParser(description="Manages NRG environment configurations.")

  # subcommands
  subparsers = parser.add_subparsers(title='subcommands')
  add_parser = subparsers.add_parser('add', help='Create a new config')
  modify_parser = subparsers.add_parser('modify', help='Modify an existing config')
  cp_parser = subparsers.add_parser('cp', help='Copy a config with a new name')
  rm_parser = subparsers.add_parser('rm', help='Remove a config')
  set_parser = subparsers.add_parser('set', help='Set the active config')
  clear_parser = subparsers.add_parser('clear', help='Delete all the stored configs')
  list_parser = subparsers.add_parser('list', help='List all the stored configs')
  show_parser = subparsers.add_parser('show', help='Show the active config')
  verbose_parser = subparsers.add_parser('verbose', help='Set the terminal verbosity.')

  # subcommand args
  add_parser.add_argument('target', type=str,
                          help='The name of the new environment configuration.')
  modify_parser.add_argument('target', type=str,
                          help='The name of the environment configuration to modify.').completer = configs_completer
  rm_parser.add_argument('target', type=str,
                          help='The name of the environment configuration to remove.').completer = configs_completer
  set_parser.add_argument('target', type=str,
                          help='The name of the environment configuration to activate.').completer = configs_completer
  cp_parser.add_argument('src', type=str,
                          help='The name of the environment configuration to copy from.').completer = configs_completer
  cp_parser.add_argument('dest', type=str,
                          help='The name of the new environment configuration.').completer = configs_completer
  verbose_parser.add_argument('on_off', type=str, choices=('on', 'off'),
                               help="Turns verbose mode 'on' or 'off'.")

  # set a callback function for each subcommand
  add_parser.set_defaults(func=add)
  rm_parser.set_defaults(func=rm)
  modify_parser.set_defaults(func=modify)
  set_parser.set_defaults(func=set)
  cp_parser.set_defaults(func=cp)
  clear_parser.set_defaults(func=clear)
  list_parser.set_defaults(func=list)
  show_parser.set_defaults(func=show)
  verbose_parser.set_defaults(func=verbose)

  return parser

def configs_completer(prefix: str, **_) -> List[str]:
  ''' Tab completion for the target and dest parameters  '''
  matches = configs_dir.glob(prefix + '*.sh')
  return [file.stem for file in matches]

def add(args: argparse.Namespace) -> int:
  src = Path('/opt/nuclearrobotics/config_template.sh')
  dest = configs_dir / (args.target + '.sh')

  if args.target == 'none':
    print("Error: Cannot name a config 'none' as this is reserved.")
    return 10

  if not src.exists():
    print('Error: Configuration template file is missing from expected location /opt/nuclearrobotics')
    return 10

  if dest.exists():
    print('Error: Configuration {} already exists.'.format(args.target))
    return 10

  try:
    shutil.copyfile(src, str(dest))
  except:
    print('Error: Failed to copy new configuration file from template.')
    return 10

  return modify(args)

def cp(args: argparse.Namespace) -> int:
  src = configs_dir / (args.src + '.sh')
  dest = configs_dir / (args.dest + '.sh')

  if src == dest:
    print('Error: Source and destination configuration names are the same.')
    return 10

  if not src.exists():
    print('Error: Configuration {} does not exist.'.format(args.src))
    return 10

  try:
    shutil.copyfile(str(src), str(dest))
  except:
    print('Error: Failed to copy configuration file.')
    return 10

  return 0

def rm(args: argparse.Namespace) -> int:
  dest = configs_dir / (args.target + '.sh')

  if not dest.exists():
    print('Error: Configuration {} does not exist.'.format(args.target))
    return 10
  
  try:
    dest.unlink()
  except:
    print('Error: Failed to remove configuration file.')
    return 10

  # if this was our active config, set the active config to 'none'
  if args.target == get_active_config():
    print("Warning: Deleted the active configuration. Setting configuration to 'none'.")
    clear_active_config()

  return 0

def modify(args: argparse.Namespace) -> int:
  dest = configs_dir / (args.target + '.sh')

  if not dest.exists():
    print('Error: Configuration {} does not exist.'.format(args.target))
    return 10

  try:
    subprocess.run(['xdg-open', str(dest)], check=True)
  except subprocess.CalledProcessError as err:
    print('Error: Default text editor exited with code ' + str(err.returncode))
    return 10
  except:
    print('Error: Failed to open default text editor.')
    return 10

  return 0

def list(_) -> int:
  p = configs_dir.glob('**/*')
  config_files = [x for x in p if x.is_file() and x.suffix == '.sh']

  for f in config_files:
    print(f.stem)

  if not config_files:
    print('No configurations')

  return 0

def show(_) -> int:

  active_config = get_active_config()

  if active_config == 'none':
    print('No environment currently set.')
  else:
    print(active_config)

  return 0

def get_active_config() -> str:
  return os.environ.get('NRG_ENV', 'none')

def clear(_) -> int:
  
  # iterate over files in configs directory
  config_files = Path(configs_dir).glob('*')
  for file in config_files:
    ns = argparse.Namespace()
    setattr(ns, 'target', file.stem)
    rm(ns)

  clear_active_config()

  return 0

def set(args: argparse.Namespace) -> int:
  config_file = configs_dir / (args.target + '.sh')

  if not config_file.exists() and args.target != 'none':
    print('Error: Configuration {} does not exist.'.format(args.target))
    return 10

  if not edit_metavariable_file('NRG_ENV', args.target):
    return 10

  print('Configuration set to {}. Be sure to source your bashrc file.'.format(args.target))

  return 0

def verbose(args: argparse.Namespace) -> int:

  remapper = {'on': 'true',
              'off': 'false'}

  if not edit_metavariable_file('NRG_VERBOSE', remapper[args.on_off]):
    return 10

  return 0

def clear_active_config() -> None:
  ''' Sets the active config to none  '''
  ns = argparse.Namespace()
  setattr(ns, 'target', 'none')
  set(ns)

def edit_metavariable_file(variable: str, value: str) -> bool:
  metavar_file = env_dir / 'cur_env.sh'

  # read in existing file contents
  try:
    with open(metavar_file, 'r') as f:
      filedata = f.read()
  except OSError as err:
    print('Failed to open cur_env.sh for editing. ' + err.strerror)
    return False

  # change the variable value
  filedata = set_variable_value(filedata, variable, value)

  # overwrite modified data back to file
  try:
    with open(metavar_file, 'w') as f:
      f.write(filedata)
  except OSError as err:
    print('Failed to write changes to cur_env.sh. ' + err.strerror)
    return False

  return True

def set_variable_value(contents: str, variable: str, value: str) -> str:
  if re.search('{}=.*'.format(variable), contents) == None:
    raise ValueError('Could not edit value of variable {} as the variable does not exist.')

  return re.sub('{}=.*'.format(variable),
                '{}={}'.format(variable, value),
                contents)

def main(args):
  # parse arguments
  parser = create_parser()
  argcomplete.autocomplete(parser)
  parsed_args = parser.parse_args(args)

  try:
    assert hasattr(parsed_args, 'func')
  except AssertionError:
    print('Program lacks a callback function to execute this command!')
    return 1

  # call the function associated with the given subcommand
  return parsed_args.func(parsed_args)

if __name__ == '__main__':
  result = main(sys.argv[1:])
  exit(result)