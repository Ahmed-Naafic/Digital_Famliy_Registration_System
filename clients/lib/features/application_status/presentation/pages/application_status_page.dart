import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/application_service.dart';
import '../../../../features/auth/auth_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/application_model.dart';

/// Application Status Page
/// Displays list of submitted applications with their status
/// Theme-aware with Material 3 design
class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final applicationService = Provider.of<ApplicationService>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Application Status'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.goNamed(Routes.dashboard),
          ),
        ),
        body: const Center(
          child: Text('Please log in to view your applications'),
        ),
      );
    }

    final applications = applicationService.getApplicationsForCitizen(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(Routes.dashboard),
        ),
      ),
      body: applications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applications found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                final statusColor = _getStatusColor(app.status);
                final dateFormat = DateFormat('yyyy-MM-dd');

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        app.serviceType.icon,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      app.serviceType.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Submitted: ${dateFormat.format(app.submittedAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                        if (app.status == ApplicationStatus.pending) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Waiting for admin approval',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.orange,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                        if (app.status == ApplicationStatus.rejected &&
                            app.rejectionReason != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Reason: ${app.rejectionReason}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.red),
                          ),
                        ],
                        if (app.status == ApplicationStatus.approved &&
                            app.certificateUrl != null) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _downloadCertificate(
                              context,
                              app.certificateUrl!,
                              app.serviceType.displayName,
                            ),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Download Certificate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(app.status.icon, color: statusColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            app.status.displayName,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _downloadCertificate(
    BuildContext context,
    String certificateUrl,
    String certificateType,
  ) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $certificateType certificate...'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Simulate download
    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$certificateType certificate downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
