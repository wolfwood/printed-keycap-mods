use <../../includes/PseudoMakeMeKeyCapProfiles/LiminalChimera.scad>;

module sculpted_key(key="R3", homing=false) {
  keyID = key == "R2" ? 0 :
    key == "R3" ? 3 :
    key == "R4" ? 6 :
    key == "R2R" ? 9 :
    key == "R3R" ? 12 :
    key == "R4R" ? 15 :
    assert(false, str("invalid LC key ID: ", key));

  keycap(keyID   = keyID, //change profile refer to KeyParameters Struct
	 cutLen  = 0, //Don't change. for chopped caps
	 heightAdjust = 0,
	 Stem    = 0, //tusn on shell and stems
	 Dish    = true, //turn on dish cut
	 visualizeDish = false, // turn on debug visual of Dish
	 crossSection  = false, // center cut to check internal
	 Sym = true,
	 Rotation = 0
	 );
}

sculpted_key();
