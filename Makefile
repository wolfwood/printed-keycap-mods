KEYBOARD != perl -n -e'/^keyboard\s*=\s*"(\S+)"/ && print $$1' < settings.scad

all: lpx cs-middle cs-index

.PHONY: lpx cs-middle cs-index

lpx: things/LPX-$(KEYBOARD).stl

cs-middle: things/CS-$(KEYBOARD)-middle-array.stl

cs-index: things/CS-$(KEYBOARD)-index-array.stl

# skipping redundant key sculpts: R4 R2R R3R R4R
CS_PROFILE=R2 R3 R3-homing R2L R3L R4L T1L T1R R3x

CS_TARGETS=$(addsuffix .stl,$(addprefix things/CS-,$(CS_PROFILE)))

cs: $(CS_TARGETS)

-include .*.depends

things/LPX-$(KEYBOARD).stl: LPX.scad
	openscad -q --hardwarnings --render  -d .lpx.depends -o $@ $<

things/CS-$(KEYBOARD)-middle-array.stl: CS.scad
	OPENSCADPATH=PseudoMakeMeKeyCapProfiles openscad -q --render  -d .cs-middle.depends -Dindex=false -o $@ $<

things/CS-$(KEYBOARD)-index-array.stl: CS.scad
	OPENSCADPATH=PseudoMakeMeKeyCapProfiles openscad -q --render -d .cs-index.depends -Dindex=true -o $@ $<

things/CS-%.stl: CS.scad
	OPENSCADPATH=PseudoMakeMeKeyCapProfiles openscad -q --render -d .cs-$*.depends -Dkeycap=\"$*\" -o $@ $<

clean:
	-rm .*.depends things/*.stl
