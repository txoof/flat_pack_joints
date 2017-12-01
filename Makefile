all: gen/boxmaker_thingiverse.scad

gen:
	mkdir -p gen

gen/boxmaker_thingiverse.scad: gen simple_box.scad lib/boxmaker.scad lib/flat_pack.scad
	cat simple_box.scad lib/boxmaker.scad lib/flat_pack.scad | sed -Ee '/^(use|include)/ d' > $@
