'use strict';

const loop = 'controls_forever';
const block_wait_seconds = "wait_seconds";

Blockly.defineBlocksWithJsonArray([

    {
        "type": block_wait_seconds,
        "message0": "wait %1 seconds",
        "inputsInline": true,
        "args0": [
          {
            "type": "input_value",
            "name": "TIMEOUT",
            "check": "Number",
          }
        ],
        "previousStatement": null,
        "nextStatement": null,
        "colour": 120
    },
    {
        "type": "controls_repeat",
        "message0": "repeat %1 ",
        "args0": [
          {
            "type": "input_value",
            "name": "TIMES",
          }
        ],
        "message1": "%1",
        "args1": [
          {
            "type": "input_statement",
            "name": "DO"
          }
        ],
        "previousStatement": null,
        "nextStatement": null,
        "colour": 120,
        "tooltip": "Lặp lại một hành động nhiều lần.",
      },
      {
        "type": loop,
        "message0": "forever",
        
        "message1": "%1",
        "args1": [
          {
            "type": "input_statement",
            "name": "LOOP"
          }
        ],
        'args2': [],
        "previousStatement": null,
        // "nextStatement": false,
        "colour": 120,
        "tooltip": "Lặp lại một hành động nhiều lần.",
      }
    ,
    {
        "type": "wait_until",
        "message0": "wait until %1 ",
        "args0": [
          {
            "type": "input_value",
            "name": "wait_until_boolean",
            "check": "Boolean"
          }
        ],
        "previousStatement": null,
        "nextStatement": null,
        "colour": 120,
        "tooltip": "Lặp lại một hành động nhiều lần.",
      }
      ,
      {
        "type": "controls_repeat_until",
        "message0": "repeat until %1 ",
        "args0": [
          {
            "type": "input_value",
            "name": "repeat_until_boolean",
            "check": "Boolean",   

          }
        ],
        "message1": "%1",
        "args1": [
          {
            "type": "input_statement",
            "name": "DO"
          }
        ],
        "previousStatement": null,
        "nextStatement": null,
        "colour": 120,
        "tooltip": "Lặp lại một hành động nhiều lần.",
      },
      

]);


// javascript.javascriptGenerator.forBlock[loop] = function(block, generator) {
//   try {
//     const loop = `void loop() { \n k \n}`;
    
//     const code = loop;
//     return code;
    
//   } catch (e) {
//     console.error("Error generating code:", e);
//     return 'Error generating code';
//   }
// };
// javascript.javascriptGenerator.forBlock[block_wait_seconds] = function (block) {
//   try{
//   var timeoutBlock = block.getInputTargetBlock('TIMEOUT');
//   // Nếu tồn tại khối con và là kiểu 'math_number', lấy giá trị của nó
//   var code1 = (timeoutBlock && timeoutBlock.type === 'math_number') ? timeoutBlock.getFieldValue('NUM') : '1';
//   var code = 'delay(' + code1 + ' * 1000);';
 
//   return code; 
// }catch(e){
//   console.error('Error generating code:', e);
//   return 'Error generating code';
// }
// };