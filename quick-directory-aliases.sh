#!/bin/sh
#
# Quick Directory Aliases
#
# Copyright 2011 Matt Woodley
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

#NOTE: will be sourced by interactive shell, do not exit!

mapFile=~/.dmap

touch "$mapFile"

done=false
curDir=`pwd`
addDir=false
removeDir=false
aliasName=
finished=false

function usage()
{
    echo "usage: d [+|-] [alias]" >&2
    echo ""
    echo "Add:      d + aliasName"
    echo "Remove:   d - aliasName"
    echo "Navigate: d aliasName"
    echo "List all: d"
    echo ""
    echo "Full README: https://tiny.amazon.com/zb62swhm/README"
}

if [ $# -eq 0 ]
then
    sed -e "s/alias DIR_\(.*\)=\"cd \(.*\)\"/\1 = \2/" < $mapFile
elif [ $# -gt 2 ]
then
    usage
else

    while [ $# -gt 0 ]
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
        usage
    elif [ -z "$aliasName" ]
    then
        usage
    else

#        echo "Commands are $addDir $removeDir $aliasName $curDir"

        if $addDir;
        then
            grep "alias DIR_$aliasName=" < $mapFile > /dev/null
            if [ $? -eq 0 ]
            then
                echo "The map alias $aliasName already exists"
            else
                #Write the new alias to our map file
                echo "alias DIR_$aliasName=\"cd $curDir\"" >> $mapFile

                #Update the current env
                alias DIR_$aliasName="cd $curDir"
            fi

        elif $removeDir;
        then
            sed -i -e "/alias DIR_$aliasName=.*/d" $mapFile
            if [ $? -eq 0 ]
            then
                echo "$aliasName successfully removed"
            else
                echo "$aliasName not found" #won't get run, sed always true
            fi
        else
           grep "alias DIR_$aliasName=" < $mapFile > /dev/null
           if [ $? -eq 1 ]
           then
               echo "The map alias $aliasName not found"
           else
               . ~/.dmap
               aliasCmd=`alias DIR_$aliasName`
               cmd=`echo $aliasCmd | sed "s/alias DIR_.*='\(.*\)'/\1/"`
               $cmd
               echo $cmd
           fi
        fi
     fi
 fi

