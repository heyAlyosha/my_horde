components {
  id: "script"
  component: "/main/game/characters/zombie/zombie.script"
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
    id: "distantion_visible"
    value: "60.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "distantion_attack"
    value: "20.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "target"
    value: ""
    type: PROPERTY_TYPE_URL
  }
}
embedded_components {
  id: "body"
  type: "sprite"
  data: "default_animation: \"zombie_0_2_default\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/atlases/first_level.atlas\"\n"
  "}\n"
  ""
  position {
    x: 0.0
    y: 6.0
    z: 1.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "bullet_hit_factory"
  type: "factory"
  data: "prototype: \"/main/game/bullets/bullet_hit.go\"\n"
  "load_dynamically: false\n"
  "dynamic_prototype: false\n"
  ""
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
}
