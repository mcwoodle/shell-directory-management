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

_d_usage()
{
    printf "usage: d [+|-] [alias]\n" >&2
    printf "\n" >&2
    printf "Add:      d + aliasName\n" >&2
    printf "Remove:   d - aliasName\n" >&2
    printf "Navigate: d aliasName\n" >&2
    printf "List all: d\n" >&2
    printf "\n" >&2
    printf "Version: 1.1\n" >&2
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
    mapFile=~/.dmap

    touch "$mapFile"

    done=false
    curDir=`pwd`
    addDir=false
    removeDir=false
    aliasName=
    finished=false # an awkward workaround for not calling exit

    if [ "$#" -eq "0" ]
    then
        cat $mapFile
    elif [ "$#" -gt "2" ]
    then
        _d_usage
    else

        while [ "$#" -gt "0" ]
        do
            case "$1" in
                +) addDir=true;;
                -) removeDir=true;;
                -h) finished=true;;
                -*) finished=true;;
                *) aliasName=$1; break;;	# terminate while loop
            esac
            shift
        done

        if $finished;
        then
            _d_usage
        elif [ -z "$aliasName" ]
        then
            _d_usage
        else
            aliasRow=`grep "^$aliasName = " $mapFile`
            if $addDir;
            then
                if [ -z "$aliasRow" ]
                then
                    #Write the new alias to our map file
                    printf "$aliasName = $curDir\n" >> $mapFile
                else
                    printf "The map alias $aliasName already exists:\n$aliasRow\n"
                fi
            else
                if [ -z "$aliasRow" ]
                then
                    printf "The alias '$aliasName' does not exist\n"
                elif $removeDir;
                then
                    sed -i -e "/^$aliasName = .*/d" $mapFile
                    if [ "$?" -eq "0" ]
                    then
                        printf "$aliasName successfully removed\n"
                    else
                        printf "Error removing $aliasName\n"
                    fi
                else
                    cmd=`printf "$aliasRow" | sed -e "s,.* = \(.*\),\1,"`
                    cd $cmd
                    printf "cd $cmd\n"
                fi
            fi
        fi
    fi
}

