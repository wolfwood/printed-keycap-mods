KEYBOARD != perl -n -e'/^keyboard\s*=\s*"(\S+)"/ && print $$1' < settings.scad

all: lpx cs-middle cs-index

.PHONY: lpx cs-middle cs-index

lpx: things/LPX-$(KEYBOARD).stl

cs-middle: things/CS-$(KEYBOARD)-middle-array.stl

cs-index: things/CS-$(KEYBOARD)-index-array.stl

-include .*.depends

things/LPX-$(KEYBOARD).stl: LPX.scad
	openscad -q --hardwarnings --render  -d .lpx.depends -o $@ $<

things/CS-$(KEYBOARD)-middle-array.stl: CS.scad
	OPENSCADPATH=PseudoMakeMeKeyCapProfiles openscad -q --render  -d .cs-middle.depends -Dindex=false -o $@ $<

things/CS-$(KEYBOARD)-index-array.stl: CS.scad
	OPENSCADPATH=PseudoMakeMeKeyCapProfiles openscad -q --render -d .cs-index.depends -Dindex=true -o $@ $<

clean:
	-rm .*.depends things/*.stl
