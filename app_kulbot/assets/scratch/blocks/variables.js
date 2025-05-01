'use strict';


Blockly.defineBlocksWithJsonArray([

    {
        "type": "define_variable",
        "message0": "Define: %1 Value %2",
        "args0": [
            {
                "type": "field_input",
                "name": "VAR",
            },
            {
                "type": "input_value",
                "name": "VALUE"
            }
        ],
        "previousStatement": true,
        "nextStatement": true,
        'colour':122
        //"style": "variable_blocks"
    },
    {
        'type': 'create_a_variable',
        'message0':'Create A Variable: Type %1  :Name  %2',
        'args0': [
            {
                'type': 'field_dropdown',
                'name': 'TYPE',
                'options': [
                    ['Character', 'Character'], 
                    ['Float','Float'],
                    ['Integer','Integer'],
                ]
            },
            {
                'type': 'field_input',
                'name': 'NAME'
            }

        ],
        'previousStatement': true,
        'nextStatement': true,
        'colour': 122
    },
    {
        
    }
]);