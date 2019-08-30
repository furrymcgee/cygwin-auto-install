#!/bin/bash
0<<-'BASH' \
5<<-'HINT' \
6<<'MAKE' \
7<<-'SED' \
LANG=C bash -e
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
	: wget --continue --directory-prefix=x86 ${SITE}/x86/setup.ini

	# join setup.ini with directories
	join <( 
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
		sed 's/.*/echo $(basename &) $(dirname &)/e' |
		sort
	) | 
	cat && exit
	grep -o [[:graph:]]\\\+ | 
	sed -n -f <( cat <&7 ) |
	uniq |
	tr \\\t \\\n |
	sed 's%.*%echo wget -c -P $(dirname &) ${SITE}/&%' |
	sh |
	cat && exit
	sh | sh

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
	tee >(
		# add find output
		cat
	) > >(
		# grep external-source from setup.hint
		cut -f3- |
		xargs -I@ grep --with-filename external-source @/setup.hint |
		tr : \\\t | tr -d ' ' |
		join -o1.1,1.3,2.1 -t$'\t' -12 - <(cat <<<external-source) 
	) |
	# sort by file name
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

	find -mindepth 2 -name setup.ini |
	xargs --no-run-if-empty mv -bvt .

	sed s/^\\\t// <&6 |
	make -f - x86/release/custompackage-0.0.1-1 x86/setup.ini
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
