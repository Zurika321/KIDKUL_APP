'use strict';

Blockly.defineBlocksWithJsonArray([


    {
        "type": "set_traffic_light",
        "message0": "Set Traffic Light: Port  %1  Color %2  Status %3",
        "args0": [
          {
            "type": "field_dropdown",
            "name": "btn_led_port",
            "options": [
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
            "type": "field_dropdown",
            "name": "color_light",
            "options": [
              [
                "Red",
                "1"
              ],
              [
                "Green",
                "2"
              ],
              [
                "Yellow",
                "3"
              ],
              
            ]
          },
          {
            "type": "field_dropdown",
            "name": "status_traffic_light",
            "options": [
              [
                "Off",
                "1"
              ],
              [
                "On",
                "2"
              ],
              
              
            ]
          },
        ],
        "inputsInline": true,
        "previousStatement": true,
        "nextStatement": true,
        "colour": 230,
    },
    {
        'type': 'get_joystick',
        'message0':'Get Joystick: Port %1 Type %2',
        'args0':[
            {
                'type': 'field_dropdown',
                'name': 'get_joystick_port',
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
                'type':'field_dropdown',
                'name':'get_joystick',
                'options':[
                    [
                        "X","x"
                    ],
                    [ 
                        "Y","y"
                    ]
                ]
            }
        ],
        'output':'Float',
        "colour": 230,
    },
    {
        'type':'get_volume',
        'message0':'Get Volume: Port %1',
        'args0':[
            {
                'type':'field_dropdown',
                'name':'get_volume',
                'options':[
                    ['1', '1'],['2', '2'],['3', '3'],['4', '4'],['5', '5'],['6', '6'],['7', '7'],['8', '8']
                ]
            }
        ],
        'output':'Float',
        "colour": 230,
    },
    {
        'type': 'get_btn_led',
        'message0':'Get Button Led: Port %1 Button %2',
        'args0':[
            {
                'type': 'field_dropdown',
                'name': 'get_led_port',
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
                'type':'field_dropdown',
                'name':'get_btn',
                'options':[
                    [
                        "Left","left"
                    ],
                    [ 
                        "Right","right"
                    ]
                ]
            }
        ],
        'output':'Boolean',
        "colour": 230,
    },

]);