#!/bin/bash

set -ex

if [ -n "$KATEX" ]; then
  apt-get update
  # Ignore error if gpg-agent doesn't exist (for Ubuntu 16.04)
  apt-get install -y gpg-agent || :

  # Configure the NodeSource repo ourselves rather than piping their setup
  # script into a root shell; apt then verifies nodejs against the repo key.
  curl --retry 3 -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
  echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  # Keep NodeSource ahead of the distro nodejs, which is newer on noble.
  printf 'Package: nodejs\nPin: origin deb.nodesource.com\nPin-Priority: 600\n' | sudo tee /etc/apt/preferences.d/nodejs
  sudo apt-get update
  sudo apt-get install -y nodejs

  curl --retry 3 -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  apt-get update
  apt-get install -y --no-install-recommends yarn
  yarn global add katex --prefix /usr/local

  sudo apt-get -y install doxygen lcov

  apt-get autoclean && apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

fi
