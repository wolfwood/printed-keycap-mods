
lpx-middle: things/LPX-santoku-middle-near.stl

lpx-index: things/LPX-santoku-index-near.stl

things/LPX-santoku-middle-near.stl: LPX.scad
	openscad -q --hardwarnings --render -Dindex=false -o $@ $<

things/LPX-santoku-index-near.stl: LPX.scad
	openscad -q --hardwarnings --render -Dindex=true -o $@ $<
