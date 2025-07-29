import 'package:flutter/material.dart';

Future<String?> showRenameDialog(
  BuildContext context,
  TextEditingController controller,
) async {
  return showDialog<String>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text("Rename"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context, newName);
                }
              },
              child: const Text("Rename"),
            ),
          ],
        ),
  );
}

Future<bool> showDeleteDialog(
  BuildContext context,
  String name,
  Future<bool> Function(String name)? delete,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final deleted = await delete?.call(name) ?? false;
                Navigator.pop(context, deleted); // trả về true nếu xóa được
              },
              child: const Text("Delete"),
            ),
          ],
        ),
  );
  return result ?? false;
}
