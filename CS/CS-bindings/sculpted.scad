use <../../includes/PseudoMakeMeKeyCapProfiles/Choc_Chicago_Steno.scad>;

function name2id_scuplt(key) =
  key == "R2" || key == "R4" ? 0 :
  key == "R3" || key == "R3-homing" ? 1 :
  -1;

module sculpted_key(key="R3", homing=false) {
  keyID = name2id_scuplt(key);

  if (keyID < 0)
      assert(false, str("invalid CS key ID: ", key));

  keycap(keyID   = keyID, //change profile refer to KeyParameters Struct
	 cutLen  = 0, //Don't change. for chopped caps
	 Stem    = true, //tusn on shell and stems
	 StemRot = 0, //change stem orientation by deg
	 Dish    = true, //turn on dish cut
	 Stab    = 0,
	 visualizeDish = false, // turn on debug visual of Dish
	 crossSection  = false, // center cut to check internal
	 homeDot = homing, //turn on homedots
	 Legends = false
	 );
}

function lookup_sculpted_sculpt(key) = XAngleSkew(name2id_scuplt(key));

sculpted_key();
