import 'package:flutter/material.dart';
import '../layout/admin_scaffold.dart';
import '../widgets/stat_card.dart';

/// Admin Dashboard Page
/// Main dashboard showing key statistics
/// Theme-aware and responsive
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AdminScaffold(
      title: 'Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Here\'s what\'s happening today',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Grid
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.35,
              children: [
                StatCard(
                  icon: Icons.people,
                  title: 'Total Citizens',
                  count: '1,234',
                  iconGradient: [
                    Colors.blue,
                    Colors.blue.shade300,
                  ],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View Citizens')),
                    );
                  },
                ),
                StatCard(
                  icon: Icons.family_restroom,
                  title: 'Families',
                  count: '456',
                  iconGradient: [
                    Colors.purple,
                    Colors.purple.shade300,
                  ],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View Families')),
                    );
                  },
                ),
                StatCard(
                  icon: Icons.pending_actions,
                  title: 'Pending Requests',
                  count: '42',
                  iconGradient: [
                    Colors.orange,
                    Colors.orange.shade300,
                  ],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View Pending Requests')),
                    );
                  },
                ),
                StatCard(
                  icon: Icons.description,
                  title: 'Certificates Issued',
                  count: '892',
                  iconGradient: [
                    Colors.green,
                    Colors.green.shade300,
                  ],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View Certificates')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
