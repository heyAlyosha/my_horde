components {
  id: "zone"
  component: "/main/game/markers/zones/btn_zone.script"
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
    id: "activation"
    value: "false"
    type: PROPERTY_TYPE_BOOLEAN
  }
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"btn_map_no_activation\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  "slice9 {\n"
  "  x: 7.0\n"
  "  y: 10.0\n"
  "  z: 7.0\n"
  "  w: 10.0\n"
  "}\n"
  "size {\n"
  "  x: 30.0\n"
  "  y: 30.0\n"
  "  z: 0.0\n"
  "  w: 0.0\n"
  "}\n"
  "size_mode: SIZE_MODE_MANUAL\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/atlases/first_level.atlas\"\n"
  "}\n"
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
embedded_components {
  id: "count"
  type: "label"
  data: "size {\n"
  "  x: 50.0\n"
  "  y: 15.0\n"
  "  z: 0.0\n"
  "  w: 0.0\n"
  "}\n"
  "color {\n"
  "  x: 1.0\n"
  "  y: 1.0\n"
  "  z: 1.0\n"
  "  w: 1.0\n"
  "}\n"
  "outline {\n"
  "  x: 0.0\n"
  "  y: 0.0\n"
  "  z: 0.0\n"
  "  w: 1.0\n"
  "}\n"
  "shadow {\n"
  "  x: 0.0\n"
  "  y: 0.0\n"
  "  z: 0.0\n"
  "  w: 0.0\n"
  "}\n"
  "leading: 1.0\n"
  "tracking: 0.0\n"
  "pivot: PIVOT_CENTER\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  "line_break: false\n"
  "text: \"10\"\n"
  "font: \"/assets/fonts/font_standart_normal.font\"\n"
  "material: \"/builtins/fonts/label.material\"\n"
  ""
  position {
    x: 1.0
    y: -6.0
    z: 0.1
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "icon"
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
    y: 7.0
    z: 0.1
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "collision_shape: \"\"\n"
  "type: COLLISION_OBJECT_TYPE_TRIGGER\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"point\"\n"
  "mask: \"default\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 0.0\n"
  "      y: 1.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  data: 14.0\n"
  "  data: 12.405064\n"
  "  data: 10.0\n"
  "}\n"
  "linear_damping: 0.0\n"
  "angular_damping: 0.0\n"
  "locked_rotation: false\n"
  "bullet: false\n"
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
embedded_components {
  id: "shadow"
  type: "sprite"
  data: "default_animation: \"btn_map_no_activation\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "blend_mode: BLEND_MODE_ALPHA\n"
  "slice9 {\n"
  "  x: 7.0\n"
  "  y: 10.0\n"
  "  z: 7.0\n"
  "  w: 10.0\n"
  "}\n"
  "size {\n"
  "  x: 32.0\n"
  "  y: 32.0\n"
  "  z: 0.0\n"
  "  w: 0.0\n"
  "}\n"
  "size_mode: SIZE_MODE_MANUAL\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/atlases/first_level.atlas\"\n"
  "}\n"
  ""
  position {
    x: 0.0
    y: -1.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
