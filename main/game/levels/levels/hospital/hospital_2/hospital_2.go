components {
  id: "map_core"
  component: "/main/game/levels/map_core.script"
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
    id: "map_url"
    value: "#tilemap"
    type: PROPERTY_TYPE_URL
  }
}
components {
  id: "tilemap"
  component: "/main/game/levels/levels/hospital/hospital_2/hospital_2.tilemap"
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
components {
  id: "map_scripts"
  component: "/main/game/levels/levels/hospital/hospital_2/map_scripts.script"
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
  id: "effect_factory"
  type: "factory"
  data: "prototype: \"/main/game/effects/effect.go\"\n"
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
embedded_components {
  id: "item_factory"
  type: "factory"
  data: "prototype: \"/main/game/objects/items/item.go\"\n"
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
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "collision_shape: \"\"\n"
  "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"default\"\n"
  "mask: \"default\"\n"
  "mask: \"physic_item_horde\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 58.0\n"
  "      y: 71.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: -0.7050518\n"
  "      w: 0.7091558\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 31.0\n"
  "      y: 329.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 3\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 31.0\n"
  "      y: 286.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 6\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 111.0\n"
  "      y: 330.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 9\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 6.0\n"
  "      y: 112.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 12\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 185.0\n"
  "      y: 112.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 15\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 318.0\n"
  "      y: 128.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 18\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 531.0\n"
  "      y: 95.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 21\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 17.0\n"
  "      y: 247.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 24\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 508.0\n"
  "      y: 385.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 27\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 320.0\n"
  "      y: 224.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 30\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: -42.0\n"
  "      y: 191.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 33\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 320.0\n"
  "      y: 320.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 36\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 320.0\n"
  "      y: 249.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 39\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 495.0\n"
  "      y: 250.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 42\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 622.0\n"
  "      y: 250.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 45\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 643.0\n"
  "      y: 317.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 48\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 496.0\n"
  "      y: 319.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 51\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 384.0\n"
  "      y: 327.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 54\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 384.0\n"
  "      y: 283.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 57\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 464.0\n"
  "      y: 327.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 60\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 528.0\n"
  "      y: 327.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 63\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 609.0\n"
  "      y: 326.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 66\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 528.0\n"
  "      y: 280.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 69\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 665.0\n"
  "      y: 201.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 72\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 832.0\n"
  "      y: 272.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 75\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 656.0\n"
  "      y: 275.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 78\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 691.0\n"
  "      y: 355.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 81\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 175.0\n"
  "      y: 324.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 84\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 175.0\n"
  "      y: 281.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 87\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 255.0\n"
  "      y: 325.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 90\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 138.0\n"
  "      y: 408.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 93\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: -138.0\n"
  "      y: 322.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 96\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 144.0\n"
  "      y: 250.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 99\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      x: 823.0\n"
  "      y: 354.0\n"
  "      z: 0.0\n"
  "    }\n"
  "    rotation {\n"
  "      x: 0.0\n"
  "      y: 0.0\n"
  "      z: 0.0\n"
  "      w: 1.0\n"
  "    }\n"
  "    index: 102\n"
  "    count: 3\n"
  "    id: \"\"\n"
  "  }\n"
  "  data: 10.0\n"
  "  data: 83.50645\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 41.281654\n"
  "  data: 32.249336\n"
  "  data: 10.4\n"
  "  data: 118.76183\n"
  "  data: 32.249336\n"
  "  data: 10.4\n"
  "  data: 48.7451\n"
  "  data: 32.249336\n"
  "  data: 10.4\n"
  "  data: 293.53265\n"
  "  data: 32.249336\n"
  "  data: 10.4\n"
  "  data: 45.3038\n"
  "  data: 22.506361\n"
  "  data: 10.4\n"
  "  data: 185.86786\n"
  "  data: 32.249336\n"
  "  data: 10.4\n"
  "  data: 48.7451\n"
  "  data: 32.249336\n"
  "  data: 10.4\n"
  "  data: 41.281654\n"
  "  data: 55.744247\n"
  "  data: 10.4\n"
  "  data: 47.52442\n"
  "  data: 55.744247\n"
  "  data: 10.4\n"
  "  data: 95.944374\n"
  "  data: 24.399214\n"
  "  data: 10.4\n"
  "  data: 63.259613\n"
  "  data: 24.399214\n"
  "  data: 10.4\n"
  "  data: 44.218105\n"
  "  data: 24.399214\n"
  "  data: 10.4\n"
  "  data: 19.312273\n"
  "  data: 76.53713\n"
  "  data: 10.192\n"
  "  data: 19.312273\n"
  "  data: 76.53713\n"
  "  data: 10.192\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 25.443783\n"
  "  data: 24.399214\n"
  "  data: 10.4\n"
  "  data: 31.362827\n"
  "  data: 158.85153\n"
  "  data: 10.4\n"
  "  data: 31.362827\n"
  "  data: 49.731056\n"
  "  data: 10.4\n"
  "  data: 45.28992\n"
  "  data: 49.731056\n"
  "  data: 10.4\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 17.78204\n"
  "  data: 10.0\n"
  "  data: 153.18875\n"
  "  data: 55.744247\n"
  "  data: 10.4\n"
  "  data: 153.18875\n"
  "  data: 55.744247\n"
  "  data: 10.4\n"
  "  data: 62.315907\n"
  "  data: 24.399214\n"
  "  data: 10.4\n"
  "  data: 72.03959\n"
  "  data: 49.731056\n"
  "  data: 10.4\n"
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
  id: "human_factory"
  type: "factory"
  data: "prototype: \"/main/game/characters/human/human.go\"\n"
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
embedded_components {
  id: "goal_collectionfactory"
  type: "collectionfactory"
  data: "prototype: \"/main/game/markers/goal/marker_goal.collection\"\n"
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
embedded_components {
  id: "door_factory"
  type: "factory"
  data: "prototype: \"/main/game/objects/objects_ruin/door_blue.go\"\n"
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
embedded_components {
  id: "pedestal_1_factory"
  type: "factory"
  data: "prototype: \"/main/game/objects/objects_ruin/pedestal_1.go\"\n"
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
embedded_components {
  id: "pedestal_2_factory"
  type: "factory"
  data: "prototype: \"/main/game/objects/objects_ruin/pedestal_2.go\"\n"
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
