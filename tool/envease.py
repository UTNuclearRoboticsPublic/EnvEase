#! /usr/bin/python3
############################################################################################
# Copyright : Copyright© The University of Texas at Austin, 2023. All rights reserved.
#                
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of python-odmltables nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

env_dir = Path.home() / '.envease'
configs_dir = env_dir / 'configs'

def create_parser() -> argparse.ArgumentParser:
  """ Parses the command line args. """
  parser = argparse.ArgumentParser(description="Manages environment configurations for ROS software development.")

  # subcommands
  subparsers = parser.add_subparsers(title='subcommands', dest='cmd')
  subparsers.required = True
  add_parser = subparsers.add_parser('add', help='Create a new config')
  modify_parser = subparsers.add_parser('modify', help='Modify an existing config')
  cp_parser = subparsers.add_parser('cp', help='Copy a config with a new name')
  rm_parser = subparsers.add_parser('rm', help='Remove a config')
  rename_parser = subparsers.add_parser('rename', help='Rename a config')
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
  rename_parser.add_argument('target', type=str,
                              help='The name of the environment configuration to rename.').completer = configs_completer
  rename_parser.add_argument('dest', type=str,
                              help='The new name.').completer = configs_completer
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
  rename_parser.set_defaults(func=rename)
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
  src = Path('/opt/EnvEase/config_template.sh')
  dest = configs_dir / (args.target + '.sh')

  if args.target == 'none':
    print("Error: Cannot name a config 'none' as this is reserved.")
    return 10

  if not src.exists():
    print('Error: Configuration template file is missing from expected location /opt/EnvEase')
    return 10

  if dest.exists():
    print('Error: Configuration {} already exists.'.format(args.target))
    return 10

  try:
    shutil.copyfile(src, str(dest))
  except OSError as err:
    print('Error: Failed to copy new configuration file from template.')
    print(err.strerror)
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

def rename(args: argparse.Namespace) -> int:
  target = configs_dir / (args.target + '.sh')
  dest = configs_dir / (args.dest + '.sh')

  if target == dest:
    print('Error: Original and new names are the same. No operation performed.')
    return

  if not target.exists():
    print('Error: Configuration {} does not exist.'.format(args.target))
    return 10

  if dest.exists():
    print('Error: Configuration {} already exists.'.format(args.dest))
    return 10

  try:
    os.rename(target, dest)
  except OSError as error:
    print('Error: Failed to rename configuration file.')
    print(error.strerror)
    return 10

  # if this was our active config, update the variable
  if args.target == get_active_config():
    print('Warning: The active configuration was renamed.')
    ns = argparse.Namespace()
    setattr(ns, 'target', args.dest)
    return set(ns)

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
  return os.environ.get('ENVEASE_ENV', 'none')

def clear(_) -> int:

  # get user confirmation
  confirm = input("Are you sure you want to delete all your configuration profiles? Type 'yes' to confirm: ")

  if confirm != 'yes':
    return 0
  
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

  if not edit_metavariable_file('ENVEASE_ENV', args.target):
    return 10

  print('Configuration set to {}. Be sure to source your bashrc file.'.format(args.target))

  return 0

def verbose(args: argparse.Namespace) -> int:

  remapper = {'on': 'true',
              'off': 'false'}

  if not edit_metavariable_file('ENVEASE_VERBOSE', remapper[args.on_off]):
    return 10

  return 0

def clear_active_config() -> None:
  ''' Sets the active config to none  '''
  ns = argparse.Namespace()
  setattr(ns, 'target', 'none')
  return set(ns)

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

  if not hasattr(parsed_args, 'func'):
    print('Program lacks a callback function to execute this command!')
    return 1

  # call the function associated with the given subcommand
  return parsed_args.func(parsed_args)

if __name__ == '__main__':
  result = main(sys.argv[1:])
  exit(result)