import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

/// Certificates Page
/// Displays all issued certificates with view and download options
class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  final List<Map<String, dynamic>> _certificates = const [
    {
      'id': '1',
      'citizenName': 'John Doe',
      'type': 'Birth Certificate',
      'dateIssued': '2024-01-10',
      'status': 'Active',
    },
    {
      'id': '2',
      'citizenName': 'Jane Smith',
      'type': 'Marriage Certificate',
      'dateIssued': '2024-01-05',
      'status': 'Active',
    },
    {
      'id': '3',
      'citizenName': 'Alice Johnson',
      'type': 'Death Certificate',
      'dateIssued': '2023-12-20',
      'status': 'Active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
      ),
      body: _certificates.isEmpty
          ? Center(
              child: Text(
                'No certificates found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final cert = _certificates[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isDark ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: kPrimaryColor,
                      ),
                    ),
                    title: Text(
                      cert['citizenName'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(cert['type']),
                        Text(
                          'Issued: ${cert['dateIssued']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kSuccessColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cert['status'],
                            style: const TextStyle(
                              color: kSuccessColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Text('View Certificate'),
                            ),
                            const PopupMenuItem(
                              value: 'download',
                              child: Text('Download'),
                            ),
                          ],
                          onSelected: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$value action for ${cert['citizenName']}\'s certificate'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


