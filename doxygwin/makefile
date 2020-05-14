# This makefile builds cygwin packages from debian source
# The debian package names are phony targets of this makefile
# The process is simulated with make --dry-run
# Additional information is printed with make --trace 

.DEFAULT_GOAL = .

${.DEFAULT_GOAL}: \
	strip-nondeterminism \
	cygport \
	calm \
	dh-autoreconf \
	sensible-utils \
	autotools-dev \
	debconf \
	docx2txt \
	debhelper \
	doc-base \
	automake \
	po-debconf \
	intltool-debian \
	dpkg \

# Get a list of debian binary packages
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
	grep-dctrl -n -s Package -F Package $(notdir $(basename $@)) Packages | \
	xargs sh cygport.sh > $@ || { rm $@ && exit 1 ; }

# Download %.dsc files
%.dsc:
	$(MAKE) $(word 1, $(subst _, ,$@)).cygport
	cygport --32 $(word 1, $(subst _, , $@)).cygport download

# Grep debian data and make template
.DEFAULT: Packages Sources
	sh cygport.sh $@ | \
	grep ^NAME\\\|^VERSION\\\|RELEASE\\\|^ARCH | \
	tr = \\\t | paste - - - - | cut -f2,4,6,8 | xargs | \
	sed -e s/noarch/\&\\\t\&/ -e s/i686/\&\\\tx86/ | \
	while read A B C D E ; \
	do \
		test -n "$${A}" && test -n "$${B}" && \
		test -n "$${C}" && test -n "$${D}" && test -n "$${E}" && \
		$(MAKE) "Y%3a%2f/$${E}/release/$${A}/$${A}_$${B}_$${C}.$${D}" ; \
	done ; \

# Download %.dsc and build %.noarch and %.i686 package with cygport
%.i686 %.noarch:
	$(MAKE) $(@D)/$(word 1, $(subst _, , $(@F)))_$(word 2, $(subst _, , $(@F))).dsc
	cygport --32 $(word 1, $(subst _, , $@)).cygport all
	rename --verbose $(subst _,-,$@) $@ $(subst _,-,$@)

# Template rule with prerequisites
define TEMPLATE =
.INTERMEDIATE: $1
.PHONY: $(word 1, $(subst _, , $(notdir $1)))
$(word 1, $(subst _, , $(notdir $1))): %: $(dir $1)%.cygport $1
	cat $$< | grep ^NAME\\\|^VERSION\\\|RELEASE\\\|^ARCH | \
	cut -d= -f2 | paste - - - - | xargs -L4 printf \
	$$(dir $(subst \,\\\,$1))%s_%s_%s.%s\\\n | xargs $$(MAKE)
	mv $1/dist/$$(basename $$(<F))/* $(dir $1) || true
	rm -rf $1
endef
#
# Find predefined %.cygport files to build a package
$(foreach x,$(shell \
	find Y%3a%2f/ \
		-maxdepth 4 \
		-name \*.cygport \
		-printf %h/%f\\\n | \
	xargs -I@ grep -H ^NAME\\\|^VERSION\\\|RELEASE\\\|^ARCH @ | \
	tr =: \\\t\\\t | \
	paste - - - - | \
	cut -f1,3,6,9,12 | \
	xargs -r -L1 | \
	while read A B C D E ; \
	do \
		echo "$$(dirname $${A})/$${B}_$${C}_$${D}.$${E}" ; \
	done ; \), \
	$(eval $(call TEMPLATE,$(subst %,\%,$(x)))) \
)

