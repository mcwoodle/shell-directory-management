# Quick Directory Aliases

## What it does

Enables quick directory aliases and navigation. Allows for easy and consistent navigation between disparate directories.

## How you use it

#### Add alias
```bash
% cd /any/really/long/or/short/directory/path/thats/hardoreasy/to/remember
% d + shortAliasName
```
> Note: changes take effect immediately across terminals/shells.

#### Navigate to an alias
```bash
% d shortAliasName

% pwd
/any/really/long/or/short/directory/path/thats/hardoreasy/to/remember
```

#### Remove alias
```bash
% d - shortAliasName
```

#### See all aliases
```bash
% d
workspace = /home/mcwoodle/workspaces/someWorkspaceDirectory
```


## How to install

1. Copy the file `quick-directory-aliases.sh` to a local directory (Download [here](https://raw.githubusercontent.com/mcwoodle/shell-directory-management/master/quick-directory-aliases.sh) - right click, save as...)
   > Lets call this directory YOUR_LOCAL_DIRECTORY_PATH
1. Add the following alias to your shell's rc file, or wherever you put your aliases:

    ```bash
    alias d='. <YOUR_LOCAL_DIRECTORY_PATH>/quick-directory-aliases.sh'
    ```
    > Dont forget the `.`; sourcing this script here is crucial to its functionality
1. Ready for use.

> Note that this uses standard sh and will work on any POSIX compliant system. To date, it's been used on macOS, RHEL5, Ubuntu, and Bash on Ubuntu on Windows.


## Implementation Details
* The script is sourced into your current working shell, allowing it to issue change directory commands within your shell.
* It creates and uses a `~/.dmap` file to store a map of aliases to directories.

