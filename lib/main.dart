import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Entrypoint of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: MacDock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

/// Mac-style dock widget.
class MacDock extends StatefulWidget {
  const MacDock({super.key, required this.items});

  final List<IconData> items;

  @override
  State<MacDock> createState() => _MacDockState();
}

class _MacDockState extends State<MacDock> {
  late List<IconData> _items;
  double hoverIndex = -1;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => MouseRegion(
                onEnter: (_) => setState(() => hoverIndex = index.toDouble()),
                onExit: (_) => setState(() => hoverIndex = -1),
                child: Draggable<IconData>(
                  data: _items[index],
                  feedback: Icon(
                    _items[index],
                    size: 50,
                    color: Colors.blue,
                  ),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragEnd: (details) =>
                      _handleReorder(index, details, constraints.maxWidth),
                  child: AnimatedDockItem(
                    icon: _items[index],
                    scale: _calculateScale(index),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _calculateScale(int index) {
    if (hoverIndex == -1) return 1.0;
    final distance = (hoverIndex - index).abs();
    if (distance > 1) return 1.0;
    return 1.5 - (distance * 0.5);
  }

  void _handleReorder(
      int draggedIndex, DraggableDetails details, double maxWidth) {
    setState(() {
      final newIndex = (details.offset.dx / (maxWidth / _items.length))
          .clamp(0, _items.length - 1)
          .toInt();
      final icon = _items.removeAt(draggedIndex);
      _items.insert(newIndex, icon);
    });
  }
}

/// Animated dock item with hover and scaling.
class AnimatedDockItem extends StatelessWidget {
  const AnimatedDockItem({super.key, required this.icon, required this.scale});

  final IconData icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 48 * scale,
      height: 48 * scale,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 24 * scale),
      ),
    );
  }
}
