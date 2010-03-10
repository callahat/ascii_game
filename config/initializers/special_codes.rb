SPEC_CODET = {
  "restrictions" =>
    {
      "no_posting" => 1,
      "no_threding" => 2,
      "no_viewing" => 3
    },
  "npc_division" =>
    {
      "merchant" => 1,
      "guard" => 2,
      "peasant" => 3
    },
  "filter_level" =>
    {
      "show" => 1,
      "locked" => 2,
      "hidden" => 4,
      "deleted" => 8,
      "mods_only" => 16
    },
  "move_type" =>
    {
      "local" => 1,
      "world" => 2,
      "local_relative" => 3
    },
  "image_type" =>
    {
      "kingdom" => 1,
      "world" => 2,
      "creature" => 3,
      "character" => 4
    },
  "pref_list_type" =>
    {
      "creatures" => 1,
      "events" => 2,
      "features" => 3
    },
  "quest_req_type" =>
    {
      "creature_kill" => 1,
      "explore" => 2,
      "item" => 3,
      "kill_any_npc" => 4,
      "kill_pc" => 5,
      "kill_specific_npc" => 6
    },
  "shown_to" =>
    {
      "everyone" => 1,
      "allies" => 2,
      "king" => 3
    },
  "quest_status" =>
    {
      "active" => 1,
      "retired" => 2,
      "all completed" => 3,
      "incompleteable" => 4,
      "design" => 0
    },
  "wellness" =>
    {
      "alive" => 1,
      "dead" => 2,
      "diseased" => 3
    },
  "event_rep_type" =>
    {
      "unlimited" => 1,
      "limited_per_char" => 2,
      "limited" => 3
    },
  "entry_limitations" =>
    {
      "no one" => 1,
      "allies" => 2,
      "everyone" => 3
    },
  "trans_method" =>
    {
      "air" => 1,
      "contact" => 2,
      "fluid" => 3,
      "luminiferous ether" => 4
    },
  "equip_loc" =>
    {
      "hand" => 1,
      "foot" => 2,
      "torso" => 3,
      "head" => 4,
      "finger" => 5,
      "neck" => 6,
      "back" => 7,
      "arms" => 8,
      "legs" => 9,
      "tentacle" => 20,
      "fin" => 21,
      "mandible" => 30,
      "thorax" => 31,
      "abdomen" => 32,
      "claw" => 90,
      "tail" => 91
    },
  "char_stat" =>
    {
      "active" => 1,
      "retired" => 2,
      "final death" => 3,
      "deleted" => 4
    },
  "account_status" =>
    {
      "active" => 1,
      "inactive" => 2,
      "banned" => 3,
      "deleted" => 4,
      "permaban" => 5
    },
  "event_type" =>
    {
      "creature" => 1,
      "disease" => 2,
      "item" => 3,
      "move" => 4,
      "npc" => 5,
      "pc" => 6,
      "quest" => 7,
      "stat" => 8,
      "throne" => 9,
      "castle" => 10,
      "spawn_kingdom" => 11,
      "storm_gate" => 12
    },
  "race_body_type" =>
    {
      "human" => 1,
      "insect" => 2,
      "seamonster" => 3
    },
  "how_eliminated" =>
    {
      "disease" => 1,
      "magic" => 2,
      "combat" => 3
    }
  }
SPEC_CODEC = {
  "restrictions" =>
    {
      1 => "no_posting",
      2 => "no_threding",
      3 => "no_viewing"
    },
  "npc_division" =>
    {
      1 => "merchant",
      2 => "guard",
      3 => "peasant"
    },
  "filter_level" =>
    {
      1 => "show",
      2 => "locked",
      4 => "hidden",
      8 => "deleted",
      16 => "mods_only"
    },
  "move_type" =>
    {
      1 => "local",
      2 => "world",
      3 => "local_relative"
    },
  "image_type" =>
    {
      1 => "kingdom",
      2 => "world",
      3 => "creature",
      4 => "character"
    },
  "pref_list_type" =>
    {
      1 => "creatures",
      2 => "events",
      3 => "features"
    },
  "quest_req_type" =>
    {
      1 => "creature_kill",
      2 => "explore",
      3 => "item",
      4 => "kill_any_npc",
      5 => "kill_pc",
      6 => "kill_specific_npc"
    },
  "shown_to" =>
    {
      1 => "everyone",
      2 => "allies",
      3 => "king"
    },
  "quest_status" =>
    {
      1 => "active",
      2 => "retired",
      3 => "all completed",
      4 => "incompleteable",
      0 => "design"
    },
  "wellness" =>
    {
      1 => "alive",
      2 => "dead",
      3 => "diseased"
    },
  "event_rep_type" =>
    {
      1 => "unlimited",
      2 => "limited_per_char",
      3 => "limited"
    },
  "entry_limitations" =>
    {
      1 => "no one",
      2 => "allies",
      3 => "everyone"
    },
  "trans_method" =>
    {
      1 => "air",
      2 => "contact",
      3 => "fluid",
      4 => "luminiferous ether"
    },
  "equip_loc" =>
    {
      1 => "hand",
      2 => "foot",
      3 => "torso",
      4 => "head",
      5 => "finger",
      6 => "neck",
      7 => "back",
      8 => "arms",
      9 => "legs",
      20 => "tentacle",
      21 => "fin",
      30 => "mandible",
      31 => "thorax",
      32 => "abdomen",
      90 => "claw",
      91 => "tail"
    },
  "char_stat" =>
    {
      1 => "active",
      2 => "retired",
      3 => "final death",
      4 => "deleted"
    },
  "account_status" =>
    {
      1 => "active",
      2 => "inactive",
      3 => "banned",
      4 => "deleted",
      5 => "permaban"
    },
  "event_type" =>
    {
      1 => "creature",
      2 => "disease",
      3 => "item",
      4 => "move",
      5 => "npc",
      6 => "pc",
      7 => "quest",
      8 => "stat",
      9 => "throne",
      10 => "castle",
      11 => "spawn_kingdom",
      12 => "storm_gate"
    },
  "race_body_type" =>
    {
      1 => "human",
      2 => "insect",
      3 => "seamonster"
    },
  "how_eliminated" =>
    {
      1 => "disease",
      2 => "magic",
      3 => "combat"
    }
  } #End of Special Codes