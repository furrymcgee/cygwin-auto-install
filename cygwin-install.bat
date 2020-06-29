@ECHO OFF
REM -- Automates doxygwin installation
REM -- See /etc/setup/installed.db
REM -- Doxygwin is a customized cygwin installation
REM -- https://github.com/furrymcgee/doxygwin
 
SETLOCAL
REM -- Configure our paths
REM SET SITE=http://cygwin.mirrors.pair.com/
REM SET SITE=http://ftp.jaist.ac.jp/pub/cygwin/
SET DOXYGWIN=%~dp0

REM -- This site is for Microsoft Windows XP
REM -- Download setup-x86.exe 2.874from web archive
REM -- HTTPS is not supported
REM -- gh-pages requires a CNAME to enable HTTP
REM -- net drive for local repository
REM -- https://sourceware.org/legacy-ml/cygwin/2017-03/msg00385.html
REM https://web.archive.org/web/20160820100148/http://cygwin.com/setup-x86.exe
REM http://www.crouchingtigerhiddenfruitbat.org/cygwin/timemachine.html
SET HTTP=https://web.archive.org/web/20160820100148/http://cygwin.com/setup-x86.exe
SET MIRROR=http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2016/08/30/104223
SET MIRROR=http://cygwin.mirrors.pair.com/
SET MIRROR=http://ftp.jaist.ac.jp/pub/cygwin/
SET MIRROR=http://cygwinxp.cathedral-networks.org

%HOMEDRIVE% && CD %HOMEPATH%
SET SETUP=setup-x86.exe

IF NOT EXIST %SETUP% (
	ECHO *** DOWNLOAD SETUP EXE
	COPY %DOXYGWIN%..\repository\Y%%3a%%2f\x86\setup-x86.exe . || cscript ^
	%DOXYGWIN%/download.vbs %HTTP% || exit /B
) ELSE (
	ECHO *** SETUP EXE EXISTS
)

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=%PACKAGES%,httpd,cron,po4a,docbook-xml45,libcrypt-devel,lynx
SET PACKAGES=%PACKAGES%,perl-MIME-Types,poppler,antiword,xlsx2csv,wv,links
SET PACKAGES=%PACKAGES%,bash,tig,tmux,vim,w3m,mc,bc,gnumeric
SET PACKAGES=%PACKAGES%,procmail,mailutils,lftp,exim4,exim4-src
SET PACKAGES=%PACKAGES%,sqlite3,tcl-sqlite3,git,wget,openssh,patch,sed
SET PACKAGES=%PACKAGES%,gcc-g++,gcc-fortran,gdb,gperf,flex,bison,ctags
SET PACKAGES=%PACKAGES%,cmake,dejagnu,make,pkg-config,gettext,check
SET PACKAGES=%PACKAGES%,git-svn,subversion,mercurial,quilt,stgit
SET PACKAGES=%PACKAGES%,mutt,irssi,dialog,procps,stow,ccache,suck,tin
SET PACKAGES=%PACKAGES%,autoconf,automake,autogen,autopoint
SET PACKAGES=%PACKAGES%,intltool,libtool,libtool-bin,libtoolize
SET PACKAGES=%PACKAGES%,lua,perl,perl_manpages,perl-Archive-Zip
SET PACKAGES=%PACKAGES%,bzip2,openssl,p7zip,unzip,xz-utils,zip
SET PACKAGES=%PACKAGES%,clear,file,less,openssh,pinfo,rxvt,wget
SET PACKAGES=%PACKAGES%,inetutils,socat,curl,xinetd,tcp_wrappers
SET PACKAGES=%PACKAGES%,busybox,pandoc,recutils,expat,moreutils
SET PACKAGES=%PACKAGES%,cygport,cygwin-devel,calm,cygwin-doc,meson
SET PACKAGES=%PACKAGES%,ncurses,libncurses-devel,terminfo-extra
SET PACKAGES=%PACKAGES%,robodoc,help2man,asciidoc,transfig,netpbm
SET PACKAGES=%PACKAGES%,python-docutils,bash-completion
SET PACKAGES=%PACKAGES%,perl-Data-UUID,perl-YAML-Tiny,libfile-ncopy-perl
SET PACKAGES=%PACKAGES%,db,perl-CGI,postgresql,ImageMagick,freeglut
SET PACKAGES=%PACKAGES%,libbz2-devel,liblzma-devel,libpipeline-devel
::SET PACKAGES=%PACKAGES%,python,ruby,scons
::SET PACKAGES=%PACKAGES%,ucl,libgdk_pixbuf2.0-devel
::SET PACKAGES=%PACKAGES%,octave,octave-doc,gnuplot,gnuplot-doc,sox
::SET PACKAGES=%PACKAGES%,xorg-server,xorg-docs,xinit,xterm,WindowMaker
::SET PACKAGES=%PACKAGES%,libxml-parser-perl,libffi-dev,libltdl-dev,libssl-dev
::SET PACKAGES=%PACKAGES%,xf86-video-dummy,yasm-devel
::SET PACKAGES=%PACKAGES%,libxml-parser-perl,libffi-dev,libltdl-dev,libssl-dev
::SET PACKAGES=%PACKAGES%,libSDL2-devel,libopenal-devel,libmpg123-devel
SET PACKAGES=%PACKAGES%,dpkg,debhelper,strip-nondeterminism,debconf,dh-exec
SET PACKAGES=%PACKAGES%,dctrl-tools,recutils,info2www,cdbs
SET PACKAGES=%PACKAGES%,dwww,swish++,po-debconf,doc-base
SET PACKAGES=%PACKAGES%,libmodule-build-perl,libmoo-perl,librole-tiny-perl,libole-storage-lite-perl,libmoox-types-mooselike-perl,libthrowable-perl,libsub-quote-perl,libclass-method-modifiers-perl
SET PACKAGES=%PACKAGES%,libemail-simple-perl,libemail-outlook-message-perl,libemail-messageid-perl,libemail-sender-perl,libemail-abstract-perl,libemail-date-format-perl
SET PACKAGES=%PACKAGES%,libemail-mime-perl,libmime-tools-perl,libemail-mime-contenttype-perl,libemail-mime-encodings-perl
SET PACKAGES=%PACKAGES%,perl-Sub-Exporter-Progressive,perl-Devel-GlobalDestruction,perl-Encode,perl-Module-Pluggable

SET ROOT=C:/doxygwin
SET REPOSITORY=%MIRROR%
SET TMPDIR=Z:/http%%3a%%2f%%2fcygwinxp.cathedral-networks.org%%2f
SUBST Z: %DOXYGWIN%/../repository
SET PKGDIR=Z:/

IF NOT EXIST %TMPDIR% (
	ECHO *** DOWNLOAD PACKAGES
	%SETUP% --verbose --quiet-mode --include-source --download --local-package-dir %PKGDIR% --root %ROOT% --packages %PACKAGES% --only-site --no-verify --site %REPOSITORY%
) ELSE (
	ECHO *** SKIP PACKAGE DOWNLOAD
)

SET SITE=Z:/Y%%3a%%2f
SET REPOSITORY=Y:/
IF NOT EXIST %SITE% (
	ECHO *** CREATE LOCAL PACKAGE DIRECTORY
	SUBST X: %SITE%
	SUBST Y: %TMPDIR%
	%SETUP% --verbose --quiet-mode --include-source --download --local-package-dir %PKGDIR% --root %ROOT% --packages %PACKAGES% --only-site --no-verify --site %REPOSITORY%
	SUBST /D X:
	SUBST /D Y:
) ELSE (
	ECHO *** LOCAL PACKAGE DIRECTORY EXISTS
)

REM Set PKGDIR=%TMPDIR% only to bootstrap a new repository
REM SET PKGDIR=%TMPDIR%
SET PKGDIR=%SITE%
IF NOT EXIST %ROOT% (
	ECHO *** INSTALL PACKAGES
	%SETUP% --quiet-mode --no-startmenu --no-desktop --disable-buggy-antivirus --local-install --local-package-dir %PKGDIR% --root %ROOT% --packages %PACKAGES%
) ELSE (
	ECHO *** ROOT DIRECTORY EXISTS
)
ECHO.

SUBST /D Z:
