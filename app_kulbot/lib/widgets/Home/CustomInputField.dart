import 'package:flutter/material.dart';

class TextInputField<T extends Object> {
  final TextEditingController controller;
  final String label;
  final String key;
  final FocusNode focusNode;
  final int minValue;
  final int maxValue;
  final int maxlength;
  final int minlength;
  final String? error;

  TextInputField({
    required this.label,
    required this.controller,
    String? key,
    FocusNode? focusNode,
    int? minValue,
    int? maxValue,
    int? maxlength,
    int? minlength,
  }) : key = key ?? label,
       focusNode = focusNode ?? FocusNode(),
       minValue = minValue ?? 0,
       maxValue = maxValue ?? 1000000,
       maxlength = maxlength ?? 100,
       minlength = minlength ?? 1,
       error =
           T != int && T != double && T != String
               ? "TextInputField<$T> chỉ hỗ trợ int, double hoặc String."
               : null;
}

class DropdownInputField<T extends Object> {
  final String label;
  final String key;
  final List<T> items;
  final List<String> items_name;
  final T selectedValue;
  final String? error;

  DropdownInputField({
    required this.label,
    String? key,
    List<String>? items_name,
    required this.items,
    required this.selectedValue,
  }) : key = key ?? label,
       items_name =
           (items_name != null && items_name.length == items.length)
               ? items_name
               : items.map((e) => e.toString()).toList(),
       error =
           (T != int && T != double && T != String)
               ? "DropdownInputField<$T> chỉ hỗ trợ int, double hoặc String."
               : null;
}

class CustomDialog extends StatefulWidget {
  final String title;
  final List<TextInputField> controllers;
  final List<DropdownInputField> dropdowns;
  final void Function(Map<String, dynamic>)? onOk;
  final VoidCallback? onDelete;
  final void Function() onCancel;
  final Color? okColor;
  final Color? cancelColor;
  final String errorNotData;

  const CustomDialog({
    super.key,
    required this.title,
    List<TextInputField>? controllers,
    List<DropdownInputField>? dropdowns,
    this.onOk,
    this.onDelete,
    required this.onCancel,
    this.okColor,
    this.cancelColor,
    String? errorNotData,
  }) : controllers = controllers ?? const [],
       dropdowns = dropdowns ?? const [],
       errorNotData =
           errorNotData ??
           'Không có dữ liệu để hiển thị. Vui lòng kiểm tra kết bluetooth!';

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog>
    with WidgetsBindingObserver {
  final TextEditingController _overlayController = TextEditingController();
  final FocusNode _overlayFocusNode = FocusNode();
  bool _showOverlayInput = false;
  bool _focus_input_macdinh = false;
  bool _focus_input_khac = true;
  FocusNode? _lastFocusedNode;
  String _labelForInputMacDinh = "";
  late Map<String, dynamic> selected_dropmenu;
  int _total_input = 0;
  Map<String, String?> _inputErrors = {};
  bool _input_macdinh_type_number = false;
  int _maxlength_input_macdinh = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    selected_dropmenu = {};
    if (widget.dropdowns.isNotEmpty) {
      for (var i = 0; i < widget.dropdowns.length; i++) {
        if (widget.dropdowns[i].items.isNotEmpty) {
          selected_dropmenu[widget.dropdowns[i].key] =
              widget.dropdowns[i].selectedValue;
        }
        _total_input++;
      }
    }
    if (widget.controllers.isNotEmpty) {
      _overlayFocusNode.addListener(() {
        if (_overlayFocusNode.hasFocus) {
          setState(() {
            _showOverlayInput = true;
            _focus_input_macdinh = true;
            _focus_input_khac = false;
          });
        } else if (!_overlayFocusNode.hasFocus && !_focus_input_khac) {
          setState(() {
            _showOverlayInput = false;
            _focus_input_khac = true;
          });
        }
      });

      _overlayController.addListener(() {
        if (_focus_input_macdinh) {
          final focusedInput = widget.controllers.firstWhere(
            (e) => e.focusNode == _lastFocusedNode,
            orElse: () => widget.controllers.first,
          );

          if (focusedInput.controller.text != _overlayController.text) {
            focusedInput.controller.text = _overlayController.text;
          }
        }
      });

      for (final input in widget.controllers) {
        input.focusNode.addListener(() {
          if (input.focusNode.hasFocus) {
            setState(() {
              _overlayController.text = input.controller.text;
              _labelForInputMacDinh = input.label;
              _lastFocusedNode = input.focusNode;
              _input_macdinh_type_number =
                  input is TextInputField<int> ||
                  input is TextInputField<double>;
              _maxlength_input_macdinh = input.maxlength;
              _showOverlayInput = true;
              _focus_input_macdinh = false;
              _focus_input_khac = true;
            });
          } else if (!input.focusNode.hasFocus && !_focus_input_macdinh) {
            setState(() {
              _showOverlayInput = false;
              _focus_input_khac = true;
            });
          }
        });

        input.controller.addListener(() {
          if (_lastFocusedNode == input.focusNode && !_focus_input_macdinh) {
            _overlayController.text = input.controller.text;
          }
        });
        _total_input++;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayController.dispose();
    _overlayFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final isKeyboardOpen = WidgetsBinding.instance.window.viewInsets.bottom > 0;
    if (!isKeyboardOpen) {
      setState(() {
        _showOverlayInput = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double dialogHeight = (_total_input * 95.0 +
            (widget.onDelete != null ? 30 : 0))
        .clamp(120.0, size.height - 60.0 > 300.0 ? 300.0 : size.height - 60.0);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.transparent,
        child: Stack(
          children: [
            // Nội dung chính
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 120,
                  maxHeight:
                      size.height - 60.0 > 250.0 ? 250.0 : size.height - 60.0,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.6,
                    minWidth: size.width * 0.4,
                  ),
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...widget.controllers.map((input) {
                          final hasInputError =
                              _inputErrors[input.key] != null &&
                              _inputErrors[input.key]!.isNotEmpty;
                          final hasCustomError =
                              input.error != null && input.error!.isNotEmpty;

                          String? errorText;
                          if (hasInputError && hasCustomError) {
                            errorText =
                                "${_inputErrors[input.key]}\n${input.error}";
                          } else if (hasInputError) {
                            errorText = _inputErrors[input.key];
                          } else if (hasCustomError) {
                            errorText = input.error;
                          } else {
                            errorText = null;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: input.controller,
                                  focusNode: input.focusNode,
                                  keyboardType:
                                      input is TextInputField<double> ||
                                              input is TextInputField<int>
                                          ? TextInputType.number
                                          : TextInputType.text,
                                  maxLength: input.maxlength,
                                  decoration: InputDecoration(
                                    labelText: input.label,
                                    border: const OutlineInputBorder(),
                                    errorText: errorText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        ...widget.dropdowns.map((dropdown) {
                          final hasItems = dropdown.items.isNotEmpty;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<Object>(
                                  value:
                                      hasItems ? dropdown.selectedValue : null,
                                  decoration: InputDecoration(
                                    labelText: dropdown.label,
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged:
                                      hasItems
                                          ? (value) {
                                            if (value != null) {
                                              selected_dropmenu[dropdown.key] =
                                                  value;
                                            }
                                          }
                                          : null, // Không cho chọn nếu rỗng
                                  items:
                                      hasItems
                                          ? List.generate(
                                            dropdown.items.length,
                                            (index) => DropdownMenuItem<Object>(
                                              value: dropdown.items[index],
                                              child: Text(
                                                dropdown.items_name.length ==
                                                        dropdown.items.length
                                                    ? dropdown.items_name[index]
                                                    : dropdown.items[index]
                                                        .toString(),
                                              ),
                                            ),
                                          )
                                          : [],
                                ),

                                // ✅ Hiển thị lỗi nếu không có dữ liệu hoặc có lỗi từ dev
                                if (!hasItems || dropdown.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      dropdown.error ?? widget.errorNotData,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),

                        if (widget.onDelete != null)
                          Container(
                            width: double.infinity,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text("Xác nhận xoá"),
                                          content: const Text(
                                            "Bạn có chắc muốn xoá mục này không?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(ctx).pop(),
                                              child: const Text("Huỷ"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                widget.onDelete?.call();
                                              },
                                              child: const Text(
                                                "Xoá",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                child: const Text("Delete"),
                              ),
                            ),
                          ),
                        const SizedBox(height: 45),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom:
                  ((size.height - dialogHeight) / 2 -
                      (_total_input > 2 ? 0 : 38.0)),
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.6,
                    minWidth: size.width * 0.4,
                  ),
                  child: Container(
                    height: 50.0,
                    constraints: BoxConstraints(
                      maxWidth: size.width * 0.6,
                      minWidth: size.width * 0.4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: widget.cancelColor ?? Colors.grey,
                          ),
                          onPressed: widget.onCancel,
                          child: const Text("Close"),
                        ),
                        if (widget.onOk != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor:
                                  widget.okColor ?? Colors.blueAccent,
                            ),
                            onPressed: () {
                              bool hasError = false;
                              _inputErrors.clear();
                              Map<String, dynamic> result = {};

                              for (final input in widget.controllers) {
                                final text = input.controller.text;

                                if (input is TextInputField<int>) {
                                  final number = int.tryParse(text);
                                  if (number == null) {
                                    _inputErrors[input.key] =
                                        "Phải là số nguyên";
                                    hasError = true;
                                    continue;
                                  } else if (number < input.minValue ||
                                      number > input.maxValue) {
                                    _inputErrors[input.key] =
                                        "Giá trị từ ${input.minValue} đến ${input.maxValue}";
                                    hasError = true;
                                    continue;
                                  }
                                  result[input.key] = number;
                                } else if (input is TextInputField<double>) {
                                  final number = double.tryParse(text);
                                  if (number == null) {
                                    _inputErrors[input.key] = "Phải là số thực";
                                    hasError = true;
                                    continue;
                                  } else if (number < input.minValue ||
                                      number > input.maxValue) {
                                    _inputErrors[input.key] =
                                        "Giá trị từ ${input.minValue} đến ${input.maxValue}";
                                    hasError = true;
                                    continue;
                                  }
                                  result[input.key] = number;
                                } else if (input is TextInputField<String>) {
                                  if (text.length < input.minlength ||
                                      text.length > input.maxlength) {
                                    _inputErrors[input.key] =
                                        "${input.label} phải có độ dài từ ${input.minlength} đến ${input.maxlength} ký tự.";
                                    hasError = true;
                                    continue;
                                  }
                                  result[input.key] = text;
                                } else {
                                  _inputErrors[input.key] =
                                      "Không xác định kiểu dữ liệu";
                                  hasError = true;
                                }
                              }

                              if (!hasError) {
                                result.addAll(selected_dropmenu);
                                widget.onOk!(result);
                              } else {
                                setState(() {});
                              }
                            },
                            child: const Text("OK"),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Overlay input nằm trên cùng
            if (widget.controllers.isNotEmpty && _showOverlayInput)
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.white,
                  elevation: 8,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _overlayController,
                          focusNode: _overlayFocusNode,
                          autofocus: true,
                          maxLength: _maxlength_input_macdinh,
                          keyboardType:
                              _input_macdinh_type_number
                                  ? TextInputType.number
                                  : null,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(),
                            labelText: _labelForInputMacDinh,
                            floatingLabelBehavior:
                                FloatingLabelBehavior.never, // Label không nổi
                            // contentPadding: EdgeInsets.only(
                            //   bottom: 20,
                            //   left: 12,
                            //   right: 12,
                            // ), // đẩy label thấp xuống
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showOverlayInput = false;
                                  _focus_input_macdinh = false;
                                  _focus_input_khac = true;
                                });
                                FocusScope.of(context).unfocus();
                              },
                              child: const Icon(Icons.keyboard_hide),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
