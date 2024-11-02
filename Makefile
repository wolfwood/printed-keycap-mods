OPENSCAD=openscad
SCADFLAGS = -q #--hardwarnings

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
CS_PROFILE=R2 R3 R3-homing R2L R3L R4L T1L T1R R3x

CS_TARGETS=$(addsuffix .$(FORMAT),$(addprefix things/CS-,$(CS_PROFILE)))

cs: $(CS_TARGETS)

CS/CS.scad: includes/PseudoMakeMeKeyCapProfiles/skin.scad includes/PseudoMakeMeKeyCapProfiles/sweep.scad

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
