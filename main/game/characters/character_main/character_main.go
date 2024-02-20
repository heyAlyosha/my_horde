components {
  id: "main_character"
  component: "/main/game/characters/character_main/main_character.script"
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
  properties {
    id: "speed"
    value: "50.0"
    type: PROPERTY_TYPE_NUMBER
  }
}
embedded_components {
  id: "body"
  type: "sprite"
  data: "tile_set: \"/main/atlases/first_level.atlas\"\n"
  "default_animation: \"zombie_0_0\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 0.0
    y: 7.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
