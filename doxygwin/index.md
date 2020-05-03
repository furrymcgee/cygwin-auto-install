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

- https://github.com/furrymcgee/cygwin-auto-install

BUILD
-----

Execute following commands to build the project. The typescript file contains
a log of autogen.sh build script.

.Building
[source,sh]
-----
# Checkout source code
git clone --recursive https://github.com/furrymcgee/doxygwin
cd doxygwin
# Execute autogen.sh and write typescript
script -c bash\ -ex < autogen.sh
-----

TODO
----

Create Cygport packages for binary distribution.


