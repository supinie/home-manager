#! /bin/bash

if [[ -s .gitignore ]]; then
    echo -e "gitignore already exists. Exiting..."
    exit 1
elif ! [[ -d .git ]] && [[ "$1" != "-f" ]]; then
    echo -e "It does not look like you are in the root of a git repository. Exiting..."
    exit 1
fi

if [[ "$1" == "" ]]; then
    echo -e "No inputs given. Exiting..."
    exit 1
else
    LANGUAGE="$1"
fi

cp $HOME/.config/home-manager/gitignore/$LANGUAGE .gitignore
