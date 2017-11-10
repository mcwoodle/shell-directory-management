#!/bin/sh
#
# Quick Directory Aliases
#
# Copyright 2011-2017 Matt Woodley
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# NOTE: will be sourced by interactive shell and will affect the caller's context, do not exit!

_d_mapFile=~/.dmap

touch "$_d_mapFile"

_d_usage()
{
    printf "usage: d [+|-] [alias]\n" >&2
    printf "\n" >&2
    printf "Add:      d + aliasName\n" >&2
    printf "Remove:   d - aliasName\n" >&2
    printf "Navigate: d aliasName\n" >&2
    printf "List all: d\n" >&2
    printf "\n" >&2
    printf "Version: 1.2\n" >&2
    printf "\n" >&2
    printf "Full README: https://github.com/mcwoodle/shell-directory-management/blob/master/README.md\n" >&2
}

# ensure there isn't an alias set with the same name.
unalias d 2>/dev/null
if [ "$?" -eq "0" ]
then
    printf "Existing alias 'd' was removed while setting up quick directory function d()\n"
    printf "You may want to clear the contents of ~/.dmap if you were using a previous version of this script\n"
fi

d()
{
    _d_curDir=`pwd`
    _d_addDir=false
    _d_removeDir=false
    _d_aliasName=
    _d_finished=false # an awkward workaround for not calling exit

    # Check for args length
    if [ "$#" -eq "0" ]
    then
        cat $_d_mapFile
        return 0
    elif [ "$#" -gt "2" ]
    then
        _d_usage
        return 1
    fi

    # Handle arguments
    while [ "$#" -gt "0" ]
    do
        case "$1" in
            +) _d_addDir=true;;
            -) _d_removeDir=true;;
            -h) _d_usage; return 0;;
            -*) _d_usage; return 1;;
            *) _d_aliasName=$1; break;;	# terminate while loop
        esac
        shift
    done

    if [ -z "$_d_aliasName" ]
    then
        _d_usage
        return 1
    fi

    _d_aliasRow=`grep "^$_d_aliasName = " $_d_mapFile`

    if $_d_addDir;
    then
        if [ -z "$_d_aliasRow" ]
        then
            #Write the new alias to our map file
            printf "$_d_aliasName = $_d_curDir\n" >> $_d_mapFile
            return $?
        else
            printf "The map alias $_d_aliasName already exists:\n$_d_aliasRow\n"
            return 1
        fi
    fi

    if [ -z "$_d_aliasRow" ]
    then
        printf "The alias '$_d_aliasName' does not exist\n"
        return 1
    fi

    if $_d_removeDir;
    then
        sed -i -e "/^$_d_aliasName = .*/d" $_d_mapFile
        if [ "$?" -eq "0" ]
        then
            printf "$_d_aliasName successfully removed\n"
            return $?
        else
            printf "Error removing $_d_aliasName\n"
            return 1
        fi
    fi

    # Actually change the directory.
    _d_cmd=`printf "$_d_aliasRow" | sed -e "s,.* = \(.*\),\1,"`
    printf "cd $_d_cmd\n"
    cd "$_d_cmd"
    return $?
}


######################
# Autocomplete Setup #
######################

# Inspiration for the zsh/bash autocomplete impl from:
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html

# For zsh, test if the compctl command exists.
if type compctl >/dev/null 2>&1
then
    _d_setupAutoComplete_zsh()
    {
        # Note: Use eval to avoid breaking 'sh' posix or shells
        eval "reply=($(sed -e 's/\(.*\) = .*/\1/' $_d_mapFile))"
        return 0
    }
    compctl -K _d_setupAutoComplete_zsh d >/dev/null 2>&1
fi

# For bash, test if the compgen/complete commands exists
if type compgen >/dev/null 2>&1
then
    _d_setupAutoComplete_bash()
    {
        local curw=${COMP_WORDS[COMP_CWORD]}
        local wordlist=$(sed -e "s/\(^.*\) = .*/\1/" $_d_mapFile)
        # Note: Use eval to avoid breaking 'sh' posix or shells
        eval "COMPREPLY=($(compgen -W "$wordlist" -- "$curw"))"
        return 0
    }

    complete -F _d_setupAutoComplete_bash d >/dev/null 2>&1
fi

