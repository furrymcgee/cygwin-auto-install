#!/bin/bash
0<<-'BASH' \
5<<-'HINT' \
6<<'MAKE' \
11<<-'SOURCE' \
LANG=C.UTF-8 bash -e
	: sed -i /etc/xinetd.d/ftpd \
		-e /disable/s/yes/no/ \
		-e /user/s/cyg_server/Administrator/

	while read SERVICE
	do
		: ${SERVICE}-config --yes
		: cygrunsvr -S ${SERVICE}
	done \
	<<-'SERVICE'
		xinetd
		syslogd
	SERVICE

	export SITE=http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2016/08/30/104223 

	cd *cygwin* || exit 1
	
	# get source packages of downloaded binaries
	find x86/setup.ini -quit ||
	wget --continue --directory-prefix=x86 ${SITE}/x86/setup.ini
	
	# downloaded setup.hint of installed packages and external sources
	find -mindepth 2 -maxdepth 2 -name setup.ini |
	xargs -r grep ^@\\\|^install:\\\|^source: |
	sed s/^@/:@/ |
	cut -d: -f2 | 
	sed -z \
		-e s/@\ /\\\x0/g \
		-e s/\\\n/\ /g |
	tr \ \\\000 \\\t\\\n |
	cut -f1,3,5,7,9 | 
	grep ^. |
	sort |
	{
		coproc {
			grep setup.hint
		}
		exec 7<&${COPROC[0]}- 8<&${COPROC[1]}-

		# Filter existing archives
		coproc {
			cut -f2-5 |
			tr \\\t \\\n |
			tac |
			paste - - |
			sed s%\\\t%\ \ ./% |
			sort |
			uniq |
			join -v1 -t$'\n' - <(
				find -type f -name '*cairo*' | 
				xargs -P 0 -I@ sha512sum @ |
				sort
			)
		}
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-

		# Find setup.hint and archives of packages
		coproc { 
			join -o2.2,2.1,1.2,1.4 -t$'\t' - <(
				cat <&11 - <(
					find * \
						-maxdepth 0 \
						-mindepth 0 \
						-type d \
						-execdir \
							find {}/release \
								-mindepth 1 \
								-type d \
								-printf %f\\\t%h\\\t%d\\\n \
							\;
				) |
				sort
			) |
			sed -e s%\\\t%/% -e s%\\\t%/setup.hint\&% |
			tr \\\t \\\n |
			sort |
			uniq |
			# suppress existing setup.hint
			join -v1 -t$'\n' - <(
				find -mindepth 2 -type f -name setup.hint |
				sort
			) |
			tee >(
				cat >&8
			)
		}
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-

		tee >(cat >&4) > >(cat >&6) &
		exec 4>&- 6>&- 8>&-

		#####################

		cat <(
			# required setup.hint
			cat <&7 > /dev/null
		) <(
			join -a2 -22 <(
				# required archives and setup.hint
				sort <&5 > /dev/null
			) <(
				# available packages
				sort -k2 <&3
			) |
			sed s/\\\s\\\+/\\\t/g
		) |
		cut -f1 |
		cat
		exit
		xargs -I@ printf \
			:\ wget\ \
				--continue\ \
				--directory-prefix=\$\(dirname\ %q\)\ \
				${SITE}/%q\ \
				@ @ 
		wait
	} |
	cat
	exit

	# use setup.hint and print file name, starting point and directory
	find * \
		-maxdepth 0 \
		-mindepth 0 \
		-type d \
		-execdir \
			find {}/release \
				-name setup.hint \
				-printf %p\\\t{}\\\t%h\\\n \
			\; | 
	sort |
	# print filename/arch and grep external-source from setup.hint
	{
		# print filename and arch
		coproc { cat; }
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
		# pipe filename to xargs grep
		coproc {
			cut -f3- |
			xargs -I@ grep --with-filename external-source @/setup.hint |
			tr : \\\t | tr -d ' ' |
			join -o1.1,1.3,2.1 -t$'\t' -12 - <(cat <<<external-source) 
		}
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-
		tee >(cat >&4) > >(cat >&6) &
		exec 4>&- 6>&-
		cat <(<&3 cat) &
		cat <(<&5 cat) &
		wait
	} |
	sort |
	# cross join filename/arch and external-source
	{
		coproc { cat; } && exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
		coproc { cat; } && exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-
		tee >(cat >&4) > >(cat >&6) & exec 4>&- 6>&-
		join -t$'\t' <(<&3 cat) <(<&5 cat) 
	} |
	sort -k3 |
	# combine lines with external-source and starting point
	join -t$'\t' -13 - <(cat <<<external-source) |
	# select only lines with external-source and starting point
	join -t$'\t' -15 -v1 -o1.4,1.3 - <(cat <<<external-source) |
	sed s%\\\t%/release/% |
	uniq |
	cat 
	exit
	# download external-source
	xargs -I@ echo wget --continue --directory-prefix=@ ${SITE}/@/setup.hint 
	exit

	find -mindepth 2 -maxdepth 2 -name setup.ini |
	xargs --no-run-if-empty mv -bvt . &&
	sed s/^.// <&6 |
	: make -f - x86/release/custompackage-0.0.1-1 x86/setup.ini
BASH
	sdesc: "My favorite packages"
	ldesc: "My favorite packages"
	category: Base
	requires: bzip2 cygwin-doc file less openssh pinfo rxvt wget
HINT
	PACKAGE=$(lastword $(subst /, ,$(firstword $(subst -, ,$@))))
	VERSION=$(word 2,$(subst -, ,$@))
	RELEASE=$(lastword $(subst -, ,$@))

	$(addsuffix /release/%,x86 x86_64):
		mkdir $(dir $@)/$(PACKAGE) || true
		cat > $(dir $@)/$(PACKAGE)/setup.hint <&5
		tar -Jcf $(dir $@)/$(PACKAGE)/$(PACKAGE)-$(VERSION)-$(RELEASE).tar.xz  --files-from /dev/null
		tar -Jcf $(dir $@)/$(PACKAGE)/$(PACKAGE)-$(VERSION)-$(RELEASE)-src.tar.xz --files-from /dev/null

	$(addsuffix /setup.ini,x86 x86_64):
		mksetupini \
			--verbose \
			--arch $(firstword $(subst /, ,$@)) \
			--inifile=$@ \
			--releasearea=. \
			--setup-version=2.874 \
			# --okmissing required-package \
			# --disable-check=missing-required-package \
			# --disable-check=missing-depended-package \
			# --disable-check=missing-curr \

		stat $@
		bzip2 < $@ > $(dir $@)/setup.bz2
		xz -6e < $@ > $(dir $@)/setup.xz
MAKE
	db	x86/release
	emacs	x86/release
	glu/libGLU1	x86/release
	dconf/libdconf1	x86/release
	e2fsprogs/libe2p2	x86/release
	libev/libev4	x86/release
	libgcrypt-devel/libgcrypt-devel	x86/release
	freeglut/libglut3	x86/release
	gmp/libgmpxx4	x86/release
	libgpg-error/libgpg-error-devel	x86/release
	lz4/liblz4_1	x86/release
	lz4/liblzo2-doc	x86/release
	pcre/libpcre16_0	x86/release
	pcre/libpcreposix0	x86/release
	pcre2/libpcre2_32_0	x86/release
	plotutils/libplot2	x86/release
	procps/libprocps-ng4	x86/release
	readline/libreadline-devel	x86/release
	libsigsegv/libsigsegv-devel	x86/release
	e2fsprogs/libss2	x86/release
	libwebp/ibwebpdecoder1	x86/release
	libwebp/libwebpdemux1	x86/release
	perl/perl-CGI	noarch/release
	postgrsql/postgresql-client	x86/release
SOURCE
