import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/circular_provider.dart';
import '../../data/models/circular_models.dart';

class CircularDetailScreen extends ConsumerStatefulWidget {
  final CircularModel circular;
  const CircularDetailScreen({super.key, required this.circular});

  @override
  ConsumerState<CircularDetailScreen> createState() => _CircularDetailScreenState();
}

class _CircularDetailScreenState extends ConsumerState<CircularDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.circular.read) {
        ref.read(circularProvider.notifier).markRead(widget.circular.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.circular;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(c.title, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _badge(c.targetType),
            const SizedBox(width: 8),
            Text('By ${c.publishedByName}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ]),
          const SizedBox(height: 16),
          Text(c.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(c.content, style: const TextStyle(fontSize: 16, height: 1.6)),
          if (c.targetClassRoomName != null) ...[
            const SizedBox(height: 16),
            Text('Class: ${c.targetClassRoomName}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
          if (c.targetSectionName != null) ...[
            const SizedBox(height: 4),
            Text('Section: ${c.targetSectionName}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ]),
      ),
    );
  }

  Widget _badge(String type) {
    final color = type == 'ALL' ? Colors.green : type == 'CLASS' ? Colors.orange : Colors.purple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color)),
      child: Text(type, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
