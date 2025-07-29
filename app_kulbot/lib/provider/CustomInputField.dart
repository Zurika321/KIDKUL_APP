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

class CustomBottomSheetContent extends StatefulWidget {
  final String title;
  final List<TextInputField> controllers;
  final List<DropdownInputField> dropdowns;
  final void Function(Map<String, dynamic>)? onOk;
  final VoidCallback? onDelete;
  final void Function() onCancel;
  final Color? okColor;
  final Color? cancelColor;
  final String errorNotData;

  const CustomBottomSheetContent({
    super.key,
    required this.title,
    this.controllers = const [],
    this.dropdowns = const [],
    this.onOk,
    this.onDelete,
    required this.onCancel,
    this.okColor,
    this.cancelColor,
    this.errorNotData =
        'No data to display. Please check bluetooth connection!',
  });

  @override
  State<CustomBottomSheetContent> createState() =>
      _CustomBottomSheetContentState();
}

class _CustomBottomSheetContentState extends State<CustomBottomSheetContent> {
  final Map<String, dynamic> _dropdownValues = {};
  final Map<String, String?> _inputErrors = {};

  @override
  void initState() {
    super.initState();
    for (var drop in widget.dropdowns) {
      if (drop.items.isNotEmpty) {
        _dropdownValues[drop.key] = drop.selectedValue;
      }
    }
  }

  void _handleOk() {
    Map<String, dynamic> result = {};
    bool hasError = false;
    _inputErrors.clear();

    for (final input in widget.controllers) {
      final text = input.controller.text;

      if (input is TextInputField<int>) {
        final value = int.tryParse(text);
        if (value == null) {
          _inputErrors[input.key] = "Must be an integer";
          hasError = true;
        } else if (value < input.minValue || value > input.maxValue) {
          _inputErrors[input.key] =
              "Values from ${input.minValue} to ${input.maxValue}";
          hasError = true;
        } else {
          result[input.key] = value;
        }
      } else if (input is TextInputField<double>) {
        final value = double.tryParse(text);
        if (value == null) {
          _inputErrors[input.key] = "Must be a real number";
          hasError = true;
        } else if (value < input.minValue || value > input.maxValue) {
          _inputErrors[input.key] =
              "Values from ${input.minValue} to ${input.maxValue}";
          hasError = true;
        } else {
          result[input.key] = value;
        }
      } else if (input is TextInputField<String>) {
        if (text.length < input.minlength || text.length > input.maxlength) {
          _inputErrors[input.key] =
              "${input.label} must be between ${input.minlength} and ${input.maxlength} characters";
          hasError = true;
        } else {
          result[input.key] = text;
        }
      }
    }

    if (!hasError) {
      result.addAll(_dropdownValues);
      widget.onOk?.call(result);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.controllers.map((input) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: input.controller,
                    keyboardType:
                        (input is TextInputField<int> ||
                                input is TextInputField<double>)
                            ? TextInputType.number
                            : TextInputType.text,
                    maxLength: input.maxlength,
                    decoration: InputDecoration(
                      labelText: input.label,
                      border: const OutlineInputBorder(),
                      errorText: _inputErrors[input.key],
                    ),
                  ),
                );
              }),
              ...widget.dropdowns.map((dropdown) {
                final hasItems = dropdown.items.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      DropdownButtonFormField<Object>(
                        value: _dropdownValues[dropdown.key],
                        decoration: InputDecoration(
                          labelText: dropdown.label,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _dropdownValues[dropdown.key] = val;
                          });
                        },
                        items:
                            dropdown.items.map((item) {
                              return DropdownMenuItem<Object>(
                                value: item,
                                child: Text(
                                  dropdown.items_name.isNotEmpty
                                      ? dropdown.items_name[dropdown.items
                                          .indexOf(item)]
                                      : item.toString(),
                                ),
                              );
                            }).toList(),
                      ),

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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút Delete nằm bên trái
                  if (widget.onDelete != null)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text(
                                  "Are you sure you want to delete this element?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      widget.onDelete?.call();
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 64,
                    ), // chừa khoảng trống cân đối nếu không có delete
                  // Nút Close và OK nằm bên phải
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.cancelColor ?? Colors.grey,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: widget.onCancel,
                        child: const Text("Close"),
                      ),
                      const SizedBox(width: 12),
                      if (widget.onOk != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                widget.okColor ?? Colors.blueAccent,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _handleOk,
                          child: const Text("OK"),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
