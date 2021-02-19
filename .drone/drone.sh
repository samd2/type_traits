#!/bin/bash

# Copyright 2020 Rene Rivera, Sam Darwin
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.txt or copy at http://boost.org/LICENSE_1_0.txt)

set -e
set -x
export TRAVIS_BUILD_DIR=$(pwd)
export DRONE_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export TRAVIS_EVENT_TYPE=$DRONE_BUILD_EVENT
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export REPO_NAME=$DRONE_REPO
export USER=$(whoami)
export CC=${CC:-gcc}
export PATH=~/.local/bin:/usr/local/bin:$PATH

if [ "$DRONE_JOB_BUILDTYPE" == "boost" ]; then

echo '==================================> INSTALL'

cd ..
git clone -b $TRAVIS_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init tools/build
git submodule update --init tools/boost_install
git submodule update --init libs/headers
git submodule update --init libs/config
git submodule update --init libs/assert
git submodule update --init libs/bind
git submodule update --init libs/core
git submodule update --init libs/detail
git submodule update --init libs/function
git submodule update --init libs/integer
git submodule update --init libs/move
git submodule update --init libs/mpl
git submodule update --init libs/preprocessor
git submodule update --init libs/static_assert
git submodule update --init libs/throw_exception
git submodule update --init libs/type_index
git submodule update --init libs/utility
cp -r $TRAVIS_BUILD_DIR/* libs/type_traits
./bootstrap.sh
./b2 headers

echo '==================================> SCRIPT'

echo "using $TOOLSET : : $COMPILER ;" > ~/user-config.jam
IFS=','
for CXXLOCAL in $CXXSTD; do  (cd libs/config/test && ../../../b2 config_info_travis_install toolset=$TOOLSET cxxstd=$CXXLOCAL $CXXSTD_DIALECT && echo With Standard Version $CXXLOCAL && ./config_info_travis && rm ./config_info_travis)  done
unset IFS
./b2 -j3 libs/type_traits/test toolset=$TOOLSET cxxstd=$CXXSTD $CXXSTD_DIALECT

fi
