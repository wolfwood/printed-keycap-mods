OPENSCAD=openscad
SCADFLAGS = -q --hardwarnings

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

# speeds up trackpoint notch cutting by more than an order of magnitude,
# small time delay otherwise
PRERENDERED=1

# stl or 3mf are most common
FORMAT = 3mf

KEYBOARD != perl -n -e'/^keyboard\s*=\s*"(\S+)"/ && print $$1' < settings.scad

most: lpx cs des-ulp

choc:lpx cs lpx-offset des-lp des-ulp

mx: lpxmx

tp: lpx cs-tp des-lp-tp des-ulp-tp

all: most choc mx lpx-offset tp

.PHONY: lpx most cs des-lp des-ulp choc mx all raw raw-cs raw-des-lp raw-des-ulp

lpx: things/LPX-$(KEYBOARD)-near.$(FORMAT) things/LPX-$(KEYBOARD)-far.$(FORMAT)

LPXMX=things/LPxMX.$(FORMAT)
lpxmx: $(LPXMX)

OFFSET=1.0 0.5
LPXOFFSET=$(addsuffix .$(FORMAT),$(addprefix things/LPX-offset-,$(OFFSET)))
lpx-offset: $(LPXOFFSET)

KEYS=R2 R3 R4 R3-homing
LATS=R2L R3L R4L R2R R3R R4R R3L-homing R3R-homing
TPKEYS=R2-SE R2-SW R3-NE R3-NW
#R2-SE R2-SW R3-NE R3-NW R3-SE R3-SW R4-NE R4-NW R3-homing-NE R3-homing-NW R3-homing-SE R3-homing-SW
TPLATS=R2L-SE R2R-SW R3L-NE R3R-NW
#R2L-SE R2L-SW R2R-SE R2R-SW R3L-NE R3L-NW R3L-SE R3R-SW R3R-NE R3R-NW R3R-SE R3R-SW R4L-NE R4L-NW R4R-NE R4R-NW R3L-homing-NE R3L-homing-NW R3L-homing-SE R3L-homing-SW R3R-homing-NE R3R-homing-NW R3R-homing-SE R3R-homing-SW

# for CS R4 R2R R3R and R4R are mostly redundant for printing, but including them is less surprising
CS_PROFILE=$(KEYS) $(LATS) T1L T1R T0L T0R R3x T015L T015R T0175L T0175R T02L T02R T15L T15R TW15L TW15R TW015L TW015R
CS_TP_PROFILE=$(TPKEYS) $(TPLATS)

CS_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/CS-,$(CS_PROFILE)))
CS_TP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/CS-,$(CS_TP_PROFILE)))

cs: $(CS_TARGETS)
cs-tp: $(CS_TP_TARGETS)

CS/CS.scad: includes/PseudoMakeMeKeyCapProfiles/skin.scad includes/PseudoMakeMeKeyCapProfiles/sweep.scad

DES_LP_PROFILE=$(KEYS) # R1 R5
DES_LP_TP_PROFILE= $(TPKEYS)

DES_LP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/DES-LP-,$(DES_LP_PROFILE)))
DES_LP_TP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/DES-LP-,$(DES_LP_TP_PROFILE)))

des-lp: $(DES_LP_TARGETS)
des-lp-tp: $(DES_LP_TP_TARGETS)

DES_ULP_PROFILE=$(KEYS) $(LATS)
DES_ULP_TP_PROFILE=$(TPKEYS) $(TPLATS)

DES_ULP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/DES-uLP-,$(DES_ULP_PROFILE)))
DES_ULP_TP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/DES-uLP-,$(DES_ULP_TP_PROFILE)))

des-ulp: $(DES_ULP_TARGETS)
des-ulp-tp: $(DES_ULP_TP_TARGETS)


RAW_CS_PROFILE=$(CS_PROFILE)
RAW_CS_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/CS/,$(RAW_CS_PROFILE)))
RAW_CS_TP_PROFILE=$(TPKEYS) $(TPLATS)
RAW_CS_TP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/CS/,$(RAW_CS_TP_PROFILE)))

raw-cs: $(RAW_CS_TARGETS)
raw-cs-tp: $(RAW_CS_TP_TARGETS)

RAW_DES_LP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/DES-LP/,$(DES_LP_PROFILE)))
RAW_DES_LP_TP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/DES-LP/,$(DES_LP_TP_PROFILE)))

raw-des-lp: $(RAW_DES_LP_TARGETS)
raw-des-lp-tp: $(RAW_DES_LP_TP_TARGETS)

RAW_DES_ULP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/DES-uLP/,$(DES_ULP_PROFILE)))
RAW_DES_ULP_TP_TARGETS=$(addsuffix .$(FORMAT),$(addprefix $(RAWDIR)/DES-uLP/,$(DES_ULP_TP_PROFILE)))

raw-des-ulp: $(RAW_DES_ULP_TARGETS)
raw-des-ulp-tp: $(RAW_DES_ULP_TP_TARGETS)

raw: raw-cs raw-des-lp raw-des-ulp
raw-tp: raw-cs-tp raw-des-lp-tp raw-des-ulp-tp


things/:
	mkdir -p $@

$(RAWDIR)/%/:
	mkdir -p $@

-include .*.depends


things/LPX-$(KEYBOARD)-near.$(FORMAT): LPX/LPX.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .lpx-near.depends -Dfar=false -o $@ $<

things/LPX-$(KEYBOARD)-far.$(FORMAT): LPX/LPX.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .lpx-far.depends -Dfar=true -o $@ $<

things/LPxMX.$(FORMAT): LPX/MX.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .lpxmx.depends -o $@ $<

things/LPX-offset-%.$(FORMAT): LPX/LPX.scad
	$(OPENSCAD) $(SCADFLAGS) --render -d .lpx-offset-$*.depends -Dspeed=false -Doffset=$* -o $@ $<

ifndef PRERENDERED
things/CS-%.$(FORMAT): CS/CS.scad | things/
	$(OPENSCAD) $(SCADFLAGS) --render -d .cs-$*.depends -Dkeycap=\"$*\" -Dprerendered=false -o $@ $<


things/DES-LP-%.$(FORMAT): DES-LP/DES-LP.scad | things/
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-lp-$*.depends -Dkeycap=\"$*\" -Dprerendered=false -o $@ $<


things/DES-uLP-%.$(FORMAT): DES-uLP/DES-uLP.scad | things/
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-ulp-$*.depends -Dkeycap=\"$*\" -Dprerendered=false -o $@ $<

else
.SECONDEXPANSION:
things/CS-%.$(FORMAT): CS/CS.scad $(RAWDIR)/CS/$$(subst -NW,,$$(subst -NE,,$$(subst -SW,,$$(subst -SE,,%)))).$(FORMAT) | things/
	$(OPENSCAD) $(SCADFLAGS) --render -d .cs-$*.depends -Dkeycap=\"$*\" -Dprerendered=true -Drawdir=\"$(RAWDIR)\" -Dformat=\"$(FORMAT)\" -o $@ $<


.SECONDEXPANSION:
things/DES-LP-%.$(FORMAT): DES-LP/DES-LP.scad $(RAWDIR)/DES-LP/$$(subst -NW,,$$(subst -NE,,$$(subst -SW,,$$(subst -SE,,%)))).$(FORMAT) | things/
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-lp-$*.depends -Dkeycap=\"$*\" -Dprerendered=true -Drawdir=\"$(RAWDIR)\" -Dformat=\"$(FORMAT)\" -o $@ $<


.SECONDEXPANSION:
things/DES-uLP-%.$(FORMAT): DES-uLP/DES-uLP.scad $(RAWDIR)/DES-uLP/$$(subst -NW,,$$(subst -NE,,$$(subst -SW,,$$(subst -SE,,%)))).$(FORMAT) | things/
	$(OPENSCAD) $(SCADFLAGS) --render -d .des-ulp-$*.depends -Dkeycap=\"$*\" -Dprerendered=true -Drawdir=\"$(RAWDIR)\" -Dformat=\"$(FORMAT)\" -o $@ $<
endif

$(RAWDIR)/CS/%.$(FORMAT): CS/CS.scad | $(RAWDIR)/CS/
	$(OPENSCAD) $(SCADFLAGS) --render -d .raw-cs-$*.depends -Dkeycap=\"$*\" -Draw=true -Dprerendered=false -o $@ $<

$(RAWDIR)/DES-LP/%.$(FORMAT): DES-LP/DES-LP.scad | $(RAWDIR)/DES-LP/
	$(OPENSCAD) $(SCADFLAGS) --render -d .raw-des-lp-$*.depends -Dkeycap=\"$*\" -Draw=true -Dprerendered=false -o $@ $<

$(RAWDIR)/DES-uLP/%.$(FORMAT): DES-uLP/DES-uLP.scad | $(RAWDIR)/DES-uLP/
	$(OPENSCAD) $(SCADFLAGS) --render -d .raw-des-ulp-$*.depends -Dkeycap=\"$*\" -Draw=true -Dprerendered=false -o $@ $<



includes/PseudoMakeMeKeyCapProfiles/skin.scad: includes/PseudoMakeMeKeyCapProfiles/list-comprehension-demos/skin.scad
	cp $< $@

includes/PseudoMakeMeKeyCapProfiles/sweep.scad: includes/PseudoMakeMeKeyCapProfiles/list-comprehension-demos/sweep.scad
	cp $< $@


clean:
	-rm .*.depends $(LPXMX) $(LPXOFFSET) $(CS_TARGETS) $(CS_TP_TARGETS) $(DES_LP_TARGETS) $(DES_LP_TP_TARGETS) $(DES_ULP_TARGETS) $(DES_ULP_TP_TARGETS) things/LPX-$(KEYBOARD)-near.$(FORMAT) things/LPX-$(KEYBOARD)-far.$(FORMAT)

image:
	exiftool -overwrite_original -recurse -EXIF= images
	cd images; find . -iname '*.png' -print0 | xargs -0 optipng -o7 -preserve
	cd images; find . -iname '*.jpg' -print0 | xargs -0 jpegoptim --max=90 --strip-all --preserve --totals --all-progressive
