import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../layout/admin_scaffold.dart';
import '../widgets/stat_card.dart';
import '../../../../core/router/route_names.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';

/// Admin Dashboard Page
/// Main dashboard showing key statistics
/// Theme-aware and responsive
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  int _totalCitizens = 0;
  int _totalFamilies = 0;
  int _pendingApplications = 0;
  int _approvedApplications = 0;
  int _rejectedApplications = 0;
  int _totalCertificates = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationService = const ApplicationService();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Authentication token missing';
          _isLoading = false;
        });
        return;
      }

      final statistics = await applicationService.getAdminStatistics(token: token);

      if (mounted) {
        setState(() {
          _totalCitizens = statistics['totalCitizens'] as int? ?? 0;
          _totalFamilies = statistics['totalFamilies'] as int? ?? 0;
          _pendingApplications = statistics['pendingApplications'] as int? ?? 0;
          _approvedApplications = statistics['approvedApplications'] as int? ?? 0;
          _rejectedApplications = statistics['rejectedApplications'] as int? ?? 0;
          _totalCertificates = statistics['totalCertificates'] as int? ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load statistics: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AdminScaffold(
      title: 'Dashboard',
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
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

              // Application Status Counters
              Text(
                'Application Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              _isLoading ? '...' : _formatCount(_pendingApplications),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pending',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.orange.shade700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              _isLoading ? '...' : _formatCount(_approvedApplications),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Approved',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green.shade700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              _isLoading ? '...' : _formatCount(_rejectedApplications),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rejected',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red.shade700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Statistics Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadStatistics,
                      tooltip: 'Refresh statistics',
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (_error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadStatistics,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
                      count: _isLoading ? '...' : _formatCount(_totalCitizens),
                      iconGradient: [
                        Colors.blue,
                        Colors.blue.shade300,
                      ],
                      onTap: () {
                        context.go('/admin/citizens');
                      },
                    ),
                    StatCard(
                      icon: Icons.family_restroom,
                      title: 'Families',
                      count: _isLoading ? '...' : _formatCount(_totalFamilies),
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
                      title: 'Pending Applications',
                      count: _isLoading ? '...' : _formatCount(_pendingApplications),
                      iconGradient: [
                        Colors.orange,
                        Colors.orange.shade300,
                      ],
                      onTap: () {
                        context.goNamed(Routes.adminApplications);
                      },
                    ),
                    StatCard(
                      icon: Icons.description,
                      title: 'Certificates Issued',
                      count: _isLoading ? '...' : _formatCount(_totalCertificates),
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
      ),
    );
  }
}
