#!/bin/bash
0<<-'BASH' \
17<<-'REQUIRED' \
18<<-'EXTERNAL' \
19<<'MAKE' \
20<<-'HINT' \
21<<-'SOURCE' \
22<<-'SERVICES' \
LANG=C.UTF-8 bash
	
	##### START SERVICES #####
	: bash <&22

	export SITE=http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2016/08/30/104223 
	cd *cygwin* || exit 1
	
	##### DOWNLOAD SETUP.INI #####
	# get source packages of downloaded binaries
	: find x86/setup.ini -quit -maxdepth 0 ||
	wget --continue --directory-prefix=x86 ${SITE}/x86/setup.ini
	
	##### DOWNLOAD PACKAGES #####
	# downloaded setup.hint of installed packages
	bash <&17
	# second process required because of external dependencies
	bash <&18

	##### MAKE SETUP.INI #####
	sed s/^.// <&19 |
	make -f - x86/release/custompackage-0.0.1-1 x86/setup.ini
BASH
	# grep available packages from setup.ini
	# join with downloaded packages
	# download setup.ini
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
	join -t$'\t' -o1.1,1.2,2.2,2.4 <(
		cat <&21 - <(
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
		sort |
		uniq
	) - |
	tr \\\t \\\n |
	tac |
	paste - - |
	tac |
	paste - - |
	sed \
		-e s%\\\t%/% \
		-e s%\\\t%/setup.hint\&% \
		-e s%\\\t%\&./%g |
	tr \\\t \\\n |
	sort |
	uniq |
	join -v1 - <(find -type f | sort &) | # exclude existing files
	xargs -I@ printf \
		wget\ \
			--continue\ \
			--directory-prefix=\$\(dirname\ %q\)\ \
			${SITE}/%q\\\n \
			@ @ |
	sh &
	exec 6<&-
	wait
REQUIRED

	# wait until required packages downloaded
	# download external sources after process finished
	# find required setup.hint 
	# print file name, starting point and directory
	# grep and join external-source
	# download external source
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
	tee >(
		cut -f3- |
		xargs -I@ grep --with-filename external-source @/setup.hint |
		tr : \\\t | tr -d ' ' |
		join -o1.1,1.3,2.1 -t$'\t' -12 - <(cat <<<external-source)
	) |
	sort |
	{
		# cross join filename/arch and external-source
		coproc { cat; }
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
		tee >(cat >&4) | # -> coproc
		join -t$'\t' - <(<&3 cat &) & # <- coproc
		exec 4>&-
		wait
	} |
	sort -k3 |
	# combine lines with external-source and starting point
	join -t$'\t' -13 - <(cat <<<external-source) |
	# select only lines with external-source and starting point
	join -t$'\t' -15 -v1 -o1.4,1.3 - <(cat <<<external-source) |
	sed s%\\\t%/release/% |
	uniq |
	sort |
	xargs -I@ printf %q/setup.hint\\\n @ |
	join -v1 - <(
		find -type f -name setup.hint| sort & # exclude existing files
	) |
	xargs -I@ printf \
		wget\ \
			--continue\ \
			--directory-prefix=\$\(dirname\ %q\)\ \
			${SITE}/%q\\\n \
			@ @ |
	sh
EXTERNAL
	PACKAGE=$(lastword $(subst /, ,$(firstword $(subst -, ,$@))))
	VERSION=$(word 2,$(subst -, ,$@))
	RELEASE=$(lastword $(subst -, ,$@))

	$(addsuffix /release/%,x86 x86_64):
		mkdir $(dir $@)/$(PACKAGE) || true
		cat > $(dir $@)/$(PACKAGE)/setup.hint <&20
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
	sdesc: "My custom package"
	ldesc: "My custom package"
	category: Base
	requires: bzip2 cygwin-doc file less openssh pinfo rxvt wget
HINT
	db	./x86/release
	emacs	./x86/release
	error/libgpg-error-devel	./x86/release/libgpg
	ibwebpdecoder1	./x86/release/libwebp
	libGLU1	./x86/release/glu
	libdconf1	./x86/release/dconf
	libe2p2	./x86/release/e2fsprogs
	libev4	./x86/release/libev
	libgcrypt-devel	./x86/release/libgcrypt
	libglut3	./x86/release/freeglut
	libgmpxx4	./x86/release/gmp
	liblz4_1	./x86/release/lz4
	liblzo2-doc	./x86/release/liblzo2
	libpcre16_0	./x86/release/pcre
	libpcre2_32_0	./x86/release/pcre2
	libpcreposix0	./x86/release/pcre
	libplot2	./x86/release/plotutils
	libprocps-ng4	./x86/release/procps-ng
	libreadline-devel	./x86/release/readline
	libsigsegv-devel	./x86/release/libsigsegv
	libss2	./x86/release/e2fsprogs
	libwebpdemux1	./x86/release/libwebp
	perl-CGI	./noarch/release
	postgresql-client	./x86/release/postgresql
SOURCE
	sed -i /etc/xinetd.d/ftpd \
		-e /disable/s/yes/no/ \
		-e /user/s/cyg_server/Administrator/

	while read SERVICE
	do
		${SERVICE}-config --yes
		cygrunsrv -S ${SERVICE}
	done \
	<<-'SERVICE'
		xinetd
		syslogd
	SERVICE
SERVICES
