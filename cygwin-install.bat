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
REM http://web.archive.org/web/20160820100148/http://cygwin.com/setup-x86.exe
REM http://www.crouchingtigerhiddenfruitbat.org/cygwin/timemachine.html
SET HTTP=http://web.archive.org/web/20160820100148/http://cygwin.com/setup-x86.exe
SET MIRROR=http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2016/08/30/104223
SET MIRROR=http://cygwin.mirrors.pair.com/
SET MIRROR=http://ftp.jaist.ac.jp/pub/cygwin/
SET MIRROR=http://cygwinxp.cathedral-networks.org

%HOMEDRIVE% && CD %HOMEPATH%
SET SETUP=setup-x86.exe

IF EXIST %SETUP% (
	ECHO *** SETUP EXE EXISTS %SETUP%
) ELSE (
	ECHO *** DOWNLOAD SETUP EXE
	COPY %DOXYGWIN%..\repository\Y%%3a%%2f\x86\setup-x86.exe . || cscript ^
	%DOXYGWIN%/download.vbs %HTTP% || exit /B
)

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=%PACKAGES%,httpd,cron,po4a,docbook-xml45,libcrypt-devel,lynx
SET PACKAGES=%PACKAGES%,perl-MIME-Types,poppler,antiword,xlsx2csv,wv,links
SET PACKAGES=%PACKAGES%,bash,tig,tmux,vim,w3m,mc,bc
SET PACKAGES=%PACKAGES%,procmail,mailutils,lftp,exim4,exim4-src,abook
SET PACKAGES=%PACKAGES%,sqlite3,tcl-sqlite3,git,wget,openssh,patch,sed
SET PACKAGES=%PACKAGES%,gcc-g++,gcc-fortran,gdb,gperf,flex,bison,ctags
SET PACKAGES=%PACKAGES%,cmake,dejagnu,make,pkg-config,gettext,check
SET PACKAGES=%PACKAGES%,git-svn,subversion,mercurial,quilt,stgit
SET PACKAGES=%PACKAGES%,mutt,irssi,dialog,procps-ng,stow,ccache,suck,tin
SET PACKAGES=%PACKAGES%,autoconf,automake,autogen,autopoint
SET PACKAGES=%PACKAGES%,intltool,libtool,libtool-bin,libtoolize
SET PACKAGES=%PACKAGES%,lua,perl,perl_manpages,perl-Archive-Zip
SET PACKAGES=%PACKAGES%,bzip2,openssl,p7zip,unzip,xz-utils,zip
SET PACKAGES=%PACKAGES%,clear,file,less,openssh,pinfo,rxvt,wget
SET PACKAGES=%PACKAGES%,inetutils,socat,curl,xinetd,tcp_wrappers,balance
SET PACKAGES=%PACKAGES%,busybox,pandoc,recutils,expat,moreutils,ncurses
SET PACKAGES=%PACKAGES%,cygport,calm,cygwin-doc,meson,terminfo-extra
SET PACKAGES=%PACKAGES%,cygwin-devel,libncurses-devel,libdb-devel,libxml2-devel
SET PACKAGES=%PACKAGES%,db,perl-CGI,postgresql,mdbtools
SET PACKAGES=%PACKAGES%,robodoc,help2man,netpbm,perl-File-ShareDir-Install
SET PACKAGES=%PACKAGES%,gnumeric,cgit,httpie,ngircd
SET PACKAGES=%PACKAGES%,bash-completion,doxygen,ImageMagick
SET PACKAGES=%PACKAGES%,perl-Data-UUID,perl-YAML-Tiny,libfile-ncopy-perl
SET PACKAGES=%PACKAGES%,public-inbox,perl-DBD-SQLite,vifm,file-devel
SET PACKAGES=%PACKAGES%,libemail-mime-perl,libnet-server-perl
SET PACKAGES=%PACKAGES%,libplack-middleware-reverseproxy-perl,libplack-perl
SET PACKAGES=%PACKAGES%,libsearch-xapian-perl,xapian-tools
::SET PACKAGES=%PACKAGES%,bcrypt,gnutls,ffmpeg,sox,praat,moc,gsl
::SET PACKAGES=%PACKAGES%,libbz2-devel,liblzma-devel,libpipeline-devel
::SET PACKAGES=%PACKAGES%,libgnutls-devel,libpopt-devel,libgsl-devel
::SET PACKAGES=%PACKAGES%,libsndfile-utils,libfluidsynth-devel,libespeak-devel
::SET PACKAGES=%PACKAGES%,docbook-utils,ruby,scons
::SET PACKAGES=%PACKAGES%,pstotext,autotrace,transfig,asciidoc
::SET PACKAGES=%PACKAGES%,ucl,libgdk_pixbuf2.0-devel,libgtk2.0-devel
::SET PACKAGES=%PACKAGES%,octave,octave-doc,gnuplot,gnuplot-doc,asymptote
::SET PACKAGES=%PACKAGES%,xorg-server,xorg-docs,xinit,xterm,WindowMaker
::SET PACKAGES=%PACKAGES%,libxml-parser-perl,libffi-dev,libltdl-dev,libssl-dev
::SET PACKAGES=%PACKAGES%,xf86-video-dummy,yasm-devel,freeglut
::SET PACKAGES=%PACKAGES%,libxml-parser-perl,libffi-dev,libltdl-dev,libssl-dev
::SET PACKAGES=%PACKAGES%,libSDL2-devel,libopenal-devel,libmpg123-devel
SET PACKAGES=%PACKAGES%,dpkg,debhelper,strip-nondeterminism,debconf,dh-exec
SET PACKAGES=%PACKAGES%,dctrl-tools,recutils,info2www,cdbs,publib-dev
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

IF EXIST %TMPDIR% (
	ECHO *** SKIP PACKAGE DOWNLOAD %TMPDIR%
) ELSE (
	ECHO *** DOWNLOAD PACKAGES
	%SETUP% --verbose --quiet-mode --include-source --download --local-package-dir %PKGDIR% --root %ROOT% --packages %PACKAGES% --only-site --no-verify --site %REPOSITORY%
)

SET SITE=Z:/Y%%3a%%2f
SET REPOSITORY=Y:/
IF EXIST %SITE% (
	ECHO *** LOCAL PACKAGE DIRECTORY EXISTS %SITE%
) ELSE (
	ECHO *** CREATE LOCAL PACKAGE DIRECTORY
	SUBST Y: %TMPDIR%
	%SETUP% --verbose --quiet-mode --include-source --download --local-package-dir %PKGDIR% --root %ROOT% --packages %PACKAGES% --only-site --no-verify --site %REPOSITORY%
	SUBST /D Y:
)

SET PKGDIR=%SITE%
IF EXIST %ROOT% (
	ECHO *** ROOT DIRECTORY EXISTS %ROOT%
) ELSE (
	ECHO *** INSTALL PACKAGES
	%SETUP% --quiet-mode --no-startmenu --no-desktop --disable-buggy-antivirus --local-install --local-package-dir %PKGDIR% --root %ROOT% --packages %PACKAGES%
)
ECHO.

SUBST /D Z:
