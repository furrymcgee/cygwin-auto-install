#!/bin/sh


test -r "$(dirname $0)/Packages" &&
test -r  "$(dirname $0)/Sources" || 
exit 1

test -n "$*" ||
exit 2

7<<-REC \
0<<-'BASH' \
bash
	%rec: Package
	%key: Package
	%type: Source rec Source
	%type: Binary rec Binary

	Package: $1
	Source: $1
	Binary: $1

	%rec: Binary
	%key: Package

	$(
		cat "$(dirname $0)/Packages" |
		sed /^Package:\ $1$/,/^$/\!d |
		sed -z s/\\x0a\\x0a/\\x00/g |
		sed -z /Extra-Source/d |
		sed s/\\x00/\\x0a\\x0a/ 
	)

	%rec: Source
	%key: Binary

	$(
		cat "$(dirname $0)/Sources" |
		sed s/Binary:.*\ $1.*/Binary:\ $1/ |
		sed /^Binary:\ $1/,/^$/\!d |
		sed -z s/\\\x0a\\\x0a/\\x00/g |
		sed -z /Extra-Source/d |
		sed s/\\\x00/\\x0a\\x0a/
	)

REC
	enable -f /usr/lib/recutils/bash-builtins/readrec.so readrec 2> /dev/null ||
	enable -f readrec-0.dll readrec ||
	exit 1
	{
		coproc { cat; }
		exec 3<&${COPROC[0]}- 4<&${COPROC[1]}-
		coproc { cat; }
		exec 5<&${COPROC[0]}- 6<&${COPROC[1]}-

		tr _- ^_ <&7 |
		sed s/^\ /\+\ / |
		tee >(cat >&4) > >(cat >&6) &
		exec 4<&- 6<&-
		cat <<-REC |
			$( recsel -t Package -j Binary <&3 )
			$( recsel -t Package -j Source <&5 )
		REC
		recsel -n0 -p \
			$(
				paste -s -d, <<-'FIELDS'
					Binary_Package
					Binary_Version
					Binary_Section
					Binary_Depends
					Source_Architecture
					Source_Directory
					Source_Files
					Source_Build_Depends_Indep
					Binary_Description
				FIELDS
			)
		wait
	} |
	while readrec
	do
		tr ^_ _- <<-CYGPORT
			# THIS IS A GENERATED CYGPORT FILE 
			NAME="$Binary_Package"
			VERSION="$( sed <<<${Binary_Version} \
				s/[^:]*:\\s*\\\([^:_]*\\\)_\\?[^_]*/\\\1/)"
			RELEASE=1
			CATEGORY="$(<<<${Binary_Section} sed /devel/s/.*/devel/)"
			SUMMARY="$(head -n1 <<<${Binary_Description})"
			DESCRIPTION="$(tail -n+2 <<<${Binary_Description})"
			HOMEPAGE="http://sourceware.org/cygwinports/"
			SRC^URI="$(
				tr \  \\\n <<<${Source_Files} |
				sed 1~3\!d |
				sed "s%^%http://ftp.debian.org/debian/${Source_Directory}/%" |
				paste -s -d' '
			)"
			SRC^DIR="."
			PATCH^URI="$(
				tr _^ -_ <<<${Binary_Package} |
				xargs -r -I@ find -maxdepth 1 -type f -name '@.patch'
			)"
			DEBEMAIL="user@example.com"
			DEBFULLNAME="Firstname Lastname"
			# DEBUILD_DPKG_BUILDPACKAGE_OPTS="--force-sign --sign-key=0000000000000000"
			# DH_VERBOSE=1

			# this package contains no compiled Cygwin binaries
			# REMOVE THE FOLLOWING LINE for packages which are to be compiled for each arch
			ARCH="$(
				<<<"${Source_Architecture}" \
				sed \
					-e /any/s/.*/i686/ \
					-e /amd64/s/.*/i686/ \
					-e /all/s/.*/noarch/ 
			)"

			$( 
				tr _? -_ <<-DEPS |
					${Source_Build_Depends_Indep}
					${Binary_Depends}
				DEPS
				PERL5LIB=/usr/share/perl5 \
				perl 9<&0 0<<-'PERL'
					use Dpkg::Deps;
					open(STDIN, '<&=', 9);
					local @_=<>;
					chomp @_;
					print <<DEPS;
						# Build dependencies only
						DEPEND="@{[join ' ', map { $_->{package} } @{deps_parse($_[0])->{list}}]}"

						# runtime deps to go in setup.hint, and note the escaped newline
						REQUIRES="@{[join ' ', map { $_->{package} } @{deps_parse($_[1])->{list}}]}"
						DEPS
				PERL
			)

			inherit dpkg
		CYGPORT
	done 
BASH
