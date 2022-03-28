#!/bin/bash
# Notes:
#
#   1. The Howto step builds the How-to-build-toolchain.pdf file, but this
#      step fails for some reason.
#   2. We don't need mingw32 or the manual, so disable them too.
#   3. The magic for building the nano bits is in build-toolchain.sh.  Search
#      for 'copy_multi_libs' then scroll up a bit.  In particular, the
#      configure parameter '--disable-libstdcxx-verbose' seems to be the
#      ingredient that avoids linking in all of the read()/write() and other
#      standard IO functions that spam your console when terminate() is
#      called.  We also need to remove the '--fno-exceptions'
#      CXXFLAGS_FOR_TARGET parameter so that we get exception tables in the
#      nano library builds.
#
# The unpatched build-toolchain.sh script takes around 63 minutes to run on my
# M1 Max Macbook Pro while the patched version takes around 74 minutes.  The
# patched version takes 273 minutes to build on my 3.3 GHz 2016 MacBook Pro.
GCC_VERSION=gcc-arm-none-eabi-9-2020-q2-update
RELEASE_DATE=20200408
TGT_SUFFIXES=(aarch64-linux.tar.bz2 x86_64-linux.tar.bz2 src.tar)

# Exit when any command fails.
set -e

# Patch the official sources.
cd $GCC_VERSION
patch -p1 < ~/patches/$GCC_VERSION-src.patch
./install-sources.sh --skip_steps=mingw32,howto
patch -p1 < ~/patches/gcc-libgloss-nano_eh-specs.patch

# Build it all.
time ./build-prerequisites.sh --skip_steps=mingw32,howto --release_date=$RELEASE_DATE
time ./build-toolchain.sh --skip_steps=mingw32,howto,manual --release_date=$RELEASE_DATE

# Link and move final build products into place.
cd && ln -s $GCC_VERSION/pkg
for suffix in "${TGT_SUFFIXES[@]}"; do
    [ -f pkg/$GCC_VERSION-$suffix ] && mv pkg/$GCC_VERSION-$suffix pkg/$GCC_VERSION-nano-eh-$suffix
done
