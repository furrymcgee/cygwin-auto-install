#!/bin/bash
0<<-'BASH' \
5<<-'HINT' \
6<<'MAKE' \
7<<-'SED' \
8<<-'MISSING' \
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

	: join <( 
		find -mindepth 2 -name setup.ini |
		xargs -r grep ^@\\\|^install:\\\|^source: |
		sed s/^@/:@/ |
		cut -d: -f2 | 
		sed -z \
			-e s/\\\n@\ /\\\x0/g \
			-e s/\\\n/\ /g | \
		tr \ \\\000 \\\t\\\n |
		cut -f-3,7 | 
		sort
	) <(
		find * \
			-maxdepth 0 \
			-mindepth 0 \
			-type d \
			-execdir \
				find {}/release \
					-mindepth 1 \
					-type d \
					-printf %f\\\t%H\\\n \
				\; | 
		sort
	) | 
	grep -o [[:graph:]]\\\+ | 
	sed -n -f <( cat <&7 ) |
	uniq |
	tr \\\t \\\n |
	xargs -I@ printf \
		wget\ \
			--continue\ \
			--directory-prefix=\$\(dirname\ %q\)\ \
			${SITE}/%q\\\n @ @ |
	sh

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
	# join filename with external-source from setup.hint
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
	# join find output and external-source
	{
		coproc { cat; }
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
		coproc { cat; }
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-
		tee >(cat >&4) > >(cat >&6) &
		exec 4>&- 6>&-
		join -t$'\t' <(<&3 cat) <(<&5 cat) 
	} |
	# grep external-source joined with starting point
	sort -k3 |
	join -t$'\t' -13 - <(cat <<<external-source) |
	join -t$'\t' -15 -v1 -o1.4,1.3 - <(cat <<<external-source) |
	join -t$'\t' -j3 -o1.1,0,1.2 -e release - <(echo) |
	tr \\\t / |
	uniq |
	# download external-source
	xargs -I@ wget --continue --directory-prefix=@ ${SITE}/@/setup.hint 

	# skip missing
	: xargs -a <(
		xargs <&8 -I@ printf x86/release/%q/setup.hint\\\t @
	) make -f <(
		cat <<<$'%/setup.hint:\n\tmkdir $(dir $@) || true && echo skip: > $@'
	)

	find -mindepth 2 -name setup.ini |
	xargs --no-run-if-empty mv -bvt . &&
	sed s/^.// <&6 |
	make -f - x86/release/custompackage-0.0.1-1 x86/setup.ini
BASH
	sdesc: My favorite packages
	ldesc: My favorite packages
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

		stat $@ && \
		bzip2 < $@ > $(dir $@)/setup.bz2 && \
		xz -6e < $@ > $(dir $@)/setup.xz
MAKE
	s%$%/setup.hint\t%
	x; n; N
	s%\n%\t%g
	H; n; G
	s%\n%/%g
	s%\t/%\t%g
	p
SED
	clear
	db
	libdconf1
	libe2p2
	libss2
	emacs
	libgmpxx4
	libGLU1
	libglut3
	libgcrypt-devel
	libgpg-error-devel
	liblzo2-doc
	libsigsegv-devel
	libglut3
	libwebpdecoder1
	libwebpdemux1
	liblz4_1
	libpcreposix0
	perl-CGI
	libev4
	libpcre16_0
	libpcre32_0
	libpcreposix0
	libplot2
	postgresql-client
	libprocps-ng5
	libreadline-devel
MISSING
