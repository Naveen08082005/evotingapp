import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/candidate_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../widgets/candidate/candidate_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';

class CandidateManagementScreen extends StatelessWidget {
  const CandidateManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CandidateController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addEditCandidate),
        icon: const Icon(Icons.add),
        label: const Text('Add Candidate'),
      ),
      body: Column(
        children: [
          // Search + Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.search,
                    decoration: InputDecoration(
                      hintText: 'Search candidates...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _FilterDropdown(controller: controller),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Filter chips
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['all', 'pending', 'approved', 'rejected']
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f == 'all' ? 'All' : f.capitalize!),
                              selected: controller.statusFilter.value == f,
                              onSelected: (_) => controller.setFilter(f),
                              selectedColor: AppColors.primary.withValues(alpha: 0.15),
                              checkmarkColor: AppColors.primary,
                            ),
                          ))
                      .toList(),
                ),
              )),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Loading candidates...');
              }
              if (controller.filteredCandidates.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.person_search_rounded,
                  title: AppStrings.noCandidatesFound,
                  subtitle: 'Add a new candidate using the button below.',
                  actionLabel: 'Add Candidate',
                  onAction: () => Get.toNamed(AppRoutes.addEditCandidate),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: controller.filteredCandidates.length,
                  itemBuilder: (_, i) {
                    final c = controller.filteredCandidates[i];
                    return Dismissible(
                      key: ValueKey(c.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      confirmDismiss: (_) async => await _confirmDelete(context, c.name),
                      onDismissed: (_) => controller.deleteCandidate(c.id),
                      child: Row(
                        children: [
                          Expanded(
                            child: CandidateCard(
                              candidate: c,
                              onTap: () => Get.toNamed(
                                AppRoutes.addEditCandidate,
                                arguments: c,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Get.toNamed(AppRoutes.addEditCandidate, arguments: c);
                              } else if (value == 'delete') {
                                final confirm = await _confirmDelete(context, c.name);
                                if (confirm == true) {
                                  controller.deleteCandidate(c.id);
                                }
                              } else {
                                await controller.updateStatus(c.id, value);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('✏️ Edit Candidate'),
                              ),
                              if (c.status != 'approved')
                                const PopupMenuItem(
                                  value: 'approved',
                                  child: Text('✅ Approve Candidate'),
                                ),
                              if (c.status != 'rejected')
                                const PopupMenuItem(
                                  value: 'rejected',
                                  child: Text('❌ Reject Candidate'),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  '🗑️ Delete Candidate',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Candidate'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final CandidateController controller;
  const _FilterDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list_rounded),
          onSelected: controller.setFilter,
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'all', child: Text('All')),
            const PopupMenuItem(value: 'pending', child: Text('Pending')),
            const PopupMenuItem(value: 'approved', child: Text('Approved')),
            const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
          ],
        );
  }
}
