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

# Create %.cygport files from debian data
%.cygport: Packages
	mkdir $(@D) && \
	grep-dctrl -r -n -s Package -F Package ^$(notdir $(basename $@)) Packages | \
	xargs sh cygport.sh > $@ || { rm $@ && exit 1 ; }

# Template rule with prerequisites
define CYGPORT =
$(eval $(call TEMPLATE,$(shell \
	cat Packages | \
	grep ^Package:\\\|^Version:\\\|^Architecture: | \
	sed /^Version:\ /aRELEASE=1 | \
	sed '1h;1d;5~4x;$$G' | \
	sed '1h;1d;5~4x;$$G' | \
	sed '1h;1d;5~4x;$$G' | \
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
	grep "$1" | \
	head -n1 \
)))
endef

# Template rule with prerequisites
define TEMPLATE =
$(info Template: $1)

#.INTERMEDIATE: $1
.PHONY: $(word 1, $(subst _, , $(notdir $1)))

# Download package files
%_$(word 2, $(subst _, ,$1)).dsc: %.cygport
	cygport --32 $$< download

# Build package with cygport
%_$(word 2, $(subst _, ,$1))_$(word 3, $(subst _, ,$1)): %.cygport
	cygport --32 $$< all
	rename --verbose $(subst _,-,$1) $1 $(subst _,-,$1)

$(word 1, $(subst _, , $(notdir $1))): $(word 1, $(subst _, ,$1))_$(word 2, $(subst _, ,$1)).dsc $1
	cat $$< | grep ^NAME\\\|^VERSION\\\|RELEASE\\\|^ARCH | \
	cut -d= -f2 | paste - - - - | xargs -r -L3 printf \
	$$(dir $(subst \,\\\,$1))%s_%s_%s.%s\\\n | xargs -r $(MAKE) 
	mv -v $1/dist/$$@/*.* $(dir $1) && \
	rm -rf $1

endef

# Grep MAKECMDGOALS from Packages
ifeq (0,${MAKELEVEL})
$(foreach x, $(MAKECMDGOALS), $(eval $(call CYGPORT,$(x))))
endif



