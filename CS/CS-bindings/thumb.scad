use <../../includes/PseudoMakeMeKeyCapProfiles/Choc_Chicago_Steno_Thumb.scad>;

function name2id_thumb(key) =
  key == "T1L"    ?  2 :
  key == "T15L"   ?  3 :
  key == "T0L"    ? 15 :
  key == "T015L"  ? 16 :
  key == "T02L"   ? 17 :
  key == "T0175L" ? 18 :
  key == "TW15L"  ? 19 :
  key == "TW015L" ? 20 :
  key == "R3L"    ?  1 :
  key == "R4L"    ?  0 :
  -1;

module thumb_key(key="T1R", homing=false) {
  keyID = name2id_thumb(key);

  if (keyID < 0)
    assert(false, str("invalid CS thumb key ID: ", key));

  keycap(keyID   = keyID, //change profile refer to KeyParameters Struct
	 cutLen  = 0, //Don't change. for chopped caps
	 Stem    = true, //tusn on shell and stems
	 StemRot = 0, //change stem orientation by deg
	 Dish    = true, //turn on dish cut
	 Stab    = 0,
	 visualizeDish = false, // turn on debug visual of Dish
	 crossSection  = false, // center cut to check internal
	 homeDot = false, //turn on homedots
	 Legends = false
	 );
}

function lookup_thumb_sculpt(key) = XAngleSkew(name2id_thumb(key));

thumb_key();
