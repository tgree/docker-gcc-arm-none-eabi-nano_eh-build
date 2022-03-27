# Copyright (c) 2022 by Terry Greeniaus.
# Build with: docker build -t gcc-arm-none-eabi-9-2019-q4-major-nano_eh-build .
# Run with  : docker run -ti gcc-arm-none-eabi-9-2019-q4-major-nano_eh-build
FROM ubuntu:20.04

# Set the locale.
ENV LANG C.UTF-8

# Un-minimize to start with.
RUN yes | unminimize

# Install the base OS and gcc build dependency packages.
RUN apt-get update                                      \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y   \
    bzip2                                               \
    curl                                                \
    g++                                                 \
    gcc                                                 \
    git                                                 \
    make                                                \
    man                                                 \
    manpages                                            \
    manpages-dev                                        \
    tig                                                 \
    tmux                                                \
    vim                                                 \
    autoconf                                            \
    autogen                                             \
    bison                                               \
    build-essential                                     \
    dejagnu                                             \
    flex                                                \
    flip                                                \
    gawk                                                \
    gperf                                               \
    gzip                                                \
    libisl-dev                                          \
    libncurses5-dev                                     \
    nsis                                                \
    openssh-client                                      \
    p7zip-full                                          \
    perl                                                \
    python-dev                                          \
    scons                                               \
    tcl                                                 \
    texinfo                                             \
    texlive                                             \
    texlive-extra-utils                                 \
    tofrodos                                            \
    wget                                                \
    zip

# Make a download location in /tmp.
RUN mkdir /tmp/download-images

# Install gcc-arm-none-eabi sources.
RUN curl -L "https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2?revision=ed3827e2-edba-4f68-8f0f-ac647100866c&hash=8E80333E823CFEB3F99213221E4EF83B82FE224A" \
         -o /tmp/download-images/gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2

# isl is no longer available from the original website; install a cached copy.
# Note that we change the suffix from .bz2 to .xz as expected by the build
# scripts; the 'tar xf' invocation in the scripts handles it transparently.
RUN curl -L "https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2" -o /tmp/download-images/isl-0.18.tar.xz

# expat is deprecated; install and rename the deprecated version.
RUN curl -L "https://downloads.sourceforge.net/project/expat/expat/2.1.1/expat-2.1.1-RENAMED-VULNERABLE-PLEASE-USE-2.4.7-INSTEAD.tar.bz2" -o /tmp/download-images/expat-2.1.1.tar.bz2

# Set up the gccbuild user.
COPY fs/home/userhome /home/gccbuild
RUN useradd -M -s /bin/bash gccbuild                    \
 && echo gccbuild:password | chpasswd

# Move all downloads into the user's home directory.
RUN mv /tmp/download-images/* /home/gccbuild/           \
 && rmdir /tmp/download-images                          \
 && chown -R gccbuild:gccbuild /home/gccbuild

# Switch to the new user and set docker to execute all further commands out of the
# new user's home directory.
USER gccbuild
WORKDIR /home/gccbuild

# Verify the MD5 sums on all downloaded files.  These should match the MD5
# sums listed on ARM's web site:
#
#    https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads
#
# Unfortunately there doesn't seem to be a programmatic way to retrieve just
# the MD5 sums, so we embed them in a file called gcc_md5_sums.txt which you
# can manually verify.
RUN md5sum -c gcc_md5_sums.txt                                          \
    && tar xf gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2             \
    && mv isl-0.18.tar.xz gcc-arm-none-eabi-9-2019-q4-major/src/        \
    && mv expat-2.1.1.tar.bz2 gcc-arm-none-eabi-9-2019-q4-major/src/
