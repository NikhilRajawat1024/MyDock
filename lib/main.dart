import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isHovered) {
              return AnimatedScale(
                scale: isHovered ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(icon, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [IconData] items.
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  /// Initial items to put in this [Dock].
  final List<IconData> items;

  /// Builder to build the provided [IconData].
  final Widget Function(IconData, bool isHovered) builder;

  @override
  State<Dock> createState() => _DockState();
}

/// State of the [Dock] used to manipulate the items.
class _DockState extends State<Dock> {
  /// Items being manipulated.
  late final List<IconData> _items = widget.items.toList();

  /// Index currently being hovered.
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final icon = _items[index];
          return DragTarget<IconData>(
            onWillAccept: (data) {
              setState(() => _hoveredIndex = index);
              return true;
            },
            onLeave: (_) => setState(() => _hoveredIndex = null),
            onAcceptWithDetails: (details) {
              setState(() {
                final oldIndex = _items.indexOf(details.data); // Use details.data
                _items.removeAt(oldIndex);
                _items.insert(index, details.data);
                _hoveredIndex = null;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return LongPressDraggable<IconData>(
                data: _items[index],
                feedback: Material(
                  color: Colors.transparent,
                  child: widget.builder(_items[index], true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: widget.builder(_items[index], false),
                ),
                onDragEnd: (_) => setState(() => _hoveredIndex = null),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: widget.builder(_items[index], _hoveredIndex == index),
                ),
              );
            },
          );

        }),
      ),
    );
  }
}
