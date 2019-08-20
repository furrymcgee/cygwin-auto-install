#!/bin/bash
0<<-"BASH" \
5<<-"HINT" \
6<<MAKE \
bash -ex
	sed -i /etc/xinetd.d/ftpd \
		-e /disable/s/yes/no/

	: xargs -I@ sh '@-config --yes && cygrunsvr -S @' <<-'EOF'
		xinetd
		syslogd
	EOF

	mkdir x86 x86/release
	sed s/^\\\t// <&6 |
	make --debug -f - x86/release x86/setup.ini
BASH
	sdesc: "My favorite packages"
	ldesc: "My favorite packages"
	category: Base
	requires: bzip2 clear cygwin-doc file less openssh pinfo rxvt wget
HINT
	PACKAGE=custompackage
	VERSION=0.0.1-1

	%/release: %
		mkdir \$@ \$@/${PACKAGE}
		cat > $@/${PACKAGE}/${PACKAGE}-${VERSION}.hint <&5
		tar -Jcf $@/${PACKAGE}/${PACKAGE}-${VERSION}.tar.xz  --files-from /dev/null
		tar -Jcf $@/${PACKAGE}/${PACKAGE}-${VERSION}-src.tar.xz --files-from /dev/null

	%/setup.ini: % %/release
		mksetupini \
			--arch \$< \
			--inifile=\$@ \
			--releasearea=\$< \
			# --disable-check=missing-required-package \
			# --disable-check=missing-depended-package \
			# --disable-check=missing-curr \

		bzip2 < \$@ > \$</setup.bz2
		xz -6e < \$@ > \$</setup.xz
MAKE
