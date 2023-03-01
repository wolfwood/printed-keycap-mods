OPENSCAD=openscad
KEYBOARD != perl -n -e'/^keyboard\s*=\s*"(\S+)"/ && print $$1' < settings.scad

all: lpx cs-middle cs-index

.PHONY: lpx cs-middle cs-index

lpx: things/LPX-$(KEYBOARD)-near.stl things/LPX-$(KEYBOARD)-far.stl

cs-middle: things/CS-$(KEYBOARD)-middle-array.stl

cs-index: things/CS-$(KEYBOARD)-index-array.stl

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
	$(OPENSCAD) -q --render  -d .cs-middle.depends -Dindex=false -o $@ $<

things/CS-$(KEYBOARD)-index-array.stl: CS.scad
	$(OPENSCAD) -q --render -d .cs-index.depends -Dindex=true -o $@ $<

things/CS-%.stl: CS.scad
	$(OPENSCAD) -q --render -d .cs-$*.depends -Dkeycap=\"$*\" -o $@ $<

PseudoMakeMeKeyCapProfiles/skin.scad: PseudoMakeMeKeyCapProfiles/list-comprehension-demos/skin.scad
	cp $< $@

PseudoMakeMeKeyCapProfiles/sweep.scad: PseudoMakeMeKeyCapProfiles/list-comprehension-demos/sweep.scad
	cp $< $@

clean:
	-rm .*.depends $(CS_TARGETS) things/CS-$(KEYBOARD)-middle-array.stl things/CS-$(KEYBOARD)-index-array.stl things/LPX-$(KEYBOARD)-near.stl things/LPX-$(KEYBOARD)-far.stl
