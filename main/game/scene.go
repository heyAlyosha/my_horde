components {
  id: "scene"
  component: "/main/game/scene.script"
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
embedded_components {
  id: "sprite_scene_bg"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"scene_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 4.0
    y: 4.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
  scale {
    x: 5.168864
    y: 5.599124
    z: 1.0
  }
}
embedded_components {
  id: "bg_sprite"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"bg_color\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 2.0
    y: 749.0
    z: 5.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
  scale {
    x: 60.0
    y: 60.0
    z: 1.0
  }
}
embedded_components {
  id: "scene_body_left_sprite"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"curtain_post_left\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -315.0
    y: 6.0
    z: 7.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "scene_body_right_sprite"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"curtain_post_right\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 331.0
    y: 7.0
    z: 7.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "scene_bottom_left"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"scene_bottom_left\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -226.0
    y: -298.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "scene_bottom_right"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"scene_bottom_right\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 226.0
    y: -298.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_1"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -361.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -443.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_2"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -279.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_3"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -197.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_4"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -115.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_5"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -33.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_6"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 49.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_7"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 131.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_8"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 213.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_9"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 295.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_10"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 377.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_bg_sprite_11"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 459.0
    y: 302.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_right_sprite"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_right\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 281.0
    y: 224.0
    z: 9.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sofit_left_sprite"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"sofit_left\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -259.0
    y: 224.0
    z: 9.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"curtain__item_top_right\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: -107.0
    y: 227.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sprite1"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"curtain__item_top_right\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 10.0
    y: 204.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
  scale {
    x: 1.5
    y: 1.5
    z: 1.0
  }
}
embedded_components {
  id: "sprite2"
  type: "sprite"
  data: "tile_set: \"/main/main.atlas\"\n"
  "default_animation: \"curtain__item_top_right\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  ""
  position {
    x: 128.0
    y: 227.0
    z: 8.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "sprite_scene_image"
  type: "sprite"
  data: "tile_set: \"/main/atlases/custom.atlas\"\n"
  "default_animation: \"bg_transperent\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  "offset: 1.0\n"
  ""
  position {
    x: 4.0
    y: 0.0
    z: 1.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
