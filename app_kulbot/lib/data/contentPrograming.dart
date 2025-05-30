import 'package:flutter/foundation.dart';

const String initialXml = 
    '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="text" x="70" y="30"><field name="TEXT">XML</field></block></xml>';


const Map<String, dynamic> initialJson = {
  'blocks': {
    'languageVersion': 0,
    'blocks': [
      {
        'type': 'event_program_starts',
        'x': 70,
        'y': 30,
        'deletable': false,
        'movable': true,
      },
      // {
      //   'type': 'text',
      //   'x': 70,
      //   'y': 30,
      //   'deletable': true,
      //   'movable': true,
      // },
    ]
  },
};


const Map<String, dynamic> newState = {
  'blocks': {
    'languageVersion': 0,
    'blocks': [
      {
        'type': 'text',
        'x': 70,
        'y': 30,
        'fields': {'TEXT': 'JSON'}
      },
      {
        'type': 'text',
        'x': 70,
        'y': 70,
        'fields': {'TEXT': 'NEW'}
      },
    ],
  },
};

const Map<String, dynamic> initialToolboxJson = {
  'kind': 'categoryToolbox',
  'contents': [
  //Events
    {
      "kind": "category",
      "name": "Events",
      'colour': 150,
      "contents": [
        {
          'kind': 'block',
          'type': "event_program_starts"
        },
        {
          'kind': 'block',
          'type': "move"
        },
      ]
    },
  //Control
  {
    'kind': 'category',
    'name': 'Control',
    'colour': 210,
    'contents': [
      {
        "kind": "block",
        "type": "control_wait_seconds",
        "inputs": {
          "TIMEOUT": {
            "shadow": {
              "type": "math_number",
              "fields": {
                "NUM": 1
              },
              "min": 1,
              "max": 10  // Đặt giới hạn từ 1 đến 10
            }
          }
        }
      },
      {
        'kind': 'block',
        'type': 'control_repeat',
        "inputs": {
          "TIMES": {
            "shadow": {
              "type": "math_number",  // Hoặc "math_integer"
              "fields": {
                "NUM": 10
              }
            }
          }
        }
      },
      {
        'kind': 'block',
        'type': 'control_forever'
      },
      {
        'kind': 'block',
        'type': 'control_if'
      },
      {
        'kind': 'block',
        'type': 'control_if_then_else'
      },
      {
        'kind': 'block',
        'type': 'control_repeat_until'
      },

    ]
    },
    //Operator
    {
      "kind": "category",
      "name": "Operators",
      'colour': 150,
      "contents": [
        {
          "kind": "block",
          "type": "operators_plus",
          "inputs": {
            "NUM1": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            },
            "NUM2": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            }
          }
        },
        {
          "kind": "block",
          "type": "operators_minus",
          "inputs": {
            "NUM1": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            },
            "NUM2": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            }
          }
        },
        {
          "kind": "block",
          "type": "operators_multiply",
          "inputs": {
            "NUM1": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            },
            "NUM2": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            }
          }
        },
        {
          "kind": "block",
          "type": "operators_divine",
          "inputs": {
            "NUM1": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            },
            "NUM2": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            }
          }
        },
        {
          "kind": "block",
          "type": "operators_random",
          "inputs": {
            "NUM1": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 1
                }
              }
            },
            "NUM2": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 10
                }
              }
            }
          }
        },
        {
          "kind": "block",
          "type": "operators_more_than",
          "inputs": {
            "NUM1": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            },
            "NUM2": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            }
          }
        },
        {
          "kind": "block",
          "type": "operators_less_than",
          "inputs": {
            "NUM1": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            },
            "NUM2": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            }
          }
        },
        {
          "kind": "block",
          "type": "operators_equal",
          "inputs": {
            "NUM1": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            },
            "NUM2": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 0
                }
              }
            }
          }
        },
        {
          'kind': 'block',
          'type': 'operators_and'
        },
        {
          'kind': 'block',
          'type': 'operators_or'
        },
        {
          'kind': 'block',
          'type': 'operators_not'
        },
      ]
    },

    //Led
    {
      "kind": 'category',
      'name': 'Led',
      'colour': 120,
      'contents': [
        {
          'kind': 'block',
          'type': 'set_btn_led'
        },
        {
          'kind': 'block',
          'type': 'set_ir_led'
        },
        {
          'kind': 'block',
          'type': 'turn_on_all_led'
        },
        {
          'kind': 'block',
          'type': 'turn_off_led'
        },
        {
          'kind': 'block',
          'type': 'turn_off_all_led'
        },
        {
          'kind':'block',
          'type':'led_on'
        },
      ]
    },
    //module
    {
      'kind': 'category',
      'name': 'Module',
      'colour': 140,
      'contents': [
        {
          'kind': 'block',
          'type':'set_traffic_light'
        },
        {
          'kind': 'block',
          'type':'get_joystick'
        },
        {
          'kind': 'block',
          'type':'get_volume'
        },
        {
          'kind': 'block',
          'type':'get_btn_led'
        },
      ]
    },
    //Sensor
    {
      'kind':'category',
      'name': 'Sensor',
      'colour': 130,
      'contents': [
        {
          'kind':'block',
          'type':'sensor_ultrasonic'
        },
        {
          'kind': 'block',
          'type':'sensor_get_line'
        },
        {
          'kind': 'block',
          'type':'get_ir'
        },
        {
          'kind': 'block',
          'type':'get_templm75'
        },
        {
          'kind': 'block',
          'type':'get_tem'
        },
        {
          'kind': 'block',
          'type':'get_hum'
        },
        {
          'kind': 'block',
          'type':'get_soil_hum'
        },
        {
          'kind': 'block',
          'type':'get_gas'
        },
        {
          'kind': 'block',
          'type':'get_touch'
        },
        {
          'kind': 'block',
          'type':'get_gryro'
        },
        {
          'kind': 'block',
          'type':'get_color'
        },
        {
          'kind': 'block',
          'type':'get_light'
        },
        {
          'kind': 'block',
          'type':'get_lux'
        },
        {
          'kind': 'block',
          'type':'get_lux_bh1750'
        }
      ]

    },

    {
      'kind': 'category',
      'name': 'Display',
      'colour': 230,
      'contents': [
        {
          'kind': 'block',
          'type': 'lcd_print_number',
          "inputs": {
            "COLUMN": {
              "shadow": {
                "type": "math_number",  // Hoặc "math_integer"
                "fields": {
                  "NUM": 0
                }
              }
            },
            "CELL": {
              "shadow": {
                "type": "math_number",  // Hoặc "math_integer"
                "fields": {
                  "NUM": 0
                }
              }
            },
            "NUMBER": {
              "shadow": {
                "type": "math_number",  // Hoặc "math_integer"
                "fields": {
                  "NUM": 0
                }
              }
            }
          }
        },
        {
          'kind': 'block',
          'type': 'lcd_print_str',
          "inputs": {
            "COLUMN": {
              "shadow": {
                "type": "math_number",  // Hoặc "math_integer"
                "fields": {
                  "NUM": 0
                }
              }
            },
            "CELL": {
              "shadow": {
                "type": "math_number",  // Hoặc "math_integer"
                "fields": {
                  "NUM": 0
                }
              }
            },
            "STRING": {
              "shadow": {
                "type": "text",
                "fields": {
                  "TEXT": "Hello!!!"
                }
              }
            }
          }
        },
        {
          'kind': 'block',
          'type': 'lcd_clear'
        }
      ]
    },

// Motions
{
'kind':'category',
'name': 'Motions',
'colour': 130,
'contents': [
  {
    'kind':"block",
    'type':"motor1",
  },
  {
    'kind':"block",
    'type':"Servo",
  },
  // {
  //   'kind':"block",
  //   'type':"SetEncoder",
  // },
  // {
  //   'kind':"block",
  //   'type':"SetTurningEncoder",
  // },
  // {
  //   'kind':"block",
  //   'type':"GetPostEncoder",
  // },

]},

    {
      'kind': 'category',
      'name': 'Loops',
      'colour': 120,
      'contents': [
        {
          'kind': 'block',
          'blockxml': '''
            <block type="controls_repeat_ext">
                  <value name="TIMES">
                    <shadow type="math_number">
                      <field name="NUM">10</field>
                    </shadow>
                  </value>
                </block>
            '''
        },
        {
          'kind': 'block',
          'blockxml': '''
                <block type="controls_whileUntil">
                  <field name="MODE">WHILE</field>
                </block>
            '''
        },
        {
          'kind': 'block',
          'blockxml': '''
            <block type="controls_for">
              <field name="VAR" id="C(8;cYCF}~vSgkxzJ+{O" variabletype="">i</field>
              <value name="FROM">
                <shadow type="math_number">
                  <field name="NUM">1</field>
                </shadow>
              </value>
              <value name="TO">
                <shadow type="math_number">
                  <field name="NUM">10</field>
                </shadow>
              </value>
              <value name="BY">
                <shadow type="math_number">
                  <field name="NUM">1</field>
                </shadow>
              </value>
            </block>
          '''
        },
        {
          'kind': 'block',
          'blockxml': '''
            <block type="controls_forEach">
              <field name="VAR" id="Cg!CSk/ZJo2XQN3=VVrz" variabletype="">j</field>
            </block>
            '''
        },
        {
          'kind': 'block',
          'blockxml': '''
            <block type="controls_flow_statements">
              <field name="FLOW">BREAK</field>
            </block>
            '''
        },
      ],
    },
    // {
    //   'kind': 'category',
    //   'name': 'Math',
    //   'colour': 230,
    //   'contents': [
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_round">
    //           <field name="OP">ROUND</field>
    //           <value name="NUM">
    //             <shadow type="math_number">
    //               <field name="NUM">3.1</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_number">
    //           <field name="NUM">0</field>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_single">
    //           <field name="OP">ROOT</field>
    //           <value name="NUM">
    //             <shadow type="math_number">
    //               <field name="NUM">9</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_trig">
    //           <field name="OP">SIN</field>
    //           <value name="NUM">
    //             <shadow type="math_number">
    //               <field name="NUM">45</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_constant">
    //           <field name="CONSTANT">PI</field>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_number_property">
    //           <mutation divisor_input="false"></mutation>
    //           <field name="PROPERTY">EVEN</field>
    //           <value name="NUMBER_TO_CHECK">
    //             <shadow type="math_number">
    //               <field name="NUM">0</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_arithmetic">
    //           <field name="OP">ADD</field>
    //           <value name="A">
    //             <shadow type="math_number">
    //               <field name="NUM">1</field>
    //             </shadow>
    //           </value>
    //           <value name="B">
    //             <shadow type="math_number">
    //               <field name="NUM">1</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_on_list">
    //           <mutation op="SUM"></mutation>
    //           <field name="OP">SUM</field>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_modulo">
    //           <value name="DIVIDEND">
    //             <shadow type="math_number">
    //               <field name="NUM">64</field>
    //             </shadow>
    //           </value>
    //           <value name="DIVISOR">
    //             <shadow type="math_number">
    //               <field name="NUM">10</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_constrain">
    //           <value name="VALUE">
    //             <shadow type="math_number">
    //               <field name="NUM">50</field>
    //             </shadow>
    //           </value>
    //           <value name="LOW">
    //             <shadow type="math_number">
    //               <field name="NUM">1</field>
    //             </shadow>
    //           </value>
    //           <value name="HIGH">
    //             <shadow type="math_number">
    //               <field name="NUM">100</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="math_random_int">
    //           <value name="FROM">
    //             <shadow type="math_number">
    //               <field name="NUM">1</field>
    //             </shadow>
    //           </value>
    //           <value name="TO">
    //             <shadow type="math_number">
    //               <field name="NUM">100</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'type': 'math_random_float',
    //     },
    //   ],
    // },
    // {
    //   'kind': 'category',
    //   'name': 'Text',
    //   'colour': 160,
    //   'contents': [
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_charAt">
    //           <mutation at="true"></mutation>
    //           <field name="WHERE">FROM_START</field>
    //           <value name="VALUE">
    //             <block type="variables_get">
    //               <field name="VAR" id="q@\$ZF(L?Zo/z`d{o.Bp!" variabletype="">text</field>
    //             </block>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text">
    //           <field name="TEXT"></field>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_append">
    //           <field name="VAR" id=":};P,s[*|I8+L^-.EbRi" variabletype="">item</field>
    //           <value name="TEXT">
    //             <shadow type="text">
    //               <field name="TEXT"></field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_length">
    //           <value name="VALUE">
    //             <shadow type="text">
    //               <field name="TEXT">abc</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_isEmpty">
    //           <value name="VALUE">
    //             <shadow type="text">
    //               <field name="TEXT"></field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_indexOf">
    //           <field name="END">FIRST</field>
    //           <value name="VALUE">
    //             <block type="variables_get">
    //               <field name="VAR" id="q@\$ZF(L?Zo/z`d{o.Bp!" variabletype="">text</field>
    //             </block>
    //           </value>
    //           <value name="FIND">
    //             <shadow type="text">
    //               <field name="TEXT">abc</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_join">
    //           <mutation items="2"></mutation>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_getSubstring">
    //           <mutation at1="true" at2="true"></mutation>
    //           <field name="WHERE1">FROM_START</field>
    //           <field name="WHERE2">FROM_START</field>
    //           <value name="STRING">
    //             <block type="variables_get">
    //               <field name="VAR" id="q@\$ZF(L?Zo/z`d{o.Bp!" variabletype="">text</field>
    //             </block>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_changeCase">
    //           <field name="CASE">UPPERCASE</field>
    //           <value name="TEXT">
    //             <shadow type="text">
    //               <field name="TEXT">abc</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_trim">
    //           <field name="MODE">BOTH</field>
    //           <value name="TEXT">
    //             <shadow type="text">
    //               <field name="TEXT">abc</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_print">
    //           <value name="TEXT">
    //             <shadow type="text">
    //               <field name="TEXT">abc</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="text_prompt_ext">
    //           <mutation type="TEXT"></mutation>
    //           <field name="TYPE">TEXT</field>
    //           <value name="TEXT">
    //             <shadow type="text">
    //               <field name="TEXT">abc</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //   ],
    // },
    // {
    //   'kind': 'category',
    //   'name': 'Lists',
    //   'colour': 259,
    //   'contents': [
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_indexOf">
    //           <field name="END">FIRST</field>
    //           <value name="VALUE">
    //             <block type="variables_get">
    //               <field name="VAR" id="e`(L;x,.j[[XN`F33Q5." variabletype="">list</field>
    //             </block>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_create_with">
    //           <mutation items="0"></mutation>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_repeat">
    //           <value name="NUM">
    //             <shadow type="math_number">
    //               <field name="NUM">5</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'type': 'lists_length',
    //     },
    //     {
    //       'kind': 'block',
    //       'type': 'lists_isEmpty',
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_create_with">
    //           <mutation items="3"></mutation>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_getIndex">
    //           <mutation statement="false" at="true"></mutation>
    //           <field name="MODE">GET</field>
    //           <field name="WHERE">FROM_START</field>
    //           <value name="VALUE">
    //             <block type="variables_get">
    //               <field name="VAR" id="e`(L;x,.j[[XN`F33Q5." variabletype="">list</field>
    //             </block>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_setIndex">
    //           <mutation at="true"></mutation>
    //           <field name="MODE">SET</field>
    //           <field name="WHERE">FROM_START</field>
    //           <value name="LIST">
    //             <block type="variables_get">
    //               <field name="VAR" id="e`(L;x,.j[[XN`F33Q5." variabletype="">list</field>
    //             </block>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_getSublist">
    //           <mutation at1="true" at2="true"></mutation>
    //           <field name="WHERE1">FROM_START</field>
    //           <field name="WHERE2">FROM_START</field>
    //           <value name="LIST">
    //             <block type="variables_get">
    //               <field name="VAR" id="e`(L;x,.j[[XN`F33Q5." variabletype="">list</field>
    //             </block>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_split">
    //           <mutation mode="SPLIT"></mutation>
    //           <field name="MODE">SPLIT</field>
    //           <value name="DELIM">
    //             <shadow type="text">
    //               <field name="TEXT">,</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="lists_sort">
    //           <field name="TYPE">NUMERIC</field>
    //           <field name="DIRECTION">1</field>
    //         </block>
    //         '''
    //     },
    //   ],
    // },
    // {
    //   'kind': 'category',
    //   'name': 'Colour',
    //   'colour': 19,
    //   'contents': [
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="colour_picker">
    //           <field name="COLOUR">#ff0000</field>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'type': 'colour_random',
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="colour_rgb">
    //           <value name="RED">
    //             <shadow type="math_number">
    //               <field name="NUM">100</field>
    //             </shadow>
    //           </value>
    //           <value name="GREEN">
    //             <shadow type="math_number">
    //               <field name="NUM">50</field>
    //             </shadow>
    //           </value>
    //           <value name="BLUE">
    //             <shadow type="math_number">
    //               <field name="NUM">0</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //     {
    //       'kind': 'block',
    //       'blockxml': '''
    //         <block type="colour_blend">
    //           <value name="COLOUR1">
    //             <shadow type="colour_picker">
    //               <field name="COLOUR">#ff0000</field>
    //             </shadow>
    //           </value>
    //           <value name="COLOUR2">
    //             <shadow type="colour_picker">
    //               <field name="COLOUR">#3333ff</field>
    //             </shadow>
    //           </value>
    //           <value name="RATIO">
    //             <shadow type="math_number">
    //               <field name="NUM">0.5</field>
    //             </shadow>
    //           </value>
    //         </block>
    //         '''
    //     },
    //   ],
    // },
    {'kind': 'sep'},
    // {
    //   'kind': 'category',
    //   'name': 'Custom Button',
    //   'colour': 19,
    //   'contents': [
    //     {
    //       'kind': 'button',
    //       'text': 'A button',
    //       'callbackKey': 'myFirstButtonPressed',
    //     },
    //   ],
    // },
    // {
    //   'kind': 'category',
    //   'name': 'Variables',
    //   'custom': 'VARIABLE',
    //   'colour': 330,
    // },
    {
      "kind": "category",
      "name": "Variables",
      'colour': 330,
      "contents": [
        {
          'kind': 'block',
          'type': "variables_create"
        },
        {
          'kind': 'block',
          'type': "variables_set",
          "inputs": {
            "VALUE": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 1
                },
              }
            }
          }
        },
        {
          'kind': 'block',
          'type': "variables_change",
          "inputs": {
            "DELTA": {
              "shadow": {
                "type": "math_number",
                "fields": {
                  "NUM": 1
                },
              }
            }
          }
        },
      ]
    },
    // {
    //   'kind': 'category',
    //   'name': 'Functions',
    //   'custom': 'PROCEDURE',
    //   'colour': 290,
    // },
  ],
};

const String initialToolboxXml = '''
  <xml xmlns="http://www.w3.org/1999/xhtml" id="toolbox" style="display: none;">
  <category name="Logic" colour="#5C81A6">
  <block type="controls_if"></block>
  <block type="logic_compare">
    <field name="OP">EQ</field>
  </block>
  <block type="logic_operation">
    <field name="OP">AND</field>
  </block>
  <block type="logic_negate"></block>
  <block type="logic_boolean">
    <field name="BOOL">TRUE</field>
  </block>
  <block type="logic_null"></block>
  <block type="logic_ternary"></block>
    </category>
    <category name="Loops" colour="#5CA65C">
  <block type="controls_repeat_ext">
    <value name="TIMES">
      <shadow type="math_number">
        <field name="NUM">10</field>
      </shadow>
    </value>
  </block>
  <block type="controls_whileUntil">
    <field name="MODE">WHILE</field>
  </block>
  <block type="controls_for">
    <field name="VAR" id="C(8;cYCF}~vSgkxzJ+{O" variabletype="">i</field>
    <value name="FROM">
      <shadow type="math_number">
        <field name="NUM">1</field>
      </shadow>
    </value>
    <value name="TO">
      <shadow type="math_number">
        <field name="NUM">10</field>
      </shadow>
    </value>
    <value name="BY">
      <shadow type="math_number">
        <field name="NUM">1</field>
      </shadow>
    </value>
  </block>
  <block type="controls_forEach">
    <field name="VAR" id="Cg!CSk/ZJo2XQN3=VVrz" variabletype="">j</field>
  </block>
  <block type="controls_flow_statements">
    <field name="FLOW">BREAK</field>
  </block>
    </category>
    <category name="Math" colour="#5C68A6">
  <block type="math_round">
    <field name="OP">ROUND</field>
    <value name="NUM">
      <shadow type="math_number">
        <field name="NUM">3.1</field>
      </shadow>
    </value>
  </block>
  <block type="math_number">
    <field name="NUM">0</field>
  </block>
  <block type="math_single">
    <field name="OP">ROOT</field>
    <value name="NUM">
      <shadow type="math_number">
        <field name="NUM">9</field>
      </shadow>
    </value>
  </block>
  <block type="math_trig">
    <field name="OP">SIN</field>
    <value name="NUM">
      <shadow type="math_number">
        <field name="NUM">45</field>
      </shadow>
    </value>
  </block>
  <block type="math_constant">
    <field name="CONSTANT">PI</field>
  </block>
  <block type="math_number_property">
    <mutation divisor_input="false"></mutation>
    <field name="PROPERTY">EVEN</field>
    <value name="NUMBER_TO_CHECK">
      <shadow type="math_number">
        <field name="NUM">0</field>
      </shadow>
    </value>
  </block>
  <block type="math_arithmetic">
    <field name="OP">ADD</field>
    <value name="A">
      <shadow type="math_number">
        <field name="NUM">1</field>
      </shadow>
    </value>
    <value name="B">
      <shadow type="math_number">
        <field name="NUM">1</field>
      </shadow>
    </value>
  </block>
  <block type="math_on_list">
    <mutation op="SUM"></mutation>
    <field name="OP">SUM</field>
  </block>
  <block type="math_modulo">
    <value name="DIVIDEND">
      <shadow type="math_number">
        <field name="NUM">64</field>
      </shadow>
    </value>
    <value name="DIVISOR">
      <shadow type="math_number">
        <field name="NUM">10</field>
      </shadow>
    </value>
  </block>
  <block type="math_constrain">
    <value name="VALUE">
      <shadow type="math_number">
        <field name="NUM">50</field>
      </shadow>
    </value>
    <value name="LOW">
      <shadow type="math_number">
        <field name="NUM">1</field>
      </shadow>
    </value>
    <value name="HIGH">
      <shadow type="math_number">
        <field name="NUM">100</field>
      </shadow>
    </value>
  </block>
  <block type="math_random_int">
    <value name="FROM">
      <shadow type="math_number">
        <field name="NUM">1</field>
      </shadow>
    </value>
    <value name="TO">
      <shadow type="math_number">
        <field name="NUM">100</field>
      </shadow>
    </value>
  </block>
  <block type="math_random_float"></block>
    </category>
    <category name="Text" colour="#5CA68D">
  <block type="text_charAt">
    <mutation at="true"></mutation>
    <field name="WHERE">FROM_START</field>
    <value name="VALUE">
      <block type="variables_get">
        <field name="VAR" id="q@\$ZF(L?Zo/z`d{o.Bp!" variabletype="">text</field>
      </block>
    </value>
  </block>
  <block type="text">
    <field name="TEXT"></field>
  </block>
  <block type="text_append">
    <field name="VAR" id=":};P,s[*|I8+L^-.EbRi" variabletype="">item</field>
    <value name="TEXT">
      <shadow type="text">
        <field name="TEXT"></field>
      </shadow>
    </value>
  </block>
  <block type="text_length">
    <value name="VALUE">
      <shadow type="text">
        <field name="TEXT">abc</field>
      </shadow>
    </value>
  </block>
  <block type="text_isEmpty">
    <value name="VALUE">
      <shadow type="text">
        <field name="TEXT"></field>
      </shadow>
    </value>
  </block>
  <block type="text_indexOf">
    <field name="END">FIRST</field>
    <value name="VALUE">
      <block type="variables_get">
        <field name="VAR" id="q@\$ZF(L?Zo/z`d{o.Bp!" variabletype="">text</field>
      </block>
    </value>
    <value name="FIND">
      <shadow type="text">
        <field name="TEXT">abc</field>
      </shadow>
    </value>
  </block>
  <block type="text_join">
    <mutation items="2"></mutation>
  </block>
  <block type="text_getSubstring">
    <mutation at1="true" at2="true"></mutation>
    <field name="WHERE1">FROM_START</field>
    <field name="WHERE2">FROM_START</field>
    <value name="STRING">
      <block type="variables_get">
        <field name="VAR" id="q@\$ZF(L?Zo/z`d{o.Bp!" variabletype="">text</field>
      </block>
    </value>
  </block>
  <block type="text_changeCase">
    <field name="CASE">UPPERCASE</field>
    <value name="TEXT">
      <shadow type="text">
        <field name="TEXT">abc</field>
      </shadow>
    </value>
  </block>
  <block type="text_trim">
    <field name="MODE">BOTH</field>
    <value name="TEXT">
      <shadow type="text">
        <field name="TEXT">abc</field>
      </shadow>
    </value>
  </block>
  <block type="text_print">
    <value name="TEXT">
      <shadow type="text">
        <field name="TEXT">abc</field>
      </shadow>
    </value>
  </block>
  <block type="text_prompt_ext">
    <mutation type="TEXT"></mutation>
    <field name="TYPE">TEXT</field>
    <value name="TEXT">
      <shadow type="text">
        <field name="TEXT">abc</field>
      </shadow>
    </value>
  </block>
    </category>
    <category name="Lists" colour="#745CA6">
  <block type="lists_indexOf">
    <field name="END">FIRST</field>
    <value name="VALUE">
      <block type="variables_get">
        <field name="VAR" id="e`(L;x,.j[[XN`F33Q5." variabletype="">list</field>
      </block>
    </value>
  </block>
  <block type="lists_create_with">
    <mutation items="0"></mutation>
  </block>
  <block type="lists_repeat">
    <value name="NUM">
      <shadow type="math_number">
        <field name="NUM">5</field>
      </shadow>
    </value>
  </block>
  <block type="lists_length"></block>
  <block type="lists_isEmpty"></block>
  <block type="lists_create_with">
    <mutation items="3"></mutation>
  </block>
  <block type="lists_getIndex">
    <mutation statement="false" at="true"></mutation>
    <field name="MODE">GET</field>
    <field name="WHERE">FROM_START</field>
    <value name="VALUE">
      <block type="variables_get">
        <field name="VAR" id="e`(L;x,.j[[XN`F33Q5." variabletype="">list</field>
      </block>
    </value>
  </block>
  <block type="lists_setIndex">
    <mutation at="true"></mutation>
    <field name="MODE">SET</field>
    <field name="WHERE">FROM_START</field>
    <value name="LIST">
      <block type="variables_get">
        <field name="VAR" id="e`(L;x,.j[[XN`F33Q5." variabletype="">list</field>
      </block>
    </value>
  </block>
  <block type="lists_getSublist">
    <mutation at1="true" at2="true"></mutation>
    <field name="WHERE1">FROM_START</field>
    <field name="WHERE2">FROM_START</field>
    <value name="LIST">
      <block type="variables_get">
        <field name="VAR" id="e`(L;x,.j[[XN`F33Q5." variabletype="">list</field>
      </block>
    </value>
  </block>
  <block type="lists_split">
    <mutation mode="SPLIT"></mutation>
    <field name="MODE">SPLIT</field>
    <value name="DELIM">
      <shadow type="text">
        <field name="TEXT">,</field>
      </shadow>
    </value>
  </block>
  <block type="lists_sort">
    <field name="TYPE">NUMERIC</field>
    <field name="DIRECTION">1</field>
  </block>
    </category>
    <category name="Colour" colour="#A6745C">
  <block type="colour_picker">
    <field name="COLOUR">#ff0000</field>
  </block>
  <block type="colour_random"></block>
  <block type="colour_rgb">
    <value name="RED">
      <shadow type="math_number">
        <field name="NUM">100</field>
      </shadow>
    </value>
    <value name="GREEN">
      <shadow type="math_number">
        <field name="NUM">50</field>
      </shadow>
    </value>
    <value name="BLUE">
      <shadow type="math_number">
        <field name="NUM">0</field>
      </shadow>
    </value>
  </block>
  <block type="colour_blend">
    <value name="COLOUR1">
      <shadow type="colour_picker">
        <field name="COLOUR">#ff0000</field>
      </shadow>
    </value>
    <value name="COLOUR2">
      <shadow type="colour_picker">
        <field name="COLOUR">#3333ff</field>
      </shadow>
    </value>
    <value name="RATIO">
      <shadow type="math_number">
        <field name="NUM">0.5</field>
      </shadow>
    </value>
  </block>
    </category>
    <sep></sep>
    <category name="Variables" colour="#A65C81" custom="VARIABLE"></category>
    <category name="Functions" colour="#9A5CA6" custom="PROCEDURE"></category>
  </xml>
  ''';

const List<Map<String, dynamic>> initialToolboxCategories = [
  {
    'name': 'Controls',
    'blocks': [
      {'type': 'controls_if'},
      {
        'type': 'controls_repeat_ext',
        'values': {
          'TIMES': {
            'type': 'math_number',
            'shadow': true,
            'fields': {
              'NUM': 10,
            },
          },
        },
        'statements': {
          'DO': {
            'type': 'text_print',
            'shadow': true,
            'values': {
              'text': {
                'type': 'text',
                'shadow': true,
                'fields': {
                  'text': 'abc',
                },
              },
            },
          },
        },
      },
    ],
  },
  {
    'name': 'Text',
    'blocks': [
      {'type': 'text'},
      {
        'type': 'text_print',
        'values': {
          'text': {
            'type': 'text',
            'shadow': true,
            'fields': {
              'text': 'abc',
            },
          },
        },
      },
    ],
  },
];