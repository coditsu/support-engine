#!/bin/bash

PLATFORM=$(uname);

echo $PLATFORM;

install ()
{
    echo "=> Installing / upgrading git-extras"
    echo "-----------------------";
    if [ $PLATFORM == "Linux" ]; then
        # remove if we have git-extras from system, it is probably outdated
        if [ ! -z "$(dpkg -l|grep git-extras)" ]; then
            sudo apt-get remove --purge git-extras;
        fi
    curl -sSL http://git.io/git-extras-setup | sudo bash /dev/stdin;
    elif [ $PLATFORM == "Darwin" ]; then
        if [ -z "$(brew list|grep git-extras)" ]; then
            brew install git-extras;
        else
            brew upgrade --cleanup git-extras;
        fi
    fi
    echo "+++++++++++++++++++++++";
}

echo "=> Your platform is $PLATFORM";
echo
install;
