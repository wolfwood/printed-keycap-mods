use <../../includes/PseudoMakeMeKeyCapProfiles/Choc_DES_Thumb_Chord.scad>;

function name2id_chord(key) =
  key == "R2L" ? 12 :
  key == "R3L" ? 11 :
  key == "R4L" ? 10 :
  -1;

module chord_key(key="R3", nohug=false, homing=false) {
  keyID = name2id_chord(key);

  if (keyID < 0)
      assert(false, str("invalid DES-uLP chord key ID: ", key));

  keycap(keyID   = keyID, //change profile refer to KeyParameters Struct
         cutLen  = 0, //Don't change. for chopped caps
         Stem    = true, //tusn on shell and stems
         Dish    = true, //turn on dish cut
         Stab    = 0,
         visualizeDish = false, // turn on debug visual of Dish
         crossSection  = false, // center cut to check internal
         homeDot = homing, //turn on homedots
         Sym     = nohug,
         fdm = false
         );
}

function lookup_chord_sculpt(key) = XAngleSkew(name2id_chord(key));
function lookup_chord_width(key) = BottomWidth(name2id_chord(key));

chord_key();
