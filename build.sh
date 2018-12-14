#!/bin/bash

set -e # stop on first error

missing=""

type g++      ||  missing="g++"
type automake ||  missing="${missing} automake"
type make     ||  missing="${missing} make"
type curl     ||  missing="${missing} curl"

[ -z "$missing" ] || { echo "sudo apt-get install $missing" ; exit ; }

# create some directories if missing

[ -d bin ] || mkdir bin 
[ -d lib ] || mkdir lib
[ -d src/external ] || mkdir src/external 


#===[ PTYPES ]===========================================================================

if [ ! -d src/external/ptypes-2.1.1 ]; then
  if [ ! -f src/external/ptypes-2.1.1.tar.gz ]; then
    pushd src/external/
      curl http://tehsausage.com/ptypes/ptypes-2.1.1.tar.gz -o ptypes-2.1.1.tar.gz
    popd
  fi
  pushd src/external/
    tar xfz ptypes-2.1.1.tar.gz
    # tests wont compile 
    sed -i -e '/^all:/ s/ptypes_test// ; s/ptypesn_test//'  ptypes-2.1.1/src/Makefile.common
  popd
fi

if [ -f lib/libptypes.so.21 ]; then
  echo "libptypes.so.21 found in lib directory"
else
  pushd src/external/ptypes-2.1.1/
    make
  popd
  cp src/external/ptypes-2.1.1/so/libptypes.so.21 lib/
  pushd lib
    ln -s libptypes.so.21 libptypes.so
  popd
fi

if [ ! -h src/spotiload/ptypes ]; then
  pushd src/spotiload
    ln -s ../external/ptypes-2.1.1/include ptypes
  popd
fi


#===[ LAME ]=============================================================================


if [ -f lib/libmp3lame.so ]; then
  echo "libmp3lame.so found in lib directory"
else
  if [ ! -f src/external/lame-3.100.tar.gz ] ; then
    pushd src/external
      wget https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz/download -O lame-3.100.tar.gz
    popd
  fi
  if [ ! -d src/external/lame-3.100 ];then
    pushd src/external
      tar xfz lame-3.100.tar.gz
    popd
  fi
  pushd src/external/lame-3.100
    chmod +x configure
    ./configure
    make
  popd

  cp src/external/lame-3.100/libmp3lame/.libs/libmp3lame.so.0.0.0 lib/
  pushd lib
    ln -s libmp3lame.so.0.0.0 libmp3lame.so	
    ln -s libmp3lame.so.0.0.0 libmp3lame.so.0
  popd
fi

if [ ! -h src/spotiload/lame ]; then
  pushd src/spotiload
    ln -s ../external/lame-3.100/include lame
  popd
fi


#===[ LIBSPOTIFY ]=======================================================================

if [ ! -d src/external/libspotify-12.1.51-Linux-x86_64-release ]; then
  if [ ! -f src/external/libspotify-12.1.51-Linux-x86_64-release.tar.gz ]; then
    pushd src/external
      wget https://github.com/mopidy/libspotify-archive/raw/master/libspotify-12.1.51-Linux-x86_64-release.tar.gz -O libspotify-12.1.51-Linux-x86_64-release.tar.gz 
      if [ $? -ne 0 ]; then
        echo "go and get libspotify-12.1.51-Linux-x86_64-release.tar.gz from the internet"
        echo "save tar.gz to src/external/libspotify/"
        exit
      fi
    popd
  else	
    pushd src/external/
      tar xfz libspotify-12.1.51-Linux-x86_64-release.tar.gz
    popd
  fi
fi

if [ ! -f lib/libspotify.so.12.1.51 ]; then
  cp src/external/libspotify-12.1.51-Linux-x86_64-release/lib/libspotify.so.12.1.51 lib/
  pushd lib
    ln -s libspotify.so.12.1.51 libspotify.so
    ln -s libspotify.so.12.1.51 libspotify.so.12
  popd
fi

if [ ! -h src/spotiload/libspotify ]; then
  pushd src/spotiload
    ln -s ../external/libspotify-12.1.51-Linux-x86_64-release/include/libspotify libspotify
  popd
fi

pushd src/spotiload
  make
popd

