#!/bin/bash

PLATFORM=$(uname);

echo $PLATFORM;

install () 
{
    echo "=> Installing / upgrading yarn"
    echo "-----------------------";
    if [ $PLATFORM == "Linux" ]; then
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -;
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
        if [ -z "$(dpkg -l|grep yarn)" ]; then
            apt-get update && apt-get install yarn;
        else
            apt-get upgrade yarn;
        fi
    elif [ $PLATFORM == "Darwin" ]; then
        if [ -z "$(brew list|grep yarn)" ]; then
            brew install yarn;
        else
            brew upgrade --cleanup yarn;
        fi
    fi
    echo "+++++++++++++++++++++++";
}

echo "=> Your platform is $PLATFORM";
echo
install;
