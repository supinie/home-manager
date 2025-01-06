#! /bin/bash

if [[ -s ./shell.nix ]] || [[ -s ./envrc ]]; then
    echo -e "shell.nix or envrc already present.\nEither you should not be running this command, or you need to clean up this environment first."
    exit 1
elif ! [[ -d .git ]] && [[ "$1" != "-f" ]]; then
    echo -e "It does not look like you are in the root of a git repository.\nAre you sure you want to proceed?\nUse -f to override."
    exit 1
fi

if [[ "$1" == "-f" ]]; then
    shift
fi

if [[ "$@" == "" ]]; then
    echo -e "No inputs given. Exiting..."
    exit 1
elif [[ "$@" == "rust" ]]; then 
    BUILDINPUTS="rustup gcc bacon"
elif [[ "$@" == "python" ]]; then
    BUILDINPUTS="gcc python3 sage"
elif [[ "$@" == "fplll" ]]; then
    BUILDINPUTS="gcc python3 sage python312Packages.fpylll fplll"
elif [[ "$@" == "tex" ]]; then
    BUILDINPUTS="texliveFull texlivePackages.beamer"
else
    BUILDINPUTS="$@"
fi
echo -e "with import <nixpkgs> {};\nmkShell {\n    buildInputs = [ $BUILDINPUTS ];\n}" >> "shell.nix"

echo "use nix" >> .envrc
direnv allow
