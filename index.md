DOXIE
-----

Doxie Search is a search engine for your office documents and emails on
Windows. A typical system has documentation in many formats (docx, pdf, email,
...). The Doxie Search finds all of them in a web browser.

Doxie Search is based on dwww and other Debian packages ported to Cygwin:
"All installed on-line documentation will be served via a local HTTP
server at http://localhost/dwww/. This package runs cron scripts to
convert available resources to the HTML pages.  Executing the dwww
command starts a sensible WWW browser locally to access them."

REQUIREMENTS
------------

A Cygwin installation is required for building and installation. Please see
link below how to install required Cygwin packages with cygwin-auto-install.
CPAN access is also required to build and install Doxie Search.

INSTALL
-------

Download scripts and packages from repository.

- https://github.com/furrymcgee/cygwin-auto-install

BOOTSTRAP
---------

Install dpkg and cygport to build packages from debian sources.

.Bootstrap
[source,sh]
-----
source bootstrap.sh
-----


SETUP
-----

Execute following commands to create a setup.ini file.
The typescript file contains a log of the autogen.sh build script.

.Setup
[source,sh]
-----
# Checkout source code
git clone --recursive https://github.com/furrymcgee/doxygwin
# Change to submodule
cd doxygwin/cygwin-auto-install/doxygwin/Y%3a%2f
# Execute autogen.sh and write typescript
printf %q\\\n source\ ../autogen.sh |
script -c bash\ -ex
-----


