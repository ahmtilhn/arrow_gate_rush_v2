import 'arrow_color.dart';

class GateSlot {
  const GateSlot({
    required this.id,
    required this.color,
    this.isOpen = true,
    this.isLocked = false,
  });

  final String id;
  final ArrowColor color;
  final bool isOpen;
  final bool isLocked;

  GateSlot copyWith({bool? isOpen, bool? isLocked}) {
    return GateSlot(
      id: id,
      color: color,
      isOpen: isOpen ?? this.isOpen,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GateSlot &&
        other.id == id &&
        other.color == color &&
        other.isOpen == isOpen &&
        other.isLocked == isLocked;
  }

  @override
  int get hashCode => Object.hash(id, color, isOpen, isLocked);
}
