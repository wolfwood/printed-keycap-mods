use <../../includes/PseudoMakeMeKeyCapProfiles/DES_chocstem.scad>;

function name2id_unsculpted(key) =
  key == "R2" ? 8 :
  key == "R3" ? 7 :
  key == "R3-homing" ? 9 :
  key == "R4" ? 6 :
  -1;

module unsculpted_key(key="R3", homing=false) {
  keyID = name2id_unsculpted(key);

  if (keyID < 0)
    assert(false, str("invalid DES-uLP unsculpted key ID: ", key));

  keycap(keyID   = keyID, //change profile refer to KeyParameters Struct
         cutLen  = 0, //Don't change. for chopped caps
         Stem    = true, //tusn on shell and stems
         Dish    = true, //turn on dish cut
         Stab    = 0,
         visualizeDish = false, // turn on debug visual of Dish
         crossSection  = false, // center cut to check internal
         homeDot = homing, //turn on homedots
         Legends=false,
         fdm = false
         );
}

function lookup_unsculpted_sculpt(key) = XAngleSkew(name2id_unsculpted(key));

unsculpted_key();
