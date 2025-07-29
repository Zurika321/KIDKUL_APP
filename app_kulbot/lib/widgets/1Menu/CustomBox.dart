import 'package:flutter/material.dart';

class CustomBox extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showMenuIcon;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final Size size;
  final Color color;

  const CustomBox({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showMenuIcon = false,
    this.onRename,
    this.onDelete,
    required this.size,
    required this.color,
  });

  @override
  State<CustomBox> createState() => _CustomBoxState();
}

class _CustomBoxState extends State<CustomBox>
    with SingleTickerProviderStateMixin {
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final RenderBox box =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeMenu,
          child: Stack(
            children: [
              Positioned(
                top: position.dy - 8,
                left: position.dx - widget.size.width + 28,
                child: Material(
                  color: const Color.fromARGB(0, 0, 0, 0),
                  child: Container(
                    width: widget.size.width,
                    height: widget.size.height,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        189,
                        158,
                        158,
                        158,
                      ), // nền đậm dễ nhìn
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 8,
                          color: Color.fromARGB(90, 0, 0, 0),
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: const Color.fromARGB(0, 0, 0, 0),
                          child: InkWell(
                            onTap: () {
                              _closeMenu();
                              widget.onRename?.call();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              child: Text(
                                'Rename',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          color: Color.fromARGB(77, 255, 255, 255),
                          height: 1,
                        ),
                        Material(
                          color: const Color.fromARGB(0, 0, 0, 0),
                          child: InkWell(
                            onTap: () {
                              _closeMenu();
                              widget.onDelete?.call();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            width: widget.size.width,
            height: widget.size.height,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(37, 0, 0, 0),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 50,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                if (widget.title.isNotEmpty) const SizedBox(height: 8),
                if (widget.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.showMenuIcon)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                key: _menuKey,
                onTap: _toggleMenu,
                child: const Icon(Icons.more_vert, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  void _closeMenu() async {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
