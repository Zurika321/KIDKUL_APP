import 'package:flutter/material.dart';

class ListBox extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final Map<String, dynamic> value;

  const ListBox({
    super.key,
    required this.config,
    required this.value,
    this.onSave,
    this.onDelete,
  });

  @override
  State<ListBox> createState() => _ListBoxState();
}

class _ListBoxState extends State<ListBox> with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  double _textWidth = 0;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    width = (widget.config['width'] ?? 150).toDouble();
    height = (widget.config['height'] ?? 35).toDouble();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(_scrollText);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.value["data"]?.toString() ?? "Status bluetooth",
        style: const TextStyle(
          fontSize: 16,
          color: Color.fromARGB(215, 0, 0, 0),
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    _textWidth = textPainter.width;

    if (_textWidth > width - 32) {
      _animationController.repeat(reverse: true);
    }
  }

  void _scrollText() {
    if (_textWidth <= width - 32) return;
    final maxScroll = _textWidth - (width - 32);
    final offset = _animationController.value * maxScroll;
    _scrollController.jumpTo(offset);
  }

  @override
  void didUpdateWidget(covariant ListBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animationController.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 244, 67, 54),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(
          color: const Color.fromARGB(255, 68, 137, 255),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(35, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            left: 0,
            top: 0,
            child: ClipRect(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.value["data"]?.toString() ?? "Status bluetooth",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(215, 0, 0, 0),
                    ),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          if (widget.config["lock"] == false)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    width += details.delta.dx;
                    height += details.delta.dy;
                    width = width.clamp(100, 300);
                    height = height.clamp(35, 80);
                  });
                },
                onPanEnd: (_) {
                  widget.onSave?.call({
                    ...widget.config,
                    'width': width,
                    'height': height,
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(190, 33, 149, 243),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
          if (widget.config["lock"] == false)
            Positioned(
              left: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _showDeleteConfirmDialog,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      255,
                      0,
                      0,
                    ).withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
