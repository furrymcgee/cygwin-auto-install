#!/bin/bash
0<<-'BASH' \
5<<-'HINT' \
6<<'MAKE' \
8<<-'SOURCE' \
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
			cut -f2-5 |
			tr \\\t \\\n |
			tac |
			paste - - |
			sort | uniq
		}
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-

		coproc { 
			join -o2.2,2.1,1.2,1.4 -t$'\t' - <(
				cat <&8 - <(
					find * \
						-maxdepth 0 \
						-mindepth 0 \
						-type d \
						-execdir \
							find {}/release \
								-mindepth 1 \
								-type d \
								-printf %f\\\t%H\\\n \
							\;
				) |
				sort
			) |
			sed -e s%\\\t%/% -e s%\\\t%/setup.hint\&% |
			tr \\\t \\\n |
			sort | uniq |
			xargs -I@ printf \
				:\ wget\ \
					--continue\ \
					--directory-prefix=\$\(dirname\ %q\)\ \
					${SITE}/%q\ \&\&\ \
					sha512sum\ %q\\\n @ @ @ 
		}
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-
	
		tee >(cat >&4) > >(cat >&6) &
		exec 4>&- 6>&-

		cat <(cat <&5 | grep -v setup.hint | sort ) > /dev/null &
		cat <(cat <&3 | sort) &
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
	libGLU1	x86/release
	libdconf1	x86/release
	libe2p2	x86/release
	libev4	x86/release
	libgcrypt-devel	x86/release
	libglut3	x86/release
	libgmpxx4	x86/release
	libgpg-error-devel	x86/release
	liblz4_1	x86/release
	liblzo2-doc	x86/release
	libpcre16_0	x86/release
	libpcre32_0	x86/release
	libpcreposix0	x86/release
	libplot2	x86/release
	libprocps-ng4	x86/release
	libreadline-devel	x86/release
	libsigsegv-devel	x86/release
	libss2	x86/release
	libwebpdecoder1	x86/release
	libwebpdemux1	x86/release
	perl-CGI	noarch/release
	postgresql-client	x86/release
SOURCE
