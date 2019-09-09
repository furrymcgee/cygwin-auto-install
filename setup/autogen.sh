#!/bin/bash
0<<-'BASH' \
5<<-'HINT' \
6<<'MAKE' \
14<<-'SOURCE' \
15<<-'SERVICES' \
16<<-'SETUP' \
17<<-'EXTSOURCE' \
LANG=C.UTF-8 bash
	export SITE=http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2016/08/30/104223 

	cd *cygwin* || exit 1
	
	##### DOWNLOAD #####

	##### DOWNLOAD SETUP.INI #####
	# get source packages of downloaded binaries
	find x86/setup.ini -quit -maxdepth 0 ||
	wget --continue --directory-prefix=x86 ${SITE}/x86/setup.ini
	
	##### DOWNLOAD PACKAGES #####
	set -x
	source <(
		: cat <&15
		cat <&16
		cat <&17
	)
	
	exit

	find -mindepth 2 -maxdepth 2 -name setup.ini |
	xargs --no-run-if-empty mv -bvt . &&
	sed s/^.// <&6 |
	: make -f - x86/release/custompackage-0.0.1-1 x86/setup.ini
BASH
	sdesc: "My custom package"
	ldesc: "My custom package"
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

	##### START SERVICES #####

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
SERVICES
	coproc {
		grep setup.hint
	}
	exec 11<&${COPROC[0]}- 12<&${COPROC[1]}-

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

		# filter existing archives
		coproc {
			cut -f2-5 |
			tr \\\t \\\n |
			tac |
			paste - - |
			sed s%\\\t%\ \ ./% |
			sort -k2 |
			uniq |
			join -v1 -j2 - <(
				find -type f | 
				sort -k2
				# xargs -P 0 -I@ sha512sum @
			)
		}
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-

		# find required setup.hint
		coproc { 
			join -o2.2,2.1,1.2,1.4 -t$'\t' - <(
				cat <&14 - <(
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
			) |
			sed \
				-e s%\\\t%/% \
				-e s%\\\t%/setup.hint\&% \
				-e s%\\\t%\&./%g |
			tr \\\t \\\n |
			sort |
			uniq |
			# suppress existing setup.hint
			join -v1 -t$'\n' - <(
				find -mindepth 2 -type f -name setup.hint |
				sort |
				tee >(cat >&12)
			) |
			tee >(cat >&8)
		}
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-

		tee >(cat >&4) > >(cat >&6) &
		exec 4>&- 6>&- 8>&-

		cat <(
			# required setup.hint
			cat <&7  > /dev/null
		) <(
			join -v1 -o1.1 <(
				# required archives and setup.hint
				sort <&5
			) <(
				# available packages
				sort <&3
			)
		) |
		xargs -I@ printf \
			wget\ \
				--continue\ \
				--directory-prefix=\$\(dirname\ %q\)\ \
				${SITE}/%q\\\n \
				@ @ 
		wait
	} |
	sh
	exec 12>&-
	exit

SETUP
	##### EXTERNAL SOURCES #####

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
	xargs -I@ printf %q/setup.hint\\\n @ |
	join -v1 - <(cat <&11) |

	# download external-source
	xargs -I@ \
		printf wget\ \
			--continue\ \
			--directory-prefix=%q\ \
			${SITE}/%q/setup.hint\\\n \
			@ @ 
EXTSOURCE
