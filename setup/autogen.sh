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
	find x86/setup.ini || wget --continue --directory-prefix=x86 ${SITE}/x86/setup.ini
	
	find -mindepth 2 -name setup.ini |
	xargs -r grep ^@\\\|^install:\\\|^source: |
	sed s/^@/:@/ |
	cut -d: -f2 | 
	sed -z \
		-e s/\\\n@\ /\\\x0/g \
		-e s/\\\n/\ /g | \
	tr \ \\\000 \\\t\\\n |
	cut -f1,3,7 | 
	sort |
	{
		# add source directories
		coproc { cat; }
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
		coproc { cat; }
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-
		tee >(cat >&4) > >(cat >&6) &
		exec 4>&- 6>&-
		join -t$'\t' <(cat <&8) <(cat <&3) |
		join -t$'\t' -j4 <(echo 1) - |
		nl &
		join -j4 <(echo 2) <(cat <&5) |
		nl > /dev/null &
		wait
	} |
	sort |
	cut -f4-6
	exit

	# join setup.ini with package names
	#join -t$'\t' -o1.2,2.1,2.2,2.3 <( 
	#	find * \
	#		-maxdepth 0 \
	#		-mindepth 0 \
	#		-type d \
	#		-execdir \
	#			find {}/release \
	#				-mindepth 1 \
	#				-type d \
	#				-printf %f\\\t%H\\\n \
	#			\; | 
	#	sort
	#	exit
	#) <(
		# add source directories
		tee >(
			join -t$'\t' - <(sort <&8)
		) > >(
			cat
		) |
		sort |
		uniq |
		less
		exit
		
	#) | 
	#cat
	exit
	#{
	#	coproc { : ; }
	#	exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
	#	coproc {
			sed -e s%\\\t%/% -e s%\\\t%/setup.hint\&% |
			uniq |
			tr \\\t \\\n |
			xargs -I@ printf \
				wget\ \
					--continue\ \
					--directory-prefix=\$\(dirname\ %q\)\ \
					${SITE}/%q\\\n @ @
	#	}
	#	exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-
	#	tee >(cat >&4) > >(cat >&6) &
	#	exec 4>&- 6>&-
	#	cat <(<&3 cat) <(<&5 cat) |
	#	cat
	#}
	exit

	# find setup.hint and print file name, starting point and directory
	: find * \
		-maxdepth 0 \
		-mindepth 0 \
		-type d \
		-execdir \
			find {}/release \
				-name setup.hint \
				-printf %p\\\t{}\\\t%h\\\n \
			\; | 
	sort |
	# print filename and external-source from setup.hint
	{
		coproc { cat; }
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
		coproc {
			cut -f3- |
			xargs -I@ grep --with-filename external-source @/setup.hint |
			tr : \\\t | tr -d ' ' |
			join -o1.1,1.3,2.1 -t$'\t' -12 - <(cat <<<external-source) 
		}
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-
		tee >(cat >&4) > >(cat >&6) &
		exec 4>&- 6>&-
		cat <(<&3 cat) <(<&5 cat) 
	} |
	sort |
	# cross join
	{
		coproc { cat; }
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
		coproc { cat; }
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-
		tee >(cat >&4) > >(cat >&6) &
		exec 4>&- 6>&-
		join -t$'\t' <(<&3 cat) <(<&5 cat) 
	} |
	sort -k3 |
	# combine lines with external-source and starting point
	join -t$'\t' -13 - <(cat <<<external-source) |
	# select only lines with external-source and starting point
	join -t$'\t' -15 -v1 -o1.4,1.3 - <(cat <<<external-source) |
	sed s%\\\t%/release/% |
	uniq |
	# download external-source
	xargs -I@ wget --continue --directory-prefix=@ ${SITE}/@/setup.hint 

	find -mindepth 2 -name setup.ini |
	xargs --no-run-if-empty mv -bvt . &&
	sed s/^.// <&6 |
	: make -f - x86/release/custompackage-0.0.1-1 x86/setup.ini
BASH
	sdesc: "My favorite packages"
	ldesc: "My favorite packages"
	category: Base
	requires: bzip2 clear cygwin-doc file less openssh pinfo rxvt wget
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
	clear
	db
	emacs
	libGLU1
	libdconf1
	libe2p2
	libev4
	libgcrypt-devel
	libglut3
	libgmpxx4
	libgpg-error-devel
	liblz4_1
	liblzo2-doc
	libpcre16_0
	libpcre32_0
	libpcreposix0
	libplot2
	libprocps-ng5
	libreadline-devel
	libsigsegv-devel
	libss2
	libwebpdecoder1
	libwebpdemux1
	perl-CGI
	postgresql-client
SOURCE
