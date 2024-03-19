components {
  id: "script"
  component: "/orthographic/camera.script"
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
    id: "near_z"
    value: "-500.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "far_z"
    value: "500.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "zoom"
    value: "1.0"
    type: PROPERTY_TYPE_NUMBER
  }
  properties {
    id: "projection"
    value: "FIXED_AUTO"
    type: PROPERTY_TYPE_HASH
  }
  properties {
    id: "follow_horizontal"
    value: "false"
    type: PROPERTY_TYPE_BOOLEAN
  }
  properties {
    id: "follow_vertical"
    value: "false"
    type: PROPERTY_TYPE_BOOLEAN
  }
  properties {
    id: "follow_target"
    value: "prototype_main_horde/player"
    type: PROPERTY_TYPE_HASH
  }
}
