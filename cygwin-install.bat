@ECHO OFF
REM -- Automates cygwin installation
 
SETLOCAL
REM -- Configure our paths
REM SET SITE=http://cygwin.mirrors.pair.com/
SET SITE=http://ftp.jaist.ac.jp/pub/cygwin/
SET LOCALDIR=%~dp0

REM -- Download setup-x86-2.874.exe from web archive
cscript %LOCALDIR%\download.vbs https://web.archive.org/web/20160820100148/http://cygwin.com/setup-x86.exe

REM -- This site is for Microsoft Windows XP
REM https://web.archive.org/web/20160820100148/http://cygwin.com/setup-x86.exe
REM http://www.crouchingtigerhiddenfruitbat.org/cygwin/timemachine.html
REM http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2016/08/30/104223/setup.ini
SET SITE=http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2016/08/30/104223
SET SETUP=%CD%\setup-x86.exe
SET ROOT=c:\cygwin

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=%PACKAGES%,httpd,cron,po4a,docbook-xml45,libcrypt-devel,lynx
SET PACKAGES=%PACKAGES%,perl-MIME-Types,poppler,antiword,xlsx2csv,wv,links
SET PACKAGES=%PACKAGES%,bash,tig,tmux,vim,w3m,mc,bc,gnumeric
SET PACKAGES=%PACKAGES%,procmail,mailutils,lftp,fdupes
SET PACKAGES=%PACKAGES%,sqlite3,tcl-sqlite3,git,wget,openssh,patch,sed
SET PACKAGES=%PACKAGES%,gcc-g++,gcc-fortran,gdb,gperf,flex,bison,ctags
SET PACKAGES=%PACKAGES%,cmake,dejagnu,make,pkg-config,gettext,check
SET PACKAGES=%PACKAGES%,git-svn,subversion,mercurial,quilt,stgit
SET PACKAGES=%PACKAGES%,mutt,irssi,dialog,procps,stow,ccache
SET PACKAGES=%PACKAGES%,autoconf,automake,autogen,autopoint
SET PACKAGES=%PACKAGES%,intltool,libtool,libtool-bin,libtoolize
SET PACKAGES=%PACKAGES%,lua,perl,perl_manpages,perl-Archive-Zip
SET PACKAGES=%PACKAGES%,bzip2,openssl,p7zip,unzip,xz-utils,zip
SET PACKAGES=%PACKAGES%,clear,file,less,openssh,pinfo,rxvt,wget
SET PACKAGES=%PACKAGES%,inetutils,socat,curl,xinetd,tcp_wrappers
SET PACKAGES=%PACKAGES%,busybox,pandoc,recutils,expat,moreutils
SET PACKAGES=%PACKAGES%,cygport,cygwin-devel,calm,cygwin-doc
SET PACKAGES=%PACKAGES%,ncurses,libncurses-devel
SET PACKAGES=%PACKAGES%,meson,robodoc,help2man,asciidoc
::SET PACKAGES=%PACKAGES%,python,ruby,scons
::SET PACKAGES=%PACKAGES%,ucl,libgdk_pixbuf2.0-devel
::SET PACKAGES=%PACKAGES%,postgresql,expat,libexpat-devel
::SET PACKAGES=%PACKAGES%,octave,octave-doc,gnuplot,gnuplot-doc,sox
::SET PACKAGES=%PACKAGES%,xorg-server,xorg-docs,xinit,xterm,WindowMaker
::SET PACKAGES=%PACKAGES%,libxml-parser-perl,libffi-dev,libltdl-dev,libssl-dev
::SET PACKAGES=%PACKAGES%,xf86-video-dummy,yasm-devel
::SET PACKAGES=%PACKAGES%,libxml-parser-perl,libffi-dev,libltdl-dev,libssl-dev
::SET PACKAGES=%PACKAGES%,libSDL2-devel,libopenal-devel,libmpg123-devel
 
REM -- Do it!
ECHO *** DOWNLOADING CUSTOM PACKAGES
"%SETUP%" --verbose --include-source --quiet-mode --no-desktop --download --no-verify --only-site --site %SITE% --local-package-dir "%LOCALDIR%\setup" --root "%ROOT%" --packages %PACKAGES% 
ECHO.
ECHO.
ECHO *** INSTALLING CUSTOM PACKAGES

"%SETUP%" --verbose --quiet-mode --no-verify --disable-buggy-antivirus --local-install --local-package-dir "%LOCALDIR%\setup" --root "%ROOT%" --packages %PACKAGES%
 
REM -- Show what we did
ECHO.
ECHO.
ECHO cygwin installation updated
ECHO  - %PACKAGES%
ECHO.

