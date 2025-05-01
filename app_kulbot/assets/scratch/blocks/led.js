'use strict';

Blockly.defineBlocksWithJsonArray([

    {
        "type": "set_btn_led",
        "message0": "Set Button Led: Port  %1  Color %2 ",
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
            "name": "btn_color_led",
            "options": [
              [
                "None",
                "1"
              ],
              [
                "Red",
                "2"
              ],
              [
                "Green",
                "3"
              ],
              [
                "Blue",
                "4"
              ],
              [
                "Yellow",
                "5"
              ],
              [
                "Cyn",
                "6"
              ],
              [
                "Violet",
                "7"
              ],
              [
                "White",
                "8"
              ],
              
            ]
          },
        ],
        "inputsInline": true,
        "previousStatement": true,
        "nextStatement": true,
        "colour": "230",
    },
    {
        "type": "set_ir_led",
        "message0": "Set IR Led: Port  %1  Color %2 ",
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
            "name": "btn_color_led",
            "options": [
              [
                "Right",
                "1"
              ],
              [
                "Left",
                "2"
              ],
              [
                "All",
                "3"
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
        'type': 'turn_on_all_led',
        'message0': 'Turn On All Led: Color %1',
        'args0': [
            {
                'type': 'field_dropdown',
                'name': 'color_all_led',
                'options': [
                    [
                        'None',
                        '1'
                    ],
                    [
                        'Red',
                        '2'
                    ],
                    [
                        'Orange',
                        '3'
                    ],
                    [
                        'Yellow',
                        '4'
                    ],
                    [
                        'Green',
                        '5'
                    ],
                    [
                        'Blue',
                        '6'
                    ],
                    [
                        'Indigo',
                        '7'
                    ],
                    [
                        'Violet',
                        '8'
                    ],
                    [
                        'White',
                        '9'
                    ],
                    [
                        'Black',
                        '10'
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
        "type": "turn_off_led",
        "message0": "Turn Off Led: Port  %1 ",
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
        ],
        "inputsInline": true,
        "previousStatement": true,
        "nextStatement": true,
        "colour": 230,
    },
    {
        "type": "turn_off_all_led",
        "message0": "Turn Off All Led",
        "inputsInline": true,
        "previousStatement": true,
        "nextStatement": true,
        "colour": 230,
    },
    {
        "type": "led_on",
        "message0": "Led On: Port  %1  Color %2 ",
        "args0": [
          {
            "type": "field_dropdown",
            "name": "led_on_port",
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
            'type': 'field_dropdown',
            'name': 'color_led_on',
            'options': [
                [
                    'None',
                    '1'
                ],
                [
                    'Red',
                    '2'
                ],
                [
                    'Orange',
                    '3'
                ],
                [
                    'Yellow',
                    '4'
                ],
                [
                    'Green',
                    '5'
                ],
                [
                    'Blue',
                    '6'
                ],
                [
                    'Indigo',
                    '7'
                ],
                [
                    'Violet',
                    '8'
                ],
                [
                    'White',
                    '9'
                ],
                [
                    'Black',
                    '10'
                ],
                
            ]
        },
        ],
        "inputsInline": true,
        "previousStatement": true,
        "nextStatement": true,
        "colour": 230,
    },
   

]);