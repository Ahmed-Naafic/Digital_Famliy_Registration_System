import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../widgets/admin_stat_card.dart';

/// Reports Page
/// Displays summary reports and export options
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary Reports',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                AdminStatCard(
                  title: 'Total Applications',
                  count: '1,234',
                  icon: Icons.assignment,
                  gradientColors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
                AdminStatCard(
                  title: 'Approved This Month',
                  count: '89',
                  icon: Icons.check_circle,
                  gradientColors: [
                    kSuccessColor,
                    kSuccessColor.withOpacity(0.7),
                  ],
                ),
                AdminStatCard(
                  title: 'Pending Reviews',
                  count: '42',
                  icon: Icons.pending_actions,
                  gradientColors: [
                    Colors.orange,
                    Colors.orange.shade300,
                  ],
                ),
                AdminStatCard(
                  title: 'Rejected',
                  count: '15',
                  icon: Icons.cancel,
                  gradientColors: [
                    kErrorColor,
                    kErrorColor.withOpacity(0.7),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Export Options
            Text(
              'Export Reports',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            _buildExportCard(
              context,
              'Monthly Applications Report',
              'Export all applications from the last month',
              Icons.calendar_month,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting monthly report...')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildExportCard(
              context,
              'Citizens Database',
              'Export complete citizens database',
              Icons.people,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting citizens database...')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildExportCard(
              context,
              'Certificates Report',
              'Export all issued certificates',
              Icons.description,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting certificates report...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

