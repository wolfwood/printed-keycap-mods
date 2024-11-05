use <../../includes/PseudoMakeMeKeyCapProfiles/Choc_Chicago_Steno_Convex.scad>;

function name2id_convex(key) =
  key == "R2x" ? 0 :
  key == "R3x" ? 1 :
  -1;

module convex_key(key="R3x", homing=false) {
  keyID = name2id_convex(key);

  if (keyID < 0)
    assert(false, str("invalid CS convex key ID: ", key));

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

function lookup_sculpted_convex(key) = XAngleSkew(name2id(key));

convex_key();
