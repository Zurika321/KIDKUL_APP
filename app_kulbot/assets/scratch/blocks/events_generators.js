"use strict";

var javascriptGenerator = {
  setupCode: "",
  loopCode: "",
  variableDeclarations: "",
  declaredVariablesSet: new Set(),
  processedBlockIds: new Set(), // Track processed block IDs to prevent duplication
  sensorInitAdded: false,
  sensorInitCode: "",
  lineSensorInitSet: new Set(),
  blockToCode: function (block) {
    // Example implementation for converting block to code
    return block.getGeneratedCode(); // Replace with actual logic to generate block code
  },
};

Blockly.defineBlocksWithJsonArray([
  {
    type: "event_program_starts",
    message0: "when Kulbot starts",
    colour: 120,
    nextStatement: true,
  },

  {
    type: "control_wait_seconds",
    message0: "wait %1 seconds",
    inputsInline: true,
    args0: [
      {
        type: "input_value",
        name: "TIMEOUT",
        check: "Number",
      },
    ],
    previousStatement: null,
    nextStatement: null,
    colour: 120,
  },

  {
    type: "control_forever",
    message0: "forever",
    message1: "%1",
    args1: [{ type: "input_statement", name: "DO" }],
    previousStatement: null,
    nextStatement: null,
    colour: 120,
    tooltip: "",
    helpUrl: "",
  },

  {
    type: "control_repeat",
    message0: "repeat %1 ",
    args0: [
      {
        type: "input_value",
        name: "TIMES",
        check: "Number",
      },
    ],
    message1: "%1",
    args1: [
      {
        type: "input_statement",
        name: "DO",
      },
    ],
    previousStatement: null,
    nextStatement: null,
    colour: 120,
    tooltip: "Lặp lại một hành động nhiều lần.",
  },

  {
    type: "control_if",
    message0: "if %1 then ",
    args0: [
      {
        type: "input_value",
        name: "if_boolean",
        check: "Boolean",
      },
    ],
    message1: "%1",
    args1: [
      {
        type: "input_statement",
        name: "DO",
      },
    ],
    previousStatement: null,
    nextStatement: null,
    colour: 120,
    tooltip: "Lặp lại một hành động nhiều lần.",
  },

  {
    type: "control_if_then_else",
    message0: "if %1 then",
    args0: [
      {
        type: "input_value",
        name: "if_boolean",
        check: "Boolean",
      },
    ],
    message1: "%1",
    args1: [
      {
        type: "input_statement",
        name: "DO",
      },
    ],
    message2: "else %1",
    args2: [
      {
        type: "input_statement",
        name: "ELSE",
      },
    ],
    previousStatement: null,
    nextStatement: null,
    colour: 120,
    tooltip: "If-then-else block",
    helpUrl: "",
  },

  {
    type: "control_repeat_until",
    message0: "repeat until %1 ",
    args0: [
      {
        type: "input_value",
        name: "repeat_until_boolean",
        check: "Boolean",
      },
    ],
    message1: "%1",
    args1: [
      {
        type: "input_statement",
        name: "DO",
      },
    ],
    previousStatement: null,
    nextStatement: null,
    colour: 120,
    tooltip: "Lặp lại một hành động nhiều lần.",
  },
  {
    type: "operators_plus",
    message0: "%1 + %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Number",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Number",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Number",
    colour: 150,
    tooltip: "Cộng hai số",
    helpUrl: "",
  },
  {
    type: "operators_minus",
    message0: "%1 - %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Number",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Number",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Number",
    colour: 150,
    tooltip: "Trừ hai số",
    helpUrl: "",
  },
  {
    type: "operators_multiply",
    message0: "%1 * %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Number",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Number",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Number",
    colour: 150,
    tooltip: "Nhân hai số",
    helpUrl: "",
  },
  {
    type: "operators_divine",
    message0: "%1 / %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Number",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Number",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Number",
    colour: 150,
    tooltip: "Chia hai số",
    helpUrl: "",
  },
  {
    type: "operators_random",
    message0: "pick random %1 to %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Number",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Number",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Number",
    colour: 150,
    tooltip: "",
    helpUrl: "",
  },
  {
    type: "operators_more_than",
    message0: "%1 > %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Number",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Number",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Boolean",
    colour: 150,
    tooltip: "",
    helpUrl: "",
  },
  {
    type: "operators_less_than",
    message0: "%1 < %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Number",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Number",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Boolean",
    colour: 150,
    tooltip: "",
    helpUrl: "",
  },
  {
    type: "operators_equal",
    message0: "%1 = %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Number",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Number",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Boolean",
    colour: 150,
    tooltip: "",
    helpUrl: "",
  },
  {
    type: "operators_and",
    message0: "%1 and %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Boolean",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Boolean",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Boolean",
    colour: 150,
    tooltip: "",
    helpUrl: "",
  },
  {
    type: "operators_or",
    message0: "%1 or %2",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Boolean",
      },
      {
        type: "input_value",
        name: "NUM2",
        check: "Boolean",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Boolean",
    colour: 150,
    tooltip: "",
    helpUrl: "",
  },
  {
    type: "operators_not",
    message0: "not %1",
    args0: [
      {
        type: "input_value",
        name: "NUM1",
        check: "Boolean",
      },
    ],
    inputsInline: true, // Để các input nằm trên cùng một hàng
    output: "Boolean",
    colour: 150,
    tooltip: "",
    helpUrl: "",
  },
  {
    type: "move",
    message0: "%1, speed %2, continued %3 s",
    args0: [
      {
        type: "field_dropdown",
        name: "run_variable",
        options: [
          ["Move forward", "Move forward"],
          ["Turn left", "Turn left"],
          ["Turn right", "Turn right"],
          ["Move backward", "Move backward"],
        ],
      },
      {
        type: "field_dropdown",
        name: "speed_variable",
        options: [
          ["Slow", "Slow"],
          ["Middle", "Middle"],
          ["Fast", "Fast"],
        ],
      },
      {
        type: "field_number",
        name: "time_variable",
        value: 0,
        min: 0,
        max: 10,
        precision: 0.01,
      },
    ],
    inputsInline: true,
    previousStatement: true,
    nextStatement: true,
    colour: 230,
  },

  {
    type: "variables_create",
    message0: "%1",
    args0: [
      {
        type: "field_variable",
        name: "VAR",
        variable: "item",
      },
    ],
    style: "variable_blocks",
    tooltip: "Create a new variable.",
    helpUrl: "",
    output: "Number",
  },
  {
    type: "variables_set",
    message0: "set %1 to %2",
    args0: [
      {
        type: "field_variable",
        name: "VAR",
        variable: "item",
      },
      {
        type: "input_value",
        name: "VALUE",
        check: "Number",
      },
    ],
    previousStatement: null,
    nextStatement: null,
    style: "variable_blocks",
    tooltip: "Set the value of a variable.",
    helpUrl: "",
  },
  {
    type: "variables_change",
    message0: "change %1 by %2",
    args0: [
      {
        type: "field_variable",
        name: "VAR",
        variable: "item",
      },
      {
        type: "input_value",
        name: "DELTA",
        check: "Number",
      },
    ],
    previousStatement: null,
    nextStatement: null,
    style: "variable_blocks",
    tooltip: "Change the value of a variable.",
    helpUrl: "",
  },

  {
    type: "sensor_ultrasonic",
    message0: "Ultrasonic: %1 (cm)",
    args0: [
      {
        type: "field_dropdown",
        name: "sensor_ultrasonic_port",
        options: [
          ["1", "1"],
          ["2", "2"],
          ["3", "3"],
          ["4", "4"],
          ["5", "5"],
          ["6", "6"],
          ["7", "7"],
          ["8", "8"],
        ],
      },
    ],
    output: "Number",
    colour: 230,
  },
  {
    type: "sensor_get_line",
    message0: "Get Line: Port %1 with line %2",
    args0: [
      {
        type: "field_dropdown",
        name: "sensor_get_line_port_1",
        options: [
          ["1", "1"],
          ["2", "2"],
          ["3", "3"],
          ["4", "4"],
          ["5", "5"],
          ["6", "6"],
          ["7", "7"],
          ["8", "8"],
        ],
      },
      {
        type: "field_dropdown",
        name: "sensor_get_line_port_2",
        options: [
          ["Right", "1"],
          ["Left", "2"],
        ],
      },
    ],
    output: "Boolean",
    colour: 230,
  },
]);

// block_events
javascript.javascriptGenerator.forBlock["event_program_starts"] = function (
  block
) {
  var code1 = "#include <Arduino.h>";
  var code2 = "#include <KULBOT.h>";
  var code3 = "KULBOT Rob;";
  var code4 = "Rob.KULBOT.INIT();";

  // Initialize setup and loop code as empty strings
  javascriptGenerator.setupCode = "";
  javascriptGenerator.loopCode = "";
  javascriptGenerator.variableDeclarations = "";
  javascriptGenerator.declaredVariablesSet.clear();
  javascriptGenerator.processedBlockIds.clear(); // Reset processed blocks
  javascriptGenerator.sensorInitAdded = false;
  javascriptGenerator.sensorInitCode = "";
  javascriptGenerator.lineSensorInitSet.clear();

  // Loop through the child blocks of block_when_to_start
  var nextBlock = block.getNextBlock();
  while (nextBlock) {
    // Get the code of the child block
    var nextCode = javascript.javascriptGenerator.blockToCode(nextBlock);

    if (nextBlock.type === "block_declare_variable") {
      // Handle variable declaration blocks
      var variableDeclaration = nextCode;
      runInVariables(variableDeclaration); // Add to variable declarations
    } else if (nextBlock.type === "javascript.setup") {
      runInSetup(nextCode, nextBlock.id);
    } else if (nextBlock.type === "javascript.loop") {
      runInLoop(nextCode, nextBlock.id);
    }

    nextBlock = nextBlock.getNextBlock(); // Move to the next block
  }

  // Combine all unique line sensor initializations
  var lineSensorInitCode = Array.from(javascriptGenerator.lineSensorInitSet)
    .map((port) => `Rob.KULBOT_LINE_SENSOR_INIT(${port});`)
    .join("\n");

  // Final Arduino sketch code
  var finalCode = `
${code1}
${code2}
${code3}
${javascriptGenerator.variableDeclarations}

void setup() {
  ${code4}
  ${javascriptGenerator.sensorInitCode}
  ${lineSensorInitCode}
  ${javascriptGenerator.setupCode}
}

void loop() {
  ${javascriptGenerator.loopCode}
}
`;

  return finalCode;
};

// Function to add code to void setup()
function runInSetup(code, blockId) {
  if (!javascriptGenerator.processedBlockIds.has(blockId)) {
    javascriptGenerator.setupCode += code + "\n";
    javascriptGenerator.processedBlockIds.add(blockId); // Mark block as processed
  }
}
// Function to add code to void loop()
function runInLoop(code, blockId) {
  if (!javascriptGenerator.processedBlockIds.has(blockId)) {
    javascriptGenerator.loopCode += code + "\n";
    javascriptGenerator.processedBlockIds.add(blockId); // Mark block as processed
  }
}

// Function to add variable declarations
function runInVariables(variableDeclaration) {
  var variableName = variableDeclaration.split(" ")[1]; // Extract second word (the variable name)

  // Check if the variable has already been declared
  if (!javascriptGenerator.declaredVariablesSet.has(variableName)) {
    // If not declared, add to set and to variable declarations
    javascriptGenerator.declaredVariablesSet.add(variableName);
    javascriptGenerator.variableDeclarations += variableDeclaration + "\n";
  }
}

function generateDefaultCode(code, blockId) {
  // Check if the blockId has already been processed
  if (!javascriptGenerator.processedBlockIds.has(blockId)) {
    // If not processed, add the blockId to the set and return the code
    javascriptGenerator.processedBlockIds.add(blockId); // Mark block as processed
    return code + "\n";
  } else {
    return "";
  }
}

javascript.javascriptGenerator.forBlock["control_forever"] = function (block) {
  var loopCode = "";
  var doBlock = block.getInputTargetBlock("DO");
  while (doBlock) {
    var code = javascript.javascriptGenerator.blockToCode(doBlock);
    loopCode += code + "\n";
    doBlock = doBlock.getNextBlock();
  }
  javascriptGenerator.loopCode += loopCode;
  return "";
};

javascript.javascriptGenerator.forBlock["move"] = function (block) {
  var action = block.getFieldValue("run_variable");
  var speed = block.getFieldValue("speed_variable");
  var time = block.getFieldValue("time_variable");
  var code =
    'performAction({"action":"' +
    action +
    '","speed":"' +
    speed +
    '","time":' +
    time +
    "});";
  return code;
};

// block_create_variable

javascript.javascriptGenerator.forBlock["variables_create"] = function (block) {
  var variable_name = Blockly.JavaScript.nameDB_.getName(
    block.getFieldValue("VAR"),
    Blockly.Names.NameType.VARIABLE
  );
  var code = "float " + variable_name + ";\n";
  runInVariables(code);
  return [variable_name, Blockly.JavaScript.ORDER_ATOMIC];
};

javascript.javascriptGenerator.forBlock["variables_change"] = function (block) {
  // Get the variable name
  var variable_name = Blockly.JavaScript.nameDB_.getName(
    block.getFieldValue("VAR"),
    Blockly.Names.NameType.VARIABLE
  );

  // Get the value to change by (DELTA)
  var delta =
    Blockly.JavaScript.valueToCode(
      block,
      "DELTA",
      Blockly.JavaScript.ORDER_ADDITION
    ) || "0";

  // Variable declaration (if not already declared)
  var code1 = "float " + variable_name + ";\n";

  // Check if the variable has already been declared
  if (!javascriptGenerator.declaredVariablesSet.has(variable_name)) {
    runInVariables(code1); // Only declare if not already declared
    javascriptGenerator.declaredVariablesSet.add(variable_name); // Mark as declared
  }

  // Generate the code to increment the variable
  var code = variable_name + " += " + delta + ";\n";
  // Kiểm tra vị trí của block
  var parentBlock = block.getSurroundParent();

  // Nếu block nằm trong các khối lặp hoặc điều kiện, trả về mã mà không thêm vào setup/loop
  if (
    parentBlock &&
    (parentBlock.type === "control_repeat" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  }

  // Nếu block đứng riêng lẻ, thêm mã lệnh vào void setup
  runInSetup(code, block.id);
  return "";
};

javascript.javascriptGenerator.forBlock["variables_set"] = function (block) {
  // Get the variable name
  var variable_name = Blockly.JavaScript.nameDB_.getName(
    block.getFieldValue("VAR"),
    Blockly.Names.NameType.VARIABLE
  );

  // Get the value to change by (DELTA)
  var value =
    Blockly.JavaScript.valueToCode(
      block,
      "VALUE",
      Blockly.JavaScript.ORDER_ADDITION
    ) || "0";

  // Variable declaration (if not already declared)
  var code1 = "float " + variable_name + ";\n";

  // Check if the variable has already been declared
  if (!javascriptGenerator.declaredVariablesSet.has(variable_name)) {
    runInVariables(code1); // Only declare if not already declared
    javascriptGenerator.declaredVariablesSet.add(variable_name); // Mark as declared
  }

  // Generate the code to increment the variable
  var code = variable_name + " = " + value + ";\n";
  // Kiểm tra vị trí của block
  var parentBlock = block.getSurroundParent();

  // Nếu block nằm trong các khối lặp hoặc điều kiện, trả về mã mà không thêm vào setup/loop
  if (
    parentBlock &&
    (parentBlock.type === "control_repeat" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  }
  // Nếu block đứng riêng lẻ, thêm mã lệnh vào void setup
  runInSetup(code, block.id);
  return "";
};

//block_control

javascript.javascriptGenerator.forBlock["control_wait_seconds"] = function (
  block
) {
  var timeoutBlock = block.getInputTargetBlock("TIMEOUT");

  var timeoutCode;

  // Nếu có khối được kết nối với TIMEOUT, lấy mã của khối đó (có thể là biến)
  if (timeoutBlock) {
    timeoutCode = javascript.javascriptGenerator.blockToCode(timeoutBlock)[0]; // Lấy tên biến hoặc giá trị từ khối kết nối
  } else {
    // Nếu không có khối kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    timeoutCode = block.getFieldValue("NUM") || "1";
  }

  // Không sử dụng parseFloat ở đây, vì timeoutCode có thể là tên biến chứ không phải là số
  // Chỉ xử lý số nguyên nếu timeoutCode là giá trị số trực tiếp
  if (!isNaN(timeoutCode)) {
    timeoutCode =
      parseFloat(timeoutCode) % 1 === 0
        ? parseFloat(timeoutCode).toFixed(0)
        : parseFloat(timeoutCode);
  }

  // Tạo mã lệnh delay dựa trên giá trị đã lấy
  var code = "delay(" + timeoutCode + " * 1000);\n";

  // Kiểm tra vị trí của block
  var parentBlock = block.getSurroundParent();

  // Nếu block nằm trong các khối lặp hoặc điều kiện, trả về mã mà không thêm vào setup/loop
  if (
    parentBlock &&
    (parentBlock.type === "control_repeat" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  }

  // Nếu block đứng riêng lẻ, thêm mã lệnh vào void setup
  runInSetup(code, block.id);
  return "";
};

javascript.javascriptGenerator.forBlock["control_repeat"] = function (block) {
  // Retrieve the repeat count from the "TIMES" input or shadow block
  var repeatCount = block.getInputTargetBlock("TIMES");
  if (!repeatCount) {
    repeatCount = block.getFieldValue("NUM") || "10"; // Default to 10 if no value provided
  } else {
    repeatCount = javascript.javascriptGenerator.blockToCode(repeatCount); // Get the code for TIMES block
  }

  // Initialize the body of the repeat loop
  var loopBody = "";

  // Get the blocks inside the 'DO' input
  var doBlock = block.getInputTargetBlock("DO");

  // Traverse and generate code for all blocks inside the repeat block
  while (doBlock) {
    var code = javascript.javascriptGenerator.blockToCode(doBlock); // Generate code for child blocks
    if (code) {
      loopBody += code + "\n"; // Append the generated code to the loop body
    }
    doBlock = doBlock.getNextBlock(); // Move to the next block
  }

  // Generate the for loop code, placing the loopBody (which includes delay) inside the loop
  var code =
    "for (int i = 0; i < " + repeatCount + "; i++) {\n" + loopBody + "}\n";

  // Determine the placement of the generated code
  var parentBlock = block.getSurroundParent();
  if (
    parentBlock &&
    (parentBlock.type === "control_forever" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  }
  if (
    parentBlock &&
    (parentBlock.type === "control_repeat" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  } else {
    runInSetup(code, block.id);
  }

  return "";
};

javascript.javascriptGenerator.forBlock["control_forever"] = function (block) {
  var loopCode = "";
  var doBlock = block.getInputTargetBlock("DO");
  while (doBlock) {
    var code = javascript.javascriptGenerator.blockToCode(doBlock);
    loopCode += code + "\n";
    doBlock = doBlock.getNextBlock();
  }
  javascriptGenerator.loopCode += loopCode;
  return "";
};

javascript.javascriptGenerator.forBlock["control_if"] = function (block) {
  // Get the boolean input from the "if_boolean" field
  var conditionBlock = block.getInputTargetBlock("if_boolean");

  // Default to "false" if there is no connected block
  var conditionCode = conditionBlock
    ? javascript.javascriptGenerator.blockToCode(conditionBlock)[0]
    : "false";

  // Initialize the code for the 'DO' input, which contains the actions inside the if statement
  var doCode = "";
  var doBlock = block.getInputTargetBlock("DO");

  // Traverse through all the blocks inside the 'DO' input and generate their code
  while (doBlock) {
    var code = javascript.javascriptGenerator.blockToCode(doBlock);
    if (code) {
      doCode += code + "\n";
    }
    doBlock = doBlock.getNextBlock(); // Move to the next block inside 'DO'
  }
  var code = "if (" + conditionCode + ") {\n" + doCode + "}\n";

  // Determine the placement of the generated code

  var parentBlock = block.getSurroundParent();
  if (
    parentBlock &&
    (parentBlock.type === "control_forever" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  }
  if (
    parentBlock &&
    (parentBlock.type === "control_repeat" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  } else {
    runInSetup(code, block.id);
  }

  return "";
};

javascript.javascriptGenerator.forBlock["control_if_then_else"] = function (
  block
) {
  // Get the boolean input from the "if_boolean" field
  var conditionBlock = block.getInputTargetBlock("if_boolean");

  // Default to "false" if there is no connected block
  var conditionCode = conditionBlock
    ? javascript.javascriptGenerator.blockToCode(conditionBlock)[0]
    : "false";

  // Initialize the code for the 'DO' input, which contains the actions inside the if statement
  var doCode = "";
  var doBlock = block.getInputTargetBlock("DO");

  var elseCode = "";
  var elseBlock = block.getInputTargetBlock("ELSE");

  // Traverse through all the blocks inside the 'DO' input and generate their code
  while (doBlock) {
    var code = javascript.javascriptGenerator.blockToCode(doBlock);
    if (code) {
      doCode += code + "\n";
    }
    doBlock = doBlock.getNextBlock(); // Move to the next block inside 'DO'
  }
  while (elseBlock) {
    var code = javascript.javascriptGenerator.blockToCode(elseBlock);
    if (code) {
      elseCode += code + "\n";
    }
    elseBlock = elseBlock.getNextBlock();
  }
  var code =
    "if (" + conditionCode + ") {\n" + doCode + "} else {\n" + elseCode + "}\n";

  var parentBlock = block.getSurroundParent();
  if (
    parentBlock &&
    (parentBlock.type === "control_forever" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  }
  if (
    parentBlock &&
    (parentBlock.type === "control_repeat" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  } else {
    runInSetup(code, block.id);
  }

  return "";
};

javascript.javascriptGenerator.forBlock["control_repeat_until"] = function (
  block
) {
  // Get the boolean input from the "if_boolean" field
  var conditionBlock = block.getInputTargetBlock("repeat_until_boolean");

  // Default to "false" if there is no connected block
  var conditionCode = conditionBlock
    ? javascript.javascriptGenerator.blockToCode(conditionBlock)
    : "!false";

  // Initialize the code for the 'DO' input, which contains the actions inside the if statement
  var doCode = "";
  var doBlock = block.getInputTargetBlock("DO");

  // Traverse through all the blocks inside the 'DO' input and generate their code
  while (doBlock) {
    var code = javascript.javascriptGenerator.blockToCode(doBlock);
    if (code) {
      doCode += code + "\n";
    }
    doBlock = doBlock.getNextBlock(); // Move to the next block inside 'DO'
  }
  var code = "while (" + conditionCode + ") {\n" + doCode + "}\n";

  // Determine the placement of the generated code

  var parentBlock = block.getSurroundParent();
  if (
    parentBlock &&
    (parentBlock.type === "control_forever" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  }
  if (
    parentBlock &&
    (parentBlock.type === "control_repeat" ||
      parentBlock.type === "control_forever" ||
      parentBlock.type === "control_if" ||
      parentBlock.type === "control_if_then_else" ||
      parentBlock.type === "control_repeat_until")
  ) {
    return generateDefaultCode(code, block.id);
  } else {
    runInSetup(code, block.id);
  }

  return "";
};

//block_operators

javascript.javascriptGenerator.forBlock["operators_plus"] = function (block) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = "(" + num1Code + " + " + num2Code + ")";
  return [code, Blockly.JavaScript.ORDER_ADDITION];
};

javascript.javascriptGenerator.forBlock["operators_minus"] = function (block) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = "(" + num1Code + " - " + num2Code + ")";
  return [code, Blockly.JavaScript.ORDER_ADDITION];
};

javascript.javascriptGenerator.forBlock["operators_multiply"] = function (
  block
) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = "(" + num1Code + " * " + num2Code + ")";
  return [code, Blockly.JavaScript.ORDER_ADDITION];
};

javascript.javascriptGenerator.forBlock["operators_divine"] = function (block) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = "(" + num1Code + " / " + num2Code + ")";
  return [code, Blockly.JavaScript.ORDER_ADDITION];
};

javascript.javascriptGenerator.forBlock["operators_random"] = function (block) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = "(random(" + num1Code + "," + num2Code + ")";
  return [code, Blockly.JavaScript.ORDER_ADDITION];
};

javascript.javascriptGenerator.forBlock["operators_more_than"] = function (
  block
) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = num1Code + " > " + num2Code;
  return [code, Blockly.JavaScript.ORDER_RELATIONAL];
};

javascript.javascriptGenerator.forBlock["operators_less_than"] = function (
  block
) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = num1Code + " < " + num2Code;
  return [code, Blockly.JavaScript.ORDER_RELATIONAL];
};

javascript.javascriptGenerator.forBlock["operators_equal"] = function (block) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = num1Code + " = " + num2Code;
  return [code, Blockly.JavaScript.ORDER_RELATIONAL];
};

javascript.javascriptGenerator.forBlock["operators_and"] = function (block) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = num1Code + " && " + num2Code;
  return [code, Blockly.JavaScript.ORDER_RELATIONAL];
};

javascript.javascriptGenerator.forBlock["operators_or"] = function (block) {
  var num1Block = block.getInputTargetBlock("NUM1");
  var num2Block = block.getInputTargetBlock("NUM2");

  var num1Code, num2Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "0";
  }

  // Nếu có block kết nối với "NUM2", lấy mã của block đó (có thể là biến)
  if (num2Block) {
    num2Code = javascript.javascriptGenerator.blockToCode(num2Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num2Code = block.getFieldValue("NUM2") || "0";
  }

  // Không sử dụng parseFloat với biến, chỉ xử lý số nguyên và số thực nếu là số trực tiếp
  if (!isNaN(num1Code)) {
    num1Code =
      parseFloat(num1Code) % 1 === 0
        ? parseFloat(num1Code).toFixed(0)
        : parseFloat(num1Code);
  }

  if (!isNaN(num2Code)) {
    num2Code =
      parseFloat(num2Code) % 1 === 0
        ? parseFloat(num2Code).toFixed(0)
        : parseFloat(num2Code);
  }

  // Tạo code cho phép cộng
  var code = num1Code + " || " + num2Code;
  return [code, Blockly.JavaScript.ORDER_RELATIONAL];
};

javascript.javascriptGenerator.forBlock["operators_not"] = function (block) {
  var num1Block = block.getInputTargetBlock("NUM1");

  var num1Code;

  // Nếu có block kết nối với "NUM1", lấy mã của block đó (có thể là biến hoặc biểu thức boolean)
  if (num1Block) {
    num1Code = javascript.javascriptGenerator.blockToCode(num1Block)[0];
  } else {
    // Nếu không có block kết nối, sử dụng giá trị mặc định hoặc giá trị shadow
    num1Code = block.getFieldValue("NUM1") || "false"; // Mặc định là false nếu không có gì được kết nối
  }

  // Kiểm tra nếu num1Code là boolean hoặc biểu thức boolean
  // Nếu là một biểu thức, cần thêm dấu ngoặc đơn cho rõ ràng
  var code = "!(" + num1Code + ")";

  // Trả về mã của khối not với mức ưu tiên quan hệ ORDER_LOGICAL_NOT
  return [code, Blockly.JavaScript.ORDER_LOGICAL_NOT];
};

//block_sensor

javascript.javascriptGenerator.forBlock["sensor_ultrasonic"] = function (
  block
) {
  // Lấy giá trị của cổng cảm biến từ field dropdown
  var sensorPort = block.getFieldValue("sensor_ultrasonic_port");

  // Sinh mã để lấy giá trị từ cảm biến siêu âm
  var sensorCode = "Rob.KULBOT_GET_SONAR_SENSOR(" + sensorPort + ")";

  if (!javascriptGenerator.sensorInitAdded) {
    // Instead of adding to setupCode, assign it to sensorInitCode
    javascriptGenerator.sensorInitCode = "Rob.KULBOT_SENSOR_INIT();\n";
    javascriptGenerator.sensorInitAdded = true; // Ensure it's added only once
  }

  return [sensorCode, Blockly.JavaScript.ORDER_ATOMIC];
};

javascript.javascriptGenerator.forBlock["sensor_get_line"] = function (block) {
  var sensorPort1 = block.getFieldValue("sensor_get_line_port_1");
  var sensorPort2 = block.getFieldValue("sensor_get_line_port_2");
  var sensorCode =
    "Rob.KULBOT_GET_LINE_SENSOR(" + sensorPort1 + "," + sensorPort2 + ")";

  if (!javascriptGenerator.sensorInitAdded) {
    // Instead of adding to setupCode, assign it to sensorInitCode
    javascriptGenerator.sensorInitCode = "Rob.KULBOT_SENSOR_INIT();\n";
    javascriptGenerator.sensorInitAdded = true; // Ensure it's added only once
  }

  javascriptGenerator.lineSensorInitSet.add(sensorPort1);

  return [sensorCode, Blockly.JavaScript.ORDER_ATOMIC];
};
