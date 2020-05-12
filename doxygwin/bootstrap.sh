#!/bin/sh
# bootstrap cygwin/dpkg toolchain

# tar
cygport --32 x86/release/tar/tar.cygport download
cygport --32 x86/release/tar/tar.cygport all
tar xJvf - < x86/release/tar/tar-1.29-1.i686/dist/tar/tar-1.29-1.tar.xz -C /

# debhelper+dpkg
cygport --32 x86/release/dpkg/dpkg.cygport download
cygport --32 noarch/release/debhelper/debhelper.cygport download
cygport --32 x86/release/dpkg/dpkg.cygport prep
cygport --32 noarch/release/debhelper/debhelper.cygport prep
cp -a x86/release/dpkg/dpkg-1.19.7-1.i686/src/dpkg-1.19.7/scripts/Dpkg* noarch/release/debhelper/debhelper-12.1.1-1.noarch/src/debhelper/lib
cygport --32 noarch/release/debhelper/debhelper.cygport compile
cygport --32 noarch/release/debhelper/debhelper.cygport install
cygport --32 noarch/release/debhelper/debhelper.cygport package
tar xvJf - < noarch/release/debhelper/debhelper-12.1.1-1.noarch/dist/debhelper/debhelper-12.1.1-1.tar.xz -C /
cygport --32 x86/release/dpkg/dpkg.cygport compile
cygport --32 x86/release/dpkg/dpkg.cygport install
cygport --32 x86/release/dpkg/dpkg.cygport package
tar xvJf - < x86/release/dpkg/dpkg-1.19.7-1.i686/dist/dpkg/dpkg-1.19.7-1.tar.xz -C /

# cygport
cygport --32 noarch/release/cygport/cygport.cygport download
cygport --32 noarch/release/cygport/cygport.cygport all
tar xJf - -C / < noarch/release/cygport/cygport-0.22.0-1.noarch/dist/cygport/cygport-0.22.0-1.tar.xz

# dh-autoreconf
cygport --32 noarch/release/dh-autoreconf/dh-autoreconf.cygport download
cygport --32 noarch/release/dh-autoreconf/dh-autoreconf.cygport all
tar xvJf - < noarch/release/dh-autoreconf/dh-autoreconf-19-1.noarch/dist/dh-autoreconf/dh-autoreconf-19-1.tar.xz -C /

# strip-nondeterminism
cygport --32 noarch/release/strip-nondeterminism/strip-nondeterminism.cygport download
cygport --32 noarch/release/strip-nondeterminism/strip-nondeterminism.cygport all
tar xvJf - < noarch/release/strip-nondeterminism/strip-nondeterminism-1.1.2-1-1.noarch/dist/strip-nondeterminism/strip-nondeterminism-1.1.2-1-1.tar.xz -C /

