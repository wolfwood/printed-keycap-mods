/*
  key name schema is:
  (R|T)(0-9)+(x)?(-homing)?(-(N|S)(E|W))?

  table schema is:
  0 : key name, string
  1 : mirror, bool, default: false
  2 : rotate, bool, default: false
  3 : flip onto right side edge, bool, default: false unless key name ends in L, then true
  4 : base key name, string, default, default: same as key name
  -----------------------------------------------------------------------------------------------
  5 : lateral, bool, default: false unless name ends in L or R
  6 : homing dot, bool, default: false unless name ends in "-homing"

  it is possible to omit entire rows or omit trailing column values in order to accept the default
  specifically, columns 5 and 6 should never need to be explicitly set
*/


function mirror_key(type, table) =
  let (type = _root_keyname(type, table))
  _mysearch(type, table, 1);

function rotate_key(type, table) =
  let (type = _root_keyname(type, table))
  _mysearch(type, table, 2);

function flip_key(type, table) =
  let (type = _root_keyname(type, table), result = _mysearch(type, table, 3))
  is_undef(result) && type[len(type)-1] == "L"
  ? true
  : result;

function base_key(type, table) =
  let (type = _root_keyname(type, table), result = _mysearch(type, table, 4))
  is_undef(result) || result == "" || !is_string(result)
  ? type
  : result;

function is_lateral_key(key, table) =
  let(rootname = _root_keyname(key, table), end = len(rootname) - 1)
  _mysearch(key, table, 5)
  ? true
  : rootname[end] == "L" || rootname[end] == "R";

function is_homing_key(key, table) =
  _mysearch(key, table, 6)
  ? true
  : _root_keyname(key, table) != _detrackpoint_keyname(key, table);


function is_trackpoint_key(key, table) =
  _detrackpoint_keyname(key, table) != key;

function trackpoint_key_x(key, table) =
  let(pos = len(key) - 1)
  !is_trackpoint_key(key, table) ? undef
  : key[pos] == "E" ? 1
  : key[pos] == "W" ? -1
  : assert(false, str("not a trackpoint key: ", key));

function trackpoint_key_y(key, table) =
  let(pos = len(key) - 2)
  !is_trackpoint_key(key, table) ? undef
  : key[pos] == "N" ? 1
  : key[pos] == "S" ? -1
  : assert(false, str("not a trackpoint key: ", key));

function pretrackpoint_key(key, table) = _detrackpoint_keyname(key, table);

// removes prefixes from a key name
function _root_keyname(key, table) =
  _dehome_keyname(_detrackpoint_keyname(key, table), table);

// removes "-NW" etc, from a key name
function _detrackpoint_keyname(key, table) =
  let(base  = len(key) - len("-NW"))
  base > 0 ?
  key[base] == "-"
  && (key[base + 1] == "N" || key[base + 1] == "S")
  && (key[base + 2] == "W" || key[base + 2] == "E")
  ? str(chr([for(i = 0; i < base; i = i + 1) ord(key[i])]))
  : key
  : key;

// removes "-homing" from a key name
function _dehome_keyname(key, table) =
  let(base  = len(key) - len("-homing"))
  base > 0 ?
  key[base] == "-" && key[base + 1] == "h" && key[base + 2] == "o" && key[base + 3] == "m" &&
  key[base + 4] == "i" && key[base + 5] == "n" && key[base + 6] == "g"
  ? str(chr([for(i = 0; i < base; i = i + 1) ord(key[i])]))
  : key
  : key;

function _mysearch(key, table, col) =
  let(row = search([key], table)[0])
  // search returns [[]] on a failed lookup, [] evaluates to false,
  // indexing with [] returns undef, undef also evaluates to false,
  // but returning undef lets callers test for failed lookups
  table[row][col];
