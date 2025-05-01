'use strict';

Blockly.defineBlocksWithJsonArray([

{
  "type": "motor1",
  "message0": "Motor1: Port %1 %2 Out %3",
  "args0": [
    {
      "type": "field_dropdown",
      "name": "motor1_port1",
      "options": [
        ["M1", "1"],
        ["M2", "2"]
      ]
    },
    {
      "type": "field_dropdown",
      "name": "motor1_port2",
      "options": [
        ["Front", "1"],
        ["Back", "2"]
      ]
    },
    {
          "type": "field_number",
          "name": "out",
          "value": 0,
          "min": 0
        }
  ],
  "inputsInline": true,
  "previousStatement": true,
  "nextStatement": true,
  "colour": 230
},

{
  "type": "Servo",
  "message0": "Servo: Port %1 Out %2",
  "args0": [
    {
      "type": "field_dropdown",
      "name": "servo_port1",
      "options": [
        ["1", "1"],
        ["2", "2"],
        ["3", "1"],
        ["4", "1"],
        ["5", "1"],
        ["6", "1"],
        ["7", "1"],
        ["8", "1"],
      ]
    },
    {
          "type": "field_number",
          "name": "out",
          "value": 90,
          "min": 0
        }
  ],
  "inputsInline": true,
  "previousStatement": true,
  "nextStatement": true,
  "colour": 230
},

//{
//  "type": "SetEncoder",
//  "message0": "Set Encoder: Port %1 Out %2",
//  "args0": [
//    {
//      "type": "field_dropdown",
//      "name": "setEncoder_port1",
//      "options": [
//        ["M1", "1"],
//        ["M2", "2"]
//      ]
//    },
//    {
//          "type": "field_number",
//          "name": "out",
//          "value": 0,
//          "min": 0
//        }
//  ],
//  "inputsInline": true,
//  "previousStatement": true,
//  "nextStatement": true,
//  "colour": 230
//}
]);
