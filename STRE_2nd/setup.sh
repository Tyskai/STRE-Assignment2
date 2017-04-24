#!/bin/sh
# 1. EXTRACT
ROOT=`pwd`
tar xf gawk-4.1.4.tar.gz
tar xf afl-latest.tgz
tar xf a.tar.gz
# 2. Build
cd $ROOT/afl-2.40b
AFL=`pwd`
make
export AFL_HARDEN=1
cd $ROOT/gawk-4.1.4
./configure CC=$AFL/afl-gcc CXX=$AFL/afl-g++ --disable-shared
make
mv gawk gawk_afl
make distclean
./configure CC=gcc CXX=g++ --disable-shared
make
mv gawk gawk_gcc
cd $ROOT/a
gcc -g -o a_gcc a.c
$AFL/afl-gcc -o a_afl a.c
gcc -g -o a_fixed_gcc a_fixed.c
