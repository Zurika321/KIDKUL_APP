let setup = "def setup():\n";
let loop = "while (1):\n";
//------
function checkConnectedToStart(block) {
  let parent = block.getParent();
  while (parent) {
    if (parent.type === "event_program_starts") {
      block.setWarningText(null);
      return true;
    }
    parent = parent.getParent();
  }
  block.setWarningText(
    'Khối này phải được nối với "when Kulbot starts" để hoạt động.'
  );
  return false;
}

//----------------event_program_starts----
//--- codetong = python.pythonGenerator.forBlock["event_program_starts"](block)
python.pythonGenerator.forBlock["event_program_starts"] = function (block) {
  const statements_do =
    python.pythonGenerator.statementToCode(block, "DO") || "";
  let foreverCode = "";
  let otherCode = "";
  let lines = statements_do.split("\n");
  let inForever = false;

  lines.forEach((line) => {
    if (line.trim().startsWith("while (1):")) {
      inForever = true;
      foreverCode += line.trimStart() + "\n";
    } else if (
      inForever &&
      (line.startsWith("    ") || line.startsWith("\t"))
    ) {
      foreverCode += "\t" + line.replace(/^((\s{4}|\t){1,2})/, "") + "\n";
    } else {
      if (line.trim() !== "") otherCode += "\t" + line.trim() + "\n"; // dùng tab
      inForever = false;
    }
  });

  let code =
    setup +
    // +
    // "\tRob.KULBOT_INIT()\n" +
    // "\tRob.KULBOT_SENSOR_INIT()\n" +
    otherCode +
    "\n";
  code += foreverCode;
  return code;
};

const customBlocks = ["event_program_starts"]; // Thêm block custom khác nếu cần

customBlocks.forEach((blockType) => {
  // Lua
  if (typeof lua !== "undefined" && lua.luaGenerator) {
    lua.luaGenerator.forBlock[blockType] = () => "";
  }

  // Dart
  if (typeof dart !== "undefined" && dart.dartGenerator) {
    dart.dartGenerator.forBlock[blockType] = () => "";
  }

  // PHP
  if (typeof php !== "undefined" && php.phpGenerator) {
    php.phpGenerator.forBlock[blockType] = () => "";
  }
});

//----------------loop_times--------------
python.pythonGenerator.forBlock["loop_times"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const times =
    python.pythonGenerator.valueToCode(
      block,
      "number",
      python.pythonGenerator.ORDER_NONE
    ) || "10";
  const statements_do =
    python.pythonGenerator.statementToCode(block, "DO") ||
    python.pythonGenerator.PASS;
  return `for (int i=0; i<${times}; i++)\n${statements_do}`;
};
//----------------loop_until--------------
python.pythonGenerator.forBlock["loop_until"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const condition =
    python.pythonGenerator.valueToCode(
      block,
      "condition",
      python.pythonGenerator.ORDER_NONE
    ) || "False";
  const statements_do =
    python.pythonGenerator.statementToCode(block, "DO") ||
    python.pythonGenerator.PASS;
  return `while (!${condition})\n${statements_do}`;
};
//------------ loop_forever ------------
python.pythonGenerator.forBlock["loop_forever"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const statements_do =
    python.pythonGenerator.statementToCode(block, "DO") ||
    python.pythonGenerator.PASS;
  return `while (1):\n${statements_do}`;
};
//------------ if ------------
python.pythonGenerator.forBlock["if"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const condition =
    python.pythonGenerator.valueToCode(
      block,
      "CONDITION",
      python.pythonGenerator.ORDER_NONE
    ) || "False";

  const statements_do =
    python.pythonGenerator.statementToCode(block, "DO") ||
    python.pythonGenerator.PASS;

  return `if ${condition}:\n${statements_do}`;
};
//------------ if_else ------------
python.pythonGenerator.forBlock["if_else"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const condition =
    python.pythonGenerator.valueToCode(
      block,
      "CONDITION",
      python.pythonGenerator.ORDER_NONE
    ) || "False";
  const statements_do =
    python.pythonGenerator.statementToCode(block, "DO") ||
    python.pythonGenerator.PASS;
  const statements_else =
    python.pythonGenerator.statementToCode(block, "ELSE") ||
    python.pythonGenerator.PASS;

  return `if ${condition}:\n${statements_do}else:\n${statements_else}`;
};
//------------ Operators ------------
python.pythonGenerator.forBlock["operators"] = function (block) {
  const op = block.getFieldValue("operators");
  const n1 =
    python.pythonGenerator.valueToCode(
      block,
      "number1",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const n2 =
    python.pythonGenerator.valueToCode(
      block,
      "number2",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return [`${n1} ${op} ${n2}`, python.pythonGenerator.ORDER_NONE];
};

python.pythonGenerator.forBlock["formula"] = function (block) {
  const op = block.getFieldValue("formula");
  const num =
    python.pythonGenerator.valueToCode(
      block,
      "number",
      python.pythonGenerator.ORDER_NONE
    ) || "0";

  const ops = {
    abs: `abs(${num})`,
    floor: `math.floor(${num})`,
    ceiling: `math.ceil(${num})`,
    sqrt: `math.sqrt(${num})`,
    sin: `math.sin(${num})`,
    cos: `math.cos(${num})`,
    tan: `math.tan(${num})`,
    asin: `math.asin(${num})`,
    acos: `math.acos(${num})`,
    atan: `math.atan(${num})`,
    ln: `math.log(${num})`,
    log: `math.log10(${num})`,
    "e^": `math.exp(${num})`,
    "10^": `10 ** (${num})`,
    round: `round(${num})`,
  };

  return [ops[op] || "0", python.pythonGenerator.ORDER_NONE];
};

python.pythonGenerator.forBlock["compare"] = function (block) {
  const op = block.getFieldValue("compare");
  const n1 =
    python.pythonGenerator.valueToCode(
      block,
      "number1",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const n2 =
    python.pythonGenerator.valueToCode(
      block,
      "number2",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return [`(${n1} ${op} ${n2})`, python.pythonGenerator.ORDER_NONE];
};

python.pythonGenerator.forBlock["compare_and"] = function (block) {
  const a =
    python.pythonGenerator.valueToCode(
      block,
      "A",
      python.pythonGenerator.ORDER_LOGICAL_AND
    ) || "False";
  const b =
    python.pythonGenerator.valueToCode(
      block,
      "B",
      python.pythonGenerator.ORDER_LOGICAL_AND
    ) || "False";
  return [`(${a} and ${b})`, python.pythonGenerator.ORDER_LOGICAL_AND];
};

python.pythonGenerator.forBlock["compare_or"] = function (block) {
  const a =
    python.pythonGenerator.valueToCode(
      block,
      "A",
      python.pythonGenerator.ORDER_LOGICAL_OR
    ) || "False";
  const b =
    python.pythonGenerator.valueToCode(
      block,
      "B",
      python.pythonGenerator.ORDER_LOGICAL_OR
    ) || "False";
  return [`(${a} or ${b})`, python.pythonGenerator.ORDER_LOGICAL_OR];
};

python.pythonGenerator.forBlock["compare_not"] = function (block) {
  const value =
    python.pythonGenerator.valueToCode(
      block,
      "BOOL",
      python.pythonGenerator.ORDER_LOGICAL_NOT
    ) || "False";
  return [`(not ${value})`, python.pythonGenerator.ORDER_LOGICAL_NOT];
};

python.pythonGenerator.forBlock["random"] = function (block) {
  const from =
    python.pythonGenerator.valueToCode(
      block,
      "FROM",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const to =
    python.pythonGenerator.valueToCode(
      block,
      "TO",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "100";
  return [`random.randint(${from}, ${to})`, python.pythonGenerator.ORDER_NONE];
};
//-----------------led-------------------

python.pythonGenerator.forBlock["led_on"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const color = block.getFieldValue("color");
  return `Rob.KULBOT_RGB_ON(${port},${color})\n`;
};
//Rob.KULBOT_RGB_INIT(100);
python.pythonGenerator.forBlock["led_off"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_RGB_OFF(${port})\n`;
};

python.pythonGenerator.forBlock["led_all_on"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const color = block.getFieldValue("color");
  return `Rob.KULBOT_RGB_ALL_ON(${color})\n`;
};

python.pythonGenerator.forBlock["led_all_off"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  return `Rob.KULBOT_RGB_ALL_OFF()\n`;
};

python.pythonGenerator.forBlock["led_button_on"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const color = block.getFieldValue("color");
  return `Rob.KULBOT_SET_BUTTON_LED(${port},${color})\n`;
};

python.pythonGenerator.forBlock["led_IR_on"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const led = block.getFieldValue("IR_Led");
  const color = block.getFieldValue("color");
  return `Rob.KULBOT_SET_IR_SENSOR_LED(${port},${led},${color})\n`;
};
//-----------------sensor-------------------
python.pythonGenerator.forBlock["init_sensor"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const SENSOR = block.getFieldValue("SENSOR");
  return `Rob.KULBOT_${SENSOR}_INIT(${port})\n`;
};
// Ultrasonic
python.pythonGenerator.forBlock["ultrasonic"] = function (block) {
  const port = block.getFieldValue("Ultrasonic");
  return `Rob.KULBOT_ULTRASONIC_GET(${port})`;
};

// Line Sensor
python.pythonGenerator.forBlock["line_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  const line = block.getFieldValue("line");
  return `Rob.KULBOT_LINE_SENSOR_GET(${port}, ${line})`;
};

// IR Sensor
python.pythonGenerator.forBlock["ir_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_IR_SENSOR_GET(${port})`;
};

// Touch Sensor
python.pythonGenerator.forBlock["touch_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_TOUCH_SENSOR_GET(${port})`;
};

// Temp/Hum Sensor
python.pythonGenerator.forBlock["temp_sensor"] = function (block) {
  const type = block.getFieldValue("type");
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_DHT_SENSOR_GET(${port}, ${type})`;
};

// Soil Humidity Sensor
python.pythonGenerator.forBlock["soil_hum_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_SOIL_HUM_SENSOR_GET(${port})`;
};

// Gas Sensor
python.pythonGenerator.forBlock["gas_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_GAS_SENSOR_GET(${port})`;
};

// Gryro Sensor
python.pythonGenerator.forBlock["gryro_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  const data = block.getFieldValue("data");
  return `Rob.KULBOT_GRYRO_SENSOR_GET(${port}, ${data})`;
};

// Color Sensor
python.pythonGenerator.forBlock["color_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  const color = block.getFieldValue("color");
  return `Rob.KULBOT_COLOR_SENSOR_GET(${port}, "${color}")`;
};

// Lux Sensor
python.pythonGenerator.forBlock["lux_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_LUX_SENSOR_GET(${port})`;
};

// Light Sensor
python.pythonGenerator.forBlock["light_sensor"] = function (block) {
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_LIGHT_SENSOR_GET(${port})`;
};
//---------modules----------
python.pythonGenerator.forBlock["init_module"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const module = block.getFieldValue("MODULE");
  return `Rob.KULBOT_${module}_INIT(${port})\n`;
};
// Traffic Light
python.pythonGenerator.forBlock["traffic_light"] = function (block) {
  const port = block.getFieldValue("port");
  const color = block.getFieldValue("color");
  const status = block.getFieldValue("Status");
  return `Rob.KULBOT_TRAFFIC_LIGHT_SET(${port}, ${color}, ${status})\n`;
};

// Joystick
python.pythonGenerator.forBlock["joystick"] = function (block) {
  const port = block.getFieldValue("port");
  const type = block.getFieldValue("type");
  return `Rob.KULBOT_JOYSTICK_GET(${port}, ${type})`;
};

// Volume
python.pythonGenerator.forBlock["volume"] = function (block) {
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_VOLUME_GET(${port})`;
};

// Get Button Led
python.pythonGenerator.forBlock["get_button"] = function (block) {
  const port = block.getFieldValue("port");
  const button = block.getFieldValue("button");
  return `Rob.KULBOT_BUTTON_LED_GET(${port}, ${button})`;
};

// Init Sensor
python.pythonGenerator.forBlock["init_sensor"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const SENSOR = block.getFieldValue("SENSOR");
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_${SENSOR}_INIT(${port})\n`;
};

//------------------lcd-------------------
python.pythonGenerator.forBlock["lcd_init"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_LCD_INIT(${port})\n`;
};
// lcd_number
python.pythonGenerator.forBlock["lcd_number"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const column =
    python.pythonGenerator.valueToCode(
      block,
      "column",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const cell =
    python.pythonGenerator.valueToCode(
      block,
      "cell",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number =
    python.pythonGenerator.valueToCode(
      block,
      "number",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return `Rob.KULBOT_LCD_PRINT_NUMBER(${port}, ${column}, ${cell}, ${number})\n`;
};
// lcd_string
python.pythonGenerator.forBlock["lcd_string"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const column =
    python.pythonGenerator.valueToCode(
      block,
      "column",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const cell =
    python.pythonGenerator.valueToCode(
      block,
      "cell",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const string =
    python.pythonGenerator.valueToCode(
      block,
      "string",
      python.pythonGenerator.ORDER_ATOMIC
    ) || '""';
  return `Rob.KULBOT_LCD_PRINT_STRING(${port}, ${column}, ${cell}, ${string})\n`;
};

// lcd_clear
python.pythonGenerator.forBlock["lcd_clear"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_LCD_CLEAR(${port})\n`;
};
// Motions
python.pythonGenerator.forBlock["motor_init"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  return `Rob.KULBOT_MOTORENCODER_INIT()\n`;
};
// motor
python.pythonGenerator.forBlock["motor"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const side = block.getFieldValue("side");
  const number =
    python.pythonGenerator.valueToCode(
      block,
      "number",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return `Rob.KULBOT_MOTORENCODER_RUN1(${port}, ${number}, ${side})\n`;
};

// servo
python.pythonGenerator.forBlock["servo"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const number =
    python.pythonGenerator.valueToCode(
      block,
      "number",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const side = block.getFieldValue("side");
  return `Rob.KULBOT_SERVO(${port}, ${number})\n`;
};

// encoder
python.pythonGenerator.forBlock["encoder"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const number =
    python.pythonGenerator.valueToCode(
      block,
      "number",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return `Rob.KULBOT_ENCODER_SET_POSI(${port}, ${number})\n`;
};

// tuning_encoder
python.pythonGenerator.forBlock["tuning_encoder"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  const number =
    python.pythonGenerator.valueToCode(
      block,
      "number",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number1 =
    python.pythonGenerator.valueToCode(
      block,
      "number1",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number2 =
    python.pythonGenerator.valueToCode(
      block,
      "number2",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return `Rob.KULBOT_ENCODER_SET_TUNING(${port}, ${number}, ${number1}, ${number2})\n`;
};

// posi_encoder
python.pythonGenerator.forBlock["posi_encoder"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  return `Rob.KULBOT_ENCODER_GET_POSI(${port})\n`;
};
// serial

// print_serial
python.pythonGenerator.forBlock["print_serial"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const text =
    python.pythonGenerator.valueToCode(
      block,
      "TEXT",
      python.pythonGenerator.ORDER_ATOMIC
    ) || '""';
  const type = block.getFieldValue("type");
  if (type === "wrap" || type === "0") {
    return `Serial.println(${text})\n`;
  } else {
    return `Serial.print(${text})\n`;
  }
};

// data_length_serial
python.pythonGenerator.forBlock["data_length_serial"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  return "Serial.available()\n";
};

// read_data_serial
python.pythonGenerator.forBlock["read_data_serial"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  return "Serial.read()\n";
};
// DATA

// data_map
python.pythonGenerator.forBlock["data_map"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const number1 =
    python.pythonGenerator.valueToCode(
      block,
      "number1",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number2 =
    python.pythonGenerator.valueToCode(
      block,
      "number2",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number3 =
    python.pythonGenerator.valueToCode(
      block,
      "number3",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number4 =
    python.pythonGenerator.valueToCode(
      block,
      "number4",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number5 =
    python.pythonGenerator.valueToCode(
      block,
      "number5",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return [
    `map(${number1}, ${number2}, ${number3}, ${number4}, ${number5})`,
    python.pythonGenerator.ORDER_FUNCTION_CALL,
  ];
};

// data_constrain
python.pythonGenerator.forBlock["data_constrain"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const number1 =
    python.pythonGenerator.valueToCode(
      block,
      "number1",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number2 =
    python.pythonGenerator.valueToCode(
      block,
      "number2",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const number3 =
    python.pythonGenerator.valueToCode(
      block,
      "number3",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return [
    ` constrain(${number1}, ${number2}, ${number3})`,
    python.pythonGenerator.ORDER_FUNCTION_CALL,
  ];
};

// data_convert_number
python.pythonGenerator.forBlock["data_convert_number"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const number1 =
    python.pythonGenerator.valueToCode(
      block,
      "number1",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  const type = block.getFieldValue("type");
  return [
    ` String("${number1}")${type}`,
    python.pythonGenerator.ORDER_FUNCTION_CALL,
  ];
};

// data_convert_number_character
python.pythonGenerator.forBlock["data_convert_number_character"] = function (
  block
) {
  if (!checkConnectedToStart(block)) return "";
  const number1 =
    python.pythonGenerator.valueToCode(
      block,
      "number1",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "97";
  return [
    ` String(char(${number1}))`,
    python.pythonGenerator.ORDER_FUNCTION_CALL,
  ];
};

// data_convert_character_number
python.pythonGenerator.forBlock["data_convert_character_number"] = function (
  block
) {
  if (!checkConnectedToStart(block)) return "";
  const text =
    python.pythonGenerator.valueToCode(
      block,
      "TEXT",
      python.pythonGenerator.ORDER_ATOMIC
    ) || '""';
  return [
    `toascii(String("${text}")[0])`,
    python.pythonGenerator.ORDER_FUNCTION_CALL,
  ];
};
// Teachable Machine

// teachable_initialize
python.pythonGenerator.forBlock["teachable_initialize"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const port = block.getFieldValue("port");
  return `Rob.INIT_CAMERA_AI(${port})\n`;
};

// teachable_update
python.pythonGenerator.forBlock["teachable_update"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  return "Rob.UPDATE_DETECT()\n";
};

// teachable_detect
python.pythonGenerator.forBlock["teachable_detect"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  const label = block.getFieldValue("label") || "";
  const accuracy =
    python.pythonGenerator.valueToCode(
      block,
      "accuracy",
      python.pythonGenerator.ORDER_ATOMIC
    ) || "0";
  return [
    `Rob.DETECT("${label}", ${accuracy})`,
    python.pythonGenerator.ORDER_FUNCTION_CALL,
  ];
};

// teachable_read
python.pythonGenerator.forBlock["teachable_read"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  return "Rob.READ_DETECT_RESULT()\n";
};

// teachable_score
python.pythonGenerator.forBlock["teachable_score"] = function (block) {
  if (!checkConnectedToStart(block)) return "";
  return "Rob.READ_DETECT_SCORE()\n";
};
