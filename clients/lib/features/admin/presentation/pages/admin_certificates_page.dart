import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../layout/admin_scaffold.dart';
import '../../../../features/applications/data/application_service.dart';
import '../../../../features/auth/auth_provider.dart';

/// Admin Certificates Management Page
/// Displays all issued certificates with search and management options
class AdminCertificatesPage extends StatefulWidget {
  const AdminCertificatesPage({super.key});

  @override
  State<AdminCertificatesPage> createState() => _AdminCertificatesPageState();
}

class _AdminCertificatesPageState extends State<AdminCertificatesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _certificates = [];
  int _totalCertificates = 0;
  int _currentPage = 1;
  final int _limit = 50;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

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

      final result = await applicationService.getAllCertificates(
        token: token,
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
      );

      if (mounted) {
        setState(() {
          _certificates = (result['certificates'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          _totalCertificates = result['total'] as int? ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load certificates: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value && mounted) {
        _loadCertificates(resetPage: true);
      }
    });
  }

  IconData _getCertificateIcon(String type) {
    switch (type.toLowerCase()) {
      case 'birth':
        return Icons.child_care;
      case 'marriage':
        return Icons.favorite;
      case 'divorce':
        return Icons.heart_broken;
      case 'death':
        return Icons.celebration;
      default:
        return Icons.description;
    }
  }

  String _getCertificateTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'birth':
        return 'Birth Certificate';
      case 'marriage':
        return 'Marriage Certificate';
      case 'divorce':
        return 'Divorce Certificate';
      case 'death':
        return 'Death Certificate';
      default:
        return 'Certificate';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AdminScaffold(
      title: 'Certificates',
      body: RefreshIndicator(
        onRefresh: () => _loadCertificates(),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by certificate number or type...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _loadCertificates(resetPage: true);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Certificates List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
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
                                onPressed: () => _loadCertificates(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _certificates.isEmpty
                          ? Center(
                              child: Text(
                                'No certificates found',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _certificates.length,
                              itemBuilder: (context, index) {
                                final cert = _certificates[index];
                                final dateFormat = DateFormat('yyyy-MM-dd');
                                final issueDate = cert['issueDate'] != null
                                    ? DateTime.parse(cert['issueDate'] as String)
                                    : DateTime.now();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getCertificateIcon(cert['type'] as String? ?? 'birth'),
                                        color: colorScheme.primary,
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      cert['citizenName'] as String? ?? 'Unknown',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          _getCertificateTypeName(
                                            cert['type'] as String? ?? 'birth',
                                          ),
                                        ),
                                        Text(
                                          'Number: ${cert['certificateNumber'] ?? 'N/A'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        Text(
                                          'Issued: ${dateFormat.format(issueDate)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
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
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            cert['status'] as String? ?? 'valid',
                                            style: const TextStyle(
                                              color: Colors.green,
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
                                              child: Row(
                                                children: [
                                                  Icon(Icons.visibility),
                                                  SizedBox(width: 8),
                                                  Text('View Details'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'download',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.download),
                                                  SizedBox(width: 8),
                                                  Text('Download'),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 'view') {
                                              _showCertificateDetails(
                                                context,
                                                cert,
                                              );
                                            } else if (value == 'download') {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Download certificate for ${cert['citizenName']}',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            // Pagination Info
            if (!_isLoading &&
                _error == null &&
                _certificates.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${_certificates.length} of $_totalCertificates certificates',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_totalCertificates > _limit)
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pagination coming soon'),
                            ),
                          );
                        },
                        child: const Text('Load More'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCertificateDetails(
    BuildContext context,
    Map<String, dynamic> certificate,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final issueDate = certificate['issueDate'] != null
        ? DateTime.parse(certificate['issueDate'] as String)
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        title: Text(
          _getCertificateTypeName(
            certificate['type'] as String? ?? 'birth',
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Certificate Number',
                  certificate['certificateNumber']?.toString() ?? 'N/A'),
              _buildDetailRow('Citizen Name',
                  certificate['citizenName']?.toString() ?? 'Unknown'),
              _buildDetailRow('Citizen Email',
                  certificate['citizenEmail']?.toString() ?? 'N/A'),
              _buildDetailRow('Type',
                  _getCertificateTypeName(certificate['type'] as String? ?? 'birth')),
              _buildDetailRow('Issue Date', dateFormat.format(issueDate)),
              _buildDetailRow('Issued By',
                  certificate['issuedBy']?.toString() ?? 'System'),
              _buildDetailRow('Status',
                  (certificate['status'] as String? ?? 'valid').toUpperCase()),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}


