# This makefile builds cygwin packages from debian source
# The debian package names are phony targets of this makefile
# The process is simulated with make --dry-run
# Additional information is printed with make --trace 

.DEFAULT_GOAL = .

${.DEFAULT_GOAL}: \
	publib-dev \
	sensible-utils \
	autotools-dev \
	docx2txt \
	doc-base \
	automake \
	dh-exec \
	po-debconf \
	intltool-debian \
	debconf \
	dpkg \

# Grep MAKECMDGOAL from Packages
CYGPORT=$(shell \
	grep ^Package:\\\|^Version:\\\|^Architecture: Packages | \
	sed /^Version:\ /aRELEASE=1 | \
	sed '1h;1d;5~4x;$G' | \
	sed '1h;1d;5~4x;$G' | \
	sed '1h;1d;5~4x;$G' | \
	sed '1~4h;4~4G' | \
	sed \
		-e 1~5s/amd64\\\|any/x86/ \
		-e 5~5s/amd64\\\|any/i686/ \
		-e s/Package:\ /NAME=/p \
		-e s/Version:\ /VERSION=/ \
		-e /^Architecture:\ /s/all/noarch/ \
		-e s/Architecture:\ /ARCHITECTURE=/ \
		| \
	tr =: \\\t\\\t | \
	paste - - - - - - | \
	cut -f2,4,6,8,10,12 | \
	sed \
		-e s@^@Y%3a%2f/@ \
		-e s@\\\t@/release/@ \
		-e s@\\\t@/@ \
		-e s@\\\t@_@ \
		-e s@\\\t@_@ \
		-e s@\\\t@.@ | \
	grep "$(MAKECMDGOALS)" | \
	head -n1 \
	)

# Get a list f debian binary packages
Packages:
	wget -O- -c \
	http://deb.debian.org/debian/dists/stable/main/binary-amd64/Packages.gz | \
	gunzip > $@

# Get a list of debian source packages
Sources:
	wget -O- -c \
	http://deb.debian.org/debian/dists/stable/main/source/Sources.gz | \
	gunzip > $@

# Source description is downloaded with debian packages
.PRECIOUS: %.dsc

# Some %.cygport are customised to the build process
.PRECIOUS: %.cygport

# Default rule
.DEFAULT: Packages Sources
	$(MAKE) $(CYGPORT)

# Create %.cygport files from debian data
%.cygport: Packages
	mkdir $(@D) && \
	grep-dctrl -r -n -s Package -F Package ^$(notdir $(basename $@)) Packages | \
	xargs sh cygport.sh > $@ || { rm $@ && exit 1 ; }

# Download %.dsc files
%.dsc:
	$(MAKE) $(word 1, $(subst _, ,$(subst \,, $@))).cygport
	cygport --32 $(word 1, $(subst _, , $(subst \,, $@))).cygport download

# Download %.dsc and build %.noarch and %.i686 package with cygport
%.i686 %.noarch:
	$(MAKE) $(@D)/$(word 1, $(subst _, , $(@F)))_$(word 2, $(subst _, , $(@F))).dsc
	cygport --32 $(word 1, $(subst _, , $(subst \,, $@))).cygport all
	rename --verbose $(subst _,-,$(subst \,, $@)) $(subst \,, $@) $(subst _,-,$(subst \,, $@))

# Template rule with prerequisites
define TEMPLATE =
.INTERMEDIATE: $1
.PHONY: $(word 1, $(subst _, , $(notdir $1)))
$(word 1, $(subst _, , $(notdir $1))): %: $(dir $1)%.cygport $1 Packages
	cat $$< | grep ^NAME\\\|^VERSION\\\|RELEASE\\\|^ARCH | \
	cut -d= -f2 | paste - - - - | xargs -L4 printf \
	$$(dir $(subst \,\\\,$1))%s_%s_%s.%s\\\n | xargs $$(MAKE)
	mv -v $1/dist/$$(basename $$(<F))/*.* $(dir $1) && \
	rm -rf $1
endef

# Grep data of Debian Packages
$(foreach x, $(CYGPORT), $(eval $(call TEMPLATE,$(subst %,\%,$(x)))) \)

