OPENSCAD=openscad
KEYBOARD != perl -n -e'/^keyboard\s*=\s*"(\S+)"/ && print $$1' < settings.scad

most: lpx cs-middle cs-index

choc:lpx cs lpx-offset

mx: lpxmx

all: most choc mx cs-middle-solo cs-index-solo lpx-offset

.PHONY: lpx cs-middle cs-index most cs cs-middle-solo cs-index-solo choc mx all

lpx: things/LPX-$(KEYBOARD)-near.stl things/LPX-$(KEYBOARD)-far.stl

LPXMX=things/LPxMX.stl things/LPxMX-speed.stl
lpxmx: $(LPXMX)

OFFSET=1.0 0.5
LPXOFFSET=$(addsuffix .stl,$(addprefix things/LPX-offset-,$(OFFSET)))
lpx-offset: $(LPXOFFSET)

TPKEYS=R3-homing R3 R2-near R2-far

cs-middle: things/CS-$(KEYBOARD)-middle-array.stl

cs-middle-solo: $(addsuffix .stl,$(addprefix things/CS-$(KEYBOARD)-middle-,$(TPKEYS)))

cs-index: things/CS-$(KEYBOARD)-index-array.stl

cs-index-solo: $(addsuffix .stl,$(addprefix things/CS-$(KEYBOARD)-index-,$(TPKEYS)))

CS_TP_TARGETS=$(addsuffix .stl,$(addprefix things/CS-$(KEYBOARD)-middle-,$(TPKEYS))) $(addsuffix .stl,$(addprefix things/CS-$(KEYBOARD)-index-,$(TPKEYS)))

# skipping redundant key sculpts: R4 R2R R3R R4R
CS_PROFILE=R2 R3 R3-homing R2L R3L R4L T1L T1R R3x

CS_TARGETS=$(addsuffix .stl,$(addprefix things/CS-,$(CS_PROFILE)))

cs: $(CS_TARGETS)

CS/CS.scad: CS/PseudoMakeMeKeyCapProfiles/skin.scad CS/PseudoMakeMeKeyCapProfiles/sweep.scad

-include .*.depends


things/LPX-$(KEYBOARD)-near.stl: LPX/LPX.scad
	$(OPENSCAD) -q --hardwarnings --render -d .lpx-near.depends -Dfar=false -o $@ $<

things/LPX-$(KEYBOARD)-far.stl: LPX/LPX.scad
	$(OPENSCAD) -q --hardwarnings --render -d .lpx-far.depends -Dfar=true -o $@ $<

things/CS-$(KEYBOARD)-middle-array.stl: CS/CS.scad
	$(OPENSCAD) -q --render  -d .cs-middle-array.depends -Dindex=false -o $@ $<

things/CS-$(KEYBOARD)-index-array.stl: CS/CS.scad
	$(OPENSCAD) -q --render -d .cs-index-array.depends -Dindex=true -o $@ $<

things/CS-$(KEYBOARD)-middle-%.stl: CS/CS.scad
	$(OPENSCAD) -q --render  -d .cs-middle-$*.depends -Dindex=false  -Dtpkey=\"$*\" -o $@ $<

things/CS-$(KEYBOARD)-index-%.stl: CS/CS.scad
	$(OPENSCAD) -q --render -d .cs-index-$*.depends -Dindex=true -Dtpkey=\"$*\" -o $@ $<


things/LPxMX.stl: LPX/MX.scad
	$(OPENSCAD) -q --hardwarnings --render -d .lpxmx.depends -Dspeed=false -o $@ $<

things/LPxMX-speed.stl: LPX/MX.scad
	$(OPENSCAD) -q --hardwarnings --render -d .lpxmx-speed.depends -Dspeed=true -o $@ $<


things/LPX-offset-%.stl: LPX/LPX.scad
	$(OPENSCAD) -q --hardwarnings --render -d .lpx-offset-$*.depends -Dspeed=false -Doffset=$* -o $@ $<


things/CS-%.stl: CS/CS.scad
	$(OPENSCAD) -q --render -d .cs-$*.depends -Dkeycap=\"$*\" -o $@ $<

CS/PseudoMakeMeKeyCapProfiles/skin.scad: CS/PseudoMakeMeKeyCapProfiles/list-comprehension-demos/skin.scad
	cp $< $@

CS/PseudoMakeMeKeyCapProfiles/sweep.scad: CS/PseudoMakeMeKeyCapProfiles/list-comprehension-demos/sweep.scad
	cp $< $@


clean:
	-rm .*.depends $(LPXMX) $(LPXOFFSET) $(CS_TARGETS) $(CS_TP_TARGETS) things/CS-$(KEYBOARD)-middle-array.stl things/CS-$(KEYBOARD)-index-array.stl things/LPX-$(KEYBOARD)-near.stl things/LPX-$(KEYBOARD)-far.stl

image:
	exiftool -overwrite_original -recurse -EXIF= images
	cd images; find . -iname '*.png' -print0 | xargs -0 optipng -o7 -preserve
	cd images; find . -iname '*.jpg' -print0 | xargs -0 jpegoptim --max=90 --strip-all --preserve --totals --all-progressive
