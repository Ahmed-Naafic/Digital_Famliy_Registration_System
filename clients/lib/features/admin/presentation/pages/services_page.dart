import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/admin_scaffold.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../features/application_status/data/application_model.dart';

/// Services Management Page
/// Displays all available services with statistics and management options
class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  bool _isLoading = false;
  Map<String, dynamic> _serviceStats = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServiceStatistics();
  }

  Future<void> _loadServiceStatistics() async {
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

      // Fetch service-specific statistics from backend
      final stats = await applicationService.getServiceStatistics(token: token);

      if (mounted) {
        setState(() {
          _serviceStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load service statistics: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdminScaffold(
      title: 'Services Management',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadServiceStatistics(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadServiceStatistics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section
                    Text(
                      'Available Services',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage and monitor all registration services',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Services Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                      children: [
                        _buildServiceCard(
                          context,
                          ApplicationType.birth,
                          _serviceStats['birth'] ?? {},
                          colorScheme,
                          isDark,
                        ),
                        _buildServiceCard(
                          context,
                          ApplicationType.marriage,
                          _serviceStats['marriage'] ?? {},
                          colorScheme,
                          isDark,
                        ),
                        _buildServiceCard(
                          context,
                          ApplicationType.divorce,
                          _serviceStats['divorce'] ?? {},
                          colorScheme,
                          isDark,
                        ),
                        _buildServiceCard(
                          context,
                          ApplicationType.death,
                          _serviceStats['death'] ?? {},
                          colorScheme,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Service Details Section
                    Text(
                      'Service Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...ApplicationType.values.map(
                      (serviceType) => _buildServiceDetailCard(
                        context,
                        serviceType,
                        _serviceStats[serviceType.name] ?? {},
                        colorScheme,
                        isDark,
                      ),
                    ),
                    // Add bottom padding to prevent overflow
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getServiceColor(ApplicationType serviceType) {
    switch (serviceType) {
      case ApplicationType.birth:
        return Colors.blue;
      case ApplicationType.marriage:
        return Colors.pink;
      case ApplicationType.divorce:
        return Colors.purple;
      case ApplicationType.death:
        return Colors.grey;
    }
  }

  Widget _buildServiceCard(
    BuildContext context,
    ApplicationType serviceType,
    Map<String, dynamic> stats,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isEnabled = stats['enabled'] as bool? ?? true;
    final total = stats['total'] as int? ?? 0;
    final pending = stats['pending'] as int? ?? 0;
    final serviceColor = _getServiceColor(serviceType);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEnabled
              ? colorScheme.primary.withOpacity(0.2)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showServiceDetails(context, serviceType, stats),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: serviceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      serviceType.icon,
                      color: serviceColor,
                      size: 32,
                    ),
                  ),
                  Switch(
                    value: isEnabled,
                    onChanged: (value) {
                      _toggleService(serviceType, value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                serviceType.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$total total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.pending, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '$pending pending',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDetailCard(
    BuildContext context,
    ApplicationType serviceType,
    Map<String, dynamic> stats,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final total = stats['total'] as int? ?? 0;
    final pending = stats['pending'] as int? ?? 0;
    final approved = stats['approved'] as int? ?? 0;
    final rejected = stats['rejected'] as int? ?? 0;
    final isEnabled = stats['enabled'] as bool? ?? true;
    final serviceColor = _getServiceColor(serviceType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: serviceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(serviceType.icon, color: serviceColor),
        ),
        title: Text(
          serviceType.displayName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isEnabled ? 'Active' : 'Disabled',
          style: TextStyle(
            color: isEnabled ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: isEnabled,
          onChanged: (value) {
            _toggleService(serviceType, value);
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Total Applications',
                        total.toString(),
                        Icons.assignment,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Pending',
                        pending.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Approved',
                        approved.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Rejected',
                        rejected.toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showServiceDetails(context, serviceType, stats),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleService(ApplicationType serviceType, bool enabled) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationService = const ApplicationService();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token missing')),
        );
        return;
      }

      // Update in backend
      await applicationService.updateServiceStatus(
        serviceType: serviceType.name,
        enabled: enabled,
        token: token,
      );

      // Update local state
      if (mounted) {
        setState(() {
          if (_serviceStats[serviceType.name] != null) {
            _serviceStats[serviceType.name]!['enabled'] = enabled;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${serviceType.displayName} ${enabled ? 'enabled' : 'disabled'}',
            ),
            backgroundColor: enabled ? Colors.green : Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showServiceDetails(
    BuildContext context,
    ApplicationType serviceType,
    Map<String, dynamic> stats,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        title: Row(
          children: [
            Icon(serviceType.icon, color: _getServiceColor(serviceType)),
            const SizedBox(width: 12),
            Text(serviceType.displayName),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Status',
                stats['enabled'] == true ? 'Active' : 'Disabled',
              ),
              const Divider(),
              _buildDetailRow('Total Applications', '${stats['total'] ?? 0}'),
              _buildDetailRow('Pending', '${stats['pending'] ?? 0}'),
              _buildDetailRow('Approved', '${stats['approved'] ?? 0}'),
              _buildDetailRow('Rejected', '${stats['rejected'] ?? 0}'),
              const SizedBox(height: 16),
              Text(
                'Service Description',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _getServiceDescription(serviceType),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _getServiceDescription(ApplicationType serviceType) {
    switch (serviceType) {
      case ApplicationType.birth:
        return 'Register new births and issue birth certificates. This service allows citizens to register births and obtain official birth certificates.';
      case ApplicationType.marriage:
        return 'Register marriages and issue marriage certificates. This service enables couples to officially register their marriage and receive marriage certificates.';
      case ApplicationType.divorce:
        return 'Register divorces and issue divorce certificates. This service allows couples to officially register their divorce and obtain divorce certificates.';
      case ApplicationType.death:
        return 'Register deaths and issue death certificates. This service enables families to register deaths and obtain official death certificates.';
    }
  }
}
