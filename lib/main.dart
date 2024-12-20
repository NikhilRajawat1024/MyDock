import 'package:flutter/material.dart';

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
          child: MacDock(
            items: const [
              Icons.home,
              Icons.search,
              Icons.settings,
              Icons.camera,
              Icons.message,
            ],
          ),
        ),
      ),
    );
  }
}

class MacDock extends StatefulWidget {
  const MacDock({super.key, required this.items});


  final List<IconData> items;

  @override
  _MacDockState createState() => _MacDockState();
}

class _MacDockState extends State<MacDock> {

  late List<IconData> _items = widget.items.toList();


  int? _hoveredIndex;


  int? _draggedIndex;


  bool _isDraggedOutside = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(12),
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
            onAccept: (data) {
              setState(() {
                if (_draggedIndex != null) {
                  final draggedItem = _items[_draggedIndex!];
                  _items.removeAt(_draggedIndex!);
                  _items.insert(index, draggedItem);
                  _hoveredIndex = null;
                  _draggedIndex = null;
                  _isDraggedOutside = false;
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return LongPressDraggable<IconData>(
                data: icon,
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: _isDraggedOutside ? 0.8 : 1.0, // Shrink only when outside
                    child: _buildDockIcon(icon),
                  ),
                ),
                childWhenDragging: const SizedBox.shrink(),
                onDragStarted: () => setState(() {
                  _draggedIndex = index;
                  _isDraggedOutside = false; // Reset state on drag start
                }),
                onDragUpdate: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final dockBounds = box.localToGlobal(Offset.zero) & box.size;

                  setState(() {
                    // Check if the icon is outside the dock's bounds
                    _isDraggedOutside = !dockBounds.contains(details.globalPosition);
                  });
                },
                onDragEnd: (_) => setState(() {
                  _draggedIndex = null;
                  _hoveredIndex = null;
                  _isDraggedOutside = false; // Reset state on drag end
                }),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: _buildDockIcon(
                    icon,
                    isHovered: _hoveredIndex == index,
                    isDragged: _draggedIndex == index,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }


  Widget _buildDockIcon(IconData icon, {bool isHovered = false, bool isDragged = false}) {
    final scale = isHovered || isDragged ? 1.5 : 1.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Transform.scale(
        scale: scale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.primaries[icon.hashCode % Colors.primaries.length],
            borderRadius: BorderRadius.circular(12),
          ),
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
