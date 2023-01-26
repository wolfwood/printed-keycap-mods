KEYBOARD != perl -n -e'/^keyboard\s*=\s*"(\S+)"/ && print $$1' < settings.scad

all: lpx-middle lpx-index cs-middle cs-index

.PHONY: lpx-middle lpx-index cs-middle cs-index

lpx-middle: things/LPX-$(KEYBOARD)-middle-near.stl

lpx-index: things/LPX-$(KEYBOARD)-index-near.stl

cs-middle: things/CS-$(KEYBOARD)-middle-array.stl

cs-index: things/CS-$(KEYBOARD)-index-array.stl

things/LPX-$(KEYBOARD)-middle-near.stl: LPX.scad
	openscad -q --hardwarnings --render -Dindex=false -o $@ $<

things/LPX-$(KEYBOARD)-index-near.stl: LPX.scad
	openscad -q --hardwarnings --render -Dindex=true -o $@ $<

things/CS-$(KEYBOARD)-middle-array.stl: CS.scad
	openscad -q --hardwarnings --render -Dindex=false -o $@ $<

things/CS-$(KEYBOARD)-index-array.stl: CS.scad
	openscad -q --hardwarnings --render -Dindex=true -o $@ $<
