'use strict';


Blockly.defineBlocksWithJsonArray([
    {
        "type": "lcd_print_number",
        "message0": "LCD Print Number: Port  %1  Column %2 Cell %3 Number %4",
        "args0": [
          {
            "type": "field_dropdown",
            "name": "lcd_numer_port",
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
            "type": "input_value",
            "name": "COLUMN",

            
          },
          {
            "type": "input_value",
            "name": "CELL",
            
          },
          {
            "type": "input_value",
            "name": "NUMBER",

            
          }
        ],
        "inputsInline": true,
        "previousStatement": true,
        "nextStatement": true,
        "colour": 230,
    },
    {
        "type": "lcd_print_str",
        "message0": "LCD Print String: Port  %1  Column %2 Cell %3 String %4",
        "args0": [
          {
            "type": "field_dropdown",
            "name": "lcd_string_port",
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
            "type": "input_value",
            "name": "COLUMN",

            
          },
          {
            "type": "input_value",
            "name": "CELL",

            
          },
          {
            "type": "input_value",
            "name": "STRING",

            
          }
        ],
        "inputsInline": true,
        "previousStatement": true,
        "nextStatement": true,
        "colour": 230,
    },
    {
        "type": "lcd_clear",
        "message0": "LCD Clear: Port  %1 ",
        "args0": [
          {
            "type": "field_dropdown",
            "name": "lcd_clear_port",
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
        // "inputsInline": true,
        "previousStatement": true,
        "nextStatement": true,
        "colour": 230,
    },

]);