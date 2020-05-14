#!/bin/sh
# bootstrap cygwin/dpkg toolchain

test -d x86 || exit 1
test -d noarch || exit 1

# tar
cygport --32 x86/release/tar/tar.cygport download
cygport --32 x86/release/tar/tar.cygport all
tar xJvf - < x86/release/tar/tar-1.29-1.i686/dist/tar/tar-1.29-1.tar.xz -C /
mv x86/release/tar/tar-1.29-1.i686/dist/tar/* x86/release/tar
rm -rf x86/release/tar/tar-1.29-1.i686

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
mv noarch/release/debhelper/debhelper-12.1.1-1.noarch/dist/debhelper/* noarch/release/debhelper
rm -rf noarch/release/debhelper/debhelper-12.1.1-1.noarch
cygport --32 x86/release/dpkg/dpkg.cygport compile
cygport --32 x86/release/dpkg/dpkg.cygport install
cygport --32 x86/release/dpkg/dpkg.cygport package
tar xvJf - < x86/release/dpkg/dpkg-1.19.7-1.i686/dist/dpkg/dpkg-1.19.7-1.tar.xz -C /
mv x86/release/dpkg/dpkg-1.19.7-1.i686/dist/dpkg/* x86/release/dpkg
rm -rf x86/release/dpkg/dpkg-1.19.7-1.i686

# cygport
cygport --32 noarch/release/cygport/cygport.cygport download
cygport --32 noarch/release/cygport/cygport.cygport all
tar xJf - -C / < noarch/release/cygport/cygport-0.22.0-1.noarch/dist/cygport/cygport-0.22.0-1.tar.xz
mv noarch/release/cygport/cygport-0.22.0-1.noarch/dist/cygport/* noarch/release/cygport
rm -rf noarch/release/cygport/cygport-0.22.0-1.noarch

# calm/mksetupini
cygport --32 noarch/release/calm/calm.cygport download
cygport --32 noarch/release/calm/calm.cygport all
tar xvJf - < noarch/release/calm/calm-20160730-1.noarch/dist/calm/calm-20160730-1.tar.xz -C /
mv noarch/release/calm/calm-20160730-1.noarch/dist/calm/* noarch/release/calm
rm -rf noarch/release/calm/calm-20160730-1.noarch

# dh-autoreconf
cygport --32 noarch/release/dh-autoreconf/dh-autoreconf.cygport download
cygport --32 noarch/release/dh-autoreconf/dh-autoreconf.cygport all
tar xvJf - < noarch/release/dh-autoreconf/dh-autoreconf-19-1.noarch/dist/dh-autoreconf/dh-autoreconf-19-1.tar.xz -C /
mv noarch/release/dh-autoreconf/dh-autoreconf-19-1.noarch/dist/dh-autoreconf/* noarch/release/dh-autoreconf
rm -rf noarch/release/dh-autoreconf/dh-autoreconf-19-1.noarch

# strip-nondeterminism
cygport --32 noarch/release/strip-nondeterminism/strip-nondeterminism.cygport download
cygport --32 noarch/release/strip-nondeterminism/strip-nondeterminism.cygport all
tar xvJf - < noarch/release/strip-nondeterminism/strip-nondeterminism-1.1.2-1-1.noarch/dist/strip-nondeterminism/strip-nondeterminism-1.1.2-1-1.tar.xz -C /
mv noarch/release/strip-nondeterminism/strip-nondeterminism-1.1.2-1-1.noarch/dist/strip-nondeterminism/* noarch/release/strip-nondeterminism
rm -rf noarch/release/strip-nondeterminism/strip-nondeterminism-1.1.2-1-1.noarch

# dctrl-tools
cygport --32 x86/release/dctrl-tools/dctrl-tools.cygport download
cygport --32 x86/release/dctrl-tools/dctrl-tools.cygport all
tar xvJf - < x86/release/dctrl-tools/dctrl-tools-2.24-3-1.i686/dist/dctrl-tools/dctrl-tools-2.24-3-1.tar.xz -C /
mv x86/release/dctrl-tools/dctrl-tools-2.24-3-1.i686/dist/dctrl-tools/* x86/release/dctrl-tools
rm -rf x86/release/dctrl-tools/dctrl-tools-2.24-3-1.i686

# recutils
cygport --32 x86/release/recutils/recutils.cygport download
cygport --32 x86/release/recutils/recutils.cygport all
tar xvJf - < x86/release/recutils/recutils-1.7-3-1.i686/dist/recutils/recutils-1.7-3-1.tar.xz -C /
mv x86/release/recutils/recutils-1.7-3-1.i686/dist/recutils/* x86/release/recutils
rm -rf x86/release/recutils/recutils-1.7-3-1.i686

