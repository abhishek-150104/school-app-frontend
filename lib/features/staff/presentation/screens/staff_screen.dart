import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/staff_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/models/staff_models.dart';

class StaffScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String schoolName;

  const StaffScreen({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(staffListProvider(widget.schoolId).notifier).search(value);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    ref.read(staffListProvider(widget.schoolId).notifier).load();
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListProvider(widget.schoolId));
    final user = ref.watch(authProvider).user;
    final canManage =
        user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search by name or employee ID',
                  border: InputBorder.none,
                ),
              )
            : Text('${widget.schoolName} — Staff'),
        actions: [
          if (_searching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searching = true),
            ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Staff'),
              onPressed: () => context.push(
                '/schools/${widget.schoolId}/staff/create',
                extra: widget.schoolName,
              ),
            )
          : null,
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load staff',
                  style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(staffListProvider(widget.schoolId).notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (staffList) {
          if (staffList.isEmpty) {
            return EmptyState(
              icon: Icons.badge_outlined,
              title: 'No staff members',
              subtitle: canManage
                  ? 'Add the first staff member to get started'
                  : 'No staff members found',
              actionLabel: canManage ? 'Add Staff' : null,
              onAction: canManage
                  ? () => context.push(
                        '/schools/${widget.schoolId}/staff/create',
                        extra: widget.schoolName,
                      )
                  : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(staffListProvider(widget.schoolId).notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: staffList.length,
              itemBuilder: (_, i) => _StaffCard(
                staff: staffList[i],
                schoolId: widget.schoolId,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  final String schoolId;

  const _StaffCard({required this.staff, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = staff.fullName.trim().split(' ').map((w) => w[0]).take(2).join();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: staff.active
              ? theme.colorScheme.secondary.withOpacity(0.15)
              : Colors.grey.shade200,
          child: Text(
            initials.toUpperCase(),
            style: TextStyle(
              color: staff.active
                  ? theme.colorScheme.secondary
                  : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                staff.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!staff.active)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Inactive',
                    style: TextStyle(
                        color: Colors.red.shade700, fontSize: 10)),
              ),
          ],
        ),
        subtitle: Text(
          [
            if (staff.designation != null) staff.designation!,
            'ID: ${staff.employeeId}',
          ].join(' · '),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: staff.subjects.isNotEmpty
            ? Chip(
                label: Text(
                  staff.subjects.first,
                  style: const TextStyle(fontSize: 11),
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )
            : const Icon(Icons.chevron_right),
        onTap: () => context.push(
          '/schools/$schoolId/staff/${staff.id}',
          extra: staff,
        ),
      ),
    );
  }
}
