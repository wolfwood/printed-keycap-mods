OPENSCAD=openscad
KEYBOARD != perl -n -e'/^keyboard\s*=\s*"(\S+)"/ && print $$1' < settings.scad

most: lpx cs-middle cs-index

all: most cs cs-middle-solo cs-index-solo

.PHONY: lpx cs-middle cs-index most cs cs-middle-solo cs-index-solo

lpx: things/LPX-$(KEYBOARD)-near.stl things/LPX-$(KEYBOARD)-far.stl

TPKEYS=R3-homing R3 R2-near R2-far

cs-middle: things/CS-$(KEYBOARD)-middle-array.stl

cs-middle-solo: $(addsuffix .stl,$(addprefix things/CS-$(KEYBOARD)-middle-,$(TPKEYS)))

cs-index: things/CS-$(KEYBOARD)-index-array.stl

cs-index-solo: $(addsuffix .stl,$(addprefix things/CS-$(KEYBOARD)-index-,$(TPKEYS)))

CS_TP_TARGETS=$(addsuffix .stl,$(addprefix things/CS-$(KEYBOARD)-middle-,$(TPKEYS))) $(addsuffix .stl,$(addprefix things/CS-$(KEYBOARD)-index-,$(TPKEYS))

# skipping redundant key sculpts: R4 R2R R3R R4R
CS_PROFILE=R2 R3 R3-homing R2L R3L R4L T1L T1R R3x

CS_TARGETS=$(addsuffix .stl,$(addprefix things/CS-,$(CS_PROFILE)))

cs: $(CS_TARGETS)

CS.scad: PseudoMakeMeKeyCapProfiles/skin.scad PseudoMakeMeKeyCapProfiles/sweep.scad

-include .*.depends

things/LPX-$(KEYBOARD)-near.stl: LPX.scad
	$(OPENSCAD) -q --hardwarnings --render  -d .lpx-near.depends -Dfar=false -o $@ $<

things/LPX-$(KEYBOARD)-far.stl: LPX.scad
	$(OPENSCAD) -q --hardwarnings --render  -d .lpx-far.depends -Dfar=true -o $@ $<

things/CS-$(KEYBOARD)-middle-array.stl: CS.scad
	$(OPENSCAD) -q --render  -d .cs-middle-array.depends -Dindex=false -o $@ $<

things/CS-$(KEYBOARD)-index-array.stl: CS.scad
	$(OPENSCAD) -q --render -d .cs-index-array.depends -Dindex=true -o $@ $<

things/CS-$(KEYBOARD)-middle-%.stl: CS.scad
	$(OPENSCAD) -q --render  -d .cs-middle-$*.depends -Dindex=false  -Dtpkey=\"$*\" -o $@ $<

things/CS-$(KEYBOARD)-index-%.stl: CS.scad
	$(OPENSCAD) -q --render -d .cs-index-$*.depends -Dindex=true -Dtpkey=\"$*\" -o $@ $<


things/CS-%.stl: CS.scad
	$(OPENSCAD) -q --render -d .cs-$*.depends -Dkeycap=\"$*\" -o $@ $<

PseudoMakeMeKeyCapProfiles/skin.scad: PseudoMakeMeKeyCapProfiles/list-comprehension-demos/skin.scad
	cp $< $@

PseudoMakeMeKeyCapProfiles/sweep.scad: PseudoMakeMeKeyCapProfiles/list-comprehension-demos/sweep.scad
	cp $< $@

clean:
	-rm .*.depends $(CS_TARGETS) $(CS_TP_TARGETS) things/CS-$(KEYBOARD)-middle-array.stl things/CS-$(KEYBOARD)-index-array.stl things/LPX-$(KEYBOARD)-near.stl things/LPX-$(KEYBOARD)-far.stl
