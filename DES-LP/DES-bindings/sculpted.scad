use <../../includes/PseudoMakeMeKeyCapProfiles/DES_chocstem.scad>;

function name2id(key) =
  key == "R1" ? 5 :
  key == "R2" ? 2 :
  key == "R3" ? 1 :
  key == "R3-homing" ? 3 :
  key == "R4" ? 0 :
  key == "R5" ? 4 :
  assert(false, str("invalid CS key ID: ", key));

module sculpted_key(key="R3", homing=false) {
  keyID = name2id(key);

  keycap(keyID   = keyID, //change profile refer to KeyParameters Struct
     cutLen  = 0, //Don't change. for chopped caps
     Stem    = true, //tusn on shell and stems
     Dish    = true, //turn on dish cut
     Stab    = 0,
     visualizeDish = false, // turn on debug visual of Dish
     crossSection  = false, // center cut to check internal
     homeDot = homing, //turn on homedots
     Legends = false
     );
}

function lookup_sculpted_sculpt(key) = XAngleSkew(name2id(key));

sculpted_key();
