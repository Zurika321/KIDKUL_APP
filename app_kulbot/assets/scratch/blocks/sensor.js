'use strict';

Blockly.defineBlocksWithJsonArray([

  {
    'type': 'get_unltra',
    'message0': 'Get Unltrasonic: Port %1 (cm)',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_unltr_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_line',
    'message0': 'Get Line: Port %1 with line %2',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_line_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      },
      {
        'type': 'field_dropdown',
        'name': 'get_line',
        'options': [
          [
            "Right",
            "Right"
          ],
          [
            "Left",
            "Left"
          ],

        ]
      }
    ],
    'output': 'Boolean',
    "colour": 230,
  },
  {
    'type': 'get_ir',
    'message0': "Get Sensor IR: Port %1 ",
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_ir_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Boolean',
    "colour": 230,
  },
  {
    'type': 'get_templm75',
    'message0': 'Get Temperature LM75: Port %1 (˚C)',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_templm75_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_tem',
    'message0': 'Get Temperature: Port %1 (˚C)',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_temp_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_hum',
    'message0': 'Get Hum: Port %1 (%)',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_hum_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_soil_hum',
    'message0': 'Get Soil Hum: Port %1 (%)',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_soild_hum_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_gas',
    'message0': 'Get Gas: Port %1 ',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_gas_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_touch',
    'message0': 'Get Touch: Port %1 ',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_touch_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Boolean',
    "colour": 230,
  },
  {
    'type': 'get_gryro',
    'message0': 'Get Gryro: Port %1 Data %2',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_gryro_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      },
      {
        'type': 'field_dropdown',
        'name': 'get_gryro_data',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ],
          [
            "9",
            "9"
          ],
          [
            "10",
            "10"
          ], [
            "11",
            "11"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_color',
    'message0': 'Get Color: Port %1 Color %2',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_color_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }, {
        'type': 'field_dropdown',
        'name': 'get_color_color',
        'options': [
          [
            "Red",
            "Red"
          ],
          [
            "Green",
            "Green"
          ],
          [
            "Blue",
            "Blue"
          ],
          [
            "Clear",
            "Clear"
          ],

        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_light',
    'message0':'Get Light: Port %1',
    'args0':[
        {
            'type': 'field_dropdown',
            'name': 'get_light_port',
            'options': [
                [
                    "1",
                    "1"
                  ],
                  [
                    "2",
                    "2"
                  ],
                  [
                    "3",
                    "3"
                  ],
                  [
                    "4",
                    "4"
                  ],
                  [
                    "5",
                    "5"
                  ],
                  [
                    "6",
                    "6"
                  ],
                  [
                    "7",
                    "7"
                  ],
                  [
                    "8",
                    "8"
                  ]
            ]
        }
    ],
    'output':'Float',
    "colour": 230,
},
  {
    'type': 'get_lux',
    'message0': 'Get Lux: Port %1',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_lux_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },
  {
    'type': 'get_lux_bh1750',
    'message0': 'Get Lux BH1750: Port %1',
    'args0': [
      {
        'type': 'field_dropdown',
        'name': 'get_lux_bh1750_port',
        'options': [
          [
            "1",
            "1"
          ],
          [
            "2",
            "2"
          ],
          [
            "3",
            "3"
          ],
          [
            "4",
            "4"
          ],
          [
            "5",
            "5"
          ],
          [
            "6",
            "6"
          ],
          [
            "7",
            "7"
          ],
          [
            "8",
            "8"
          ]
        ]
      }
    ],
    'output': 'Number',
    "colour": 230,
  },

]);