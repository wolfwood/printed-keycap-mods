OPENSCAD=openscad
SCADFLAGS = -q #--hardwarnings

RAWDIR=things/raw

MANIFOLD_FEATURE := $(shell $(OPENSCAD) --version --enable manifold > /dev/null 2>&1; echo $$?)
MANIFOLD_BACKEND := $(shell $(OPENSCAD) --version --backend manifold > /dev/null 2>&1; echo $$?)

ifeq ($(MANIFOLD_BACKEND), 0)
    SCADFLAGS += --backend manifold
else
ifeq ($(MANIFOLD_FEATURE), 0)
    SCADFLAGS += --enable manifold
endif
endif

# stl or 3mf are most common
FORMAT = 3mf

KEYBOARD != perl -n -e'/^keyboard\s*=\s*"(\S+)"/ && print $$1' < settings.scad

most: lpx cs-middle cs-index

choc:lpx cs lpx-offset

mx: lpxmx

all: most choc mx cs-middle-solo cs-index-solo lpx-offset

.PHONY: lpx cs-middle cs-index most cs cs-middle-solo cs-index-solo choc mx all

lpx: things/LPX-$(KEYBOARD)-near.$(FORMAT) things/LPX-$(KEYBOARD)-far.$(FORMAT)

LPXMX=things/LPxMX.$(FORMAT)
lpxmx: $(LPXMX)

OFFSET=1.0 0.5
LPXOFFSET=$(addsuffix .$(FORMAT),$(addprefix things/LPX-offset-,$(OFFSET)))
lpx-offset: $(LPXOFFSET)

TPKEYS=R3-homing R3 R2-near R2-far

cs-middle: things/CS-$(KEYBOARD)-middle-array.$(FORMAT)

cs-middle-solo: $(addsuffix .$(FORMAT),$(addprefix things/CS-$(KEYBOARD)-middle-,$(TPKEYS)))

cs-index: things/CS-$(KEYBOARD)-index-array.$(FORMAT)

cs-index-solo: $(addsuffix .$(FORMAT),$(addprefix things/CS-$(KEYBOARD)-index-,$(TPKEYS)))

CS_TP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/CS-$(KEYBOARD)-middle-,$(TPKEYS))) $(addsuffix .$(FORMAT),$(addprefix things/CS-$(KEYBOARD)-index-,$(TPKEYS)))

# skipping redundant key sculpts: R4 R2R R3R R4R
CS_PROFILE=R2 R3 R3-homing R2L R3L R4L T1L T1R T0L T0R R3x T015L T015R T0175L T0175R T02L T02R T15L T15R TW15L TW15R TW015L TW015R

CS_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/CS-,$(CS_PROFILE)))

cs: $(CS_TARGETS)

CS/CS.scad: includes/PseudoMakeMeKeyCapProfiles/skin.scad includes/PseudoMakeMeKeyCapProfiles/sweep.scad

DES_PROFILE=R2 R3 R3-homing R4 # R1 R5

DES_LP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/DES-LP-,$(DES_PROFILE)))

des-lp: $(DES_LP_TARGETS)

DES_ULP_PROFILE=R2 R3 R3-homing R4 R2L R3L R4L R2R R3R R4R

DES_ULP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/DES-uLP-,$(DES_ULP_PROFILE)))

des-ulp: $(DES_ULP_TARGETS)

des-ulp-index: things/DES-uLP-$(KEYBOARD)-index-array.$(FORMAT)

des-ulp-index-solo: $(addsuffix .$(FORMAT),$(addprefix things/DES-uLP-$(KEYBOARD)-index-,$(TPKEYS)))


RAW_CS_PROFILE=$(CS_PROFILE) R4 R4R
RAW_CS_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/CS/,$(RAW_CS_PROFILE)))

raw-cs: $(RAW_CS_TARGETS)

RAW_DES_LP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/DES-LP/,$(DES_PROFILE)))

raw-des-lp: $(RAW_DES_LP_TARGETS)

RAW_DES_ULP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/DES-uLP/,$(DES_ULP_PROFILE)))

raw-des-ulp: $(RAW_DES_ULP_TARGETS)

raw: raw-cs raw-des-lp raw-des-ulp

$(RAWDIR)/%/:
	mkdir -p $@

-include .*.depends


things/LPX-$(KEYBOARD)-near.$(FORMAT): LPX/LPX.scad
	$(OPENSCAD) $(SCADFLAGS) --hardwarnings --render -d .lpx-near.depends -Dfar=false -o $@ $<

things/LPX-$(KEYBOARD)-far.$(FORMAT): LPX/LPX.scad
	$(OPENSCAD) $(SCADFLAGS) --hardwarnings --render -d .lpx-far.depends -Dfar=true -o $@ $<

things/CS-$(KEYBOARD)-middle-array.$(FORMAT): CS/CS.scad
	$(OPENSCAD) $(SCADFLAGS) --render  -d .cs-middle-array.depends -Dindex=false -o $@ $<

things/CS-$(KEYBOARD)-index-array.$(FORMAT): CS/CS.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .cs-index-array.depends -Dindex=true -o $@ $<

things/CS-$(KEYBOARD)-middle-%.$(FORMAT): CS/CS.scad
	$(OPENSCAD) $(SCADFLAGS) --render  -d .cs-middle-$*.depends -Dindex=false  -Dtpkey=\"$*\" -o $@ $<

things/CS-$(KEYBOARD)-index-%.$(FORMAT): CS/CS.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .cs-index-$*.depends -Dindex=true -Dtpkey=\"$*\" -o $@ $<


things/LPxMX.$(FORMAT): LPX/MX.scad
	$(OPENSCAD) $(SCADFLAGS) --hardwarnings --render -d .lpxmx.depends -o $@ $<


things/LPX-offset-%.$(FORMAT): LPX/LPX.scad
	$(OPENSCAD) $(SCADFLAGS) --hardwarnings --render -d .lpx-offset-$*.depends -Dspeed=false -Doffset=$* -o $@ $<


things/CS-%.$(FORMAT): CS/CS.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .cs-$*.depends -Dkeycap=\"$*\" -o $@ $<

things/DES-LP-%.$(FORMAT): DES-LP/DES-LP.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-lp-$*.depends -Dkeycap=\"$*\" -o $@ $<


things/DES-uLP-%.$(FORMAT): DES-uLP/DES-uLP.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-ulp-$*.depends -Dkeycap=\"$*\" -o $@ $<


things/DES-uLP-$(KEYBOARD)-index-array.$(FORMAT): DES-uLP/DES-uLP.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-ulp-index-array.depends -Dindex=true -o $@ $<

things/DES-uLP-$(KEYBOARD)-index-%.$(FORMAT): DES-uLP/DES-uLP.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-ulp-index-$*.depends -Dindex=true -Dtpkey=\"$*\" -o $@ $<


$(RAWDIR)/CS/%.$(FORMAT): CS/CS.scad | $(RAWDIR)/CS/
	$(OPENSCAD) $(SCADFLAGS) --render -d .cs-$*.depends -Dkeycap=\"$*\" -Draw=true -o $@ $<

$(RAWDIR)/DES-LP/%.$(FORMAT): DES-LP/DES-LP.scad | $(RAWDIR)/DES-LP/
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-lp-$*.depends -Dkeycap=\"$*\" -Draw=true -o $@ $<

$(RAWDIR)/DES-uLP/%.$(FORMAT): DES-uLP/DES-uLP.scad | $(RAWDIR)/DES-uLP/
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-ulp-$*.depends -Dkeycap=\"$*\" -Draw=true -o $@ $<



includes/PseudoMakeMeKeyCapProfiles/skin.scad: includes/PseudoMakeMeKeyCapProfiles/list-comprehension-demos/skin.scad
	cp $< $@

includes/PseudoMakeMeKeyCapProfiles/sweep.scad: includes/PseudoMakeMeKeyCapProfiles/list-comprehension-demos/sweep.scad
	cp $< $@


clean:
	-rm .*.depends $(LPXMX) $(LPXOFFSET) $(CS_TARGETS) $(CS_TP_TARGETS) things/CS-$(KEYBOARD)-middle-array.$(FORMAT) things/CS-$(KEYBOARD)-index-array.$(FORMAT) things/LPX-$(KEYBOARD)-near.$(FORMAT) things/LPX-$(KEYBOARD)-far.$(FORMAT)

image:
	exiftool -overwrite_original -recurse -EXIF= images
	cd images; find . -iname '*.png' -print0 | xargs -0 optipng -o7 -preserve
	cd images; find . -iname '*.jpg' -print0 | xargs -0 jpegoptim --max=90 --strip-all --preserve --totals --all-progressive
