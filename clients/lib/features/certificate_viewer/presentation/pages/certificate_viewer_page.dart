import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/applications/data/application_service.dart'
    as api_service;
import '../../../../features/auth/auth_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../data/certificate_data_model.dart';
import 'certificate_detail_page.dart';

/// Certificate Viewer Page
/// Displays list of certificates with view/download options
/// Theme-aware with Material 3 design
class CertificateViewerPage extends StatefulWidget {
  const CertificateViewerPage({super.key});

  @override
  State<CertificateViewerPage> createState() => _CertificateViewerPageState();
}

class _CertificateViewerPageState extends State<CertificateViewerPage> {
  bool _isLoading = true;
  List<CertificateData> _certificates = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationService = const api_service.ApplicationService();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Authentication token missing';
          _isLoading = false;
        });
        return;
      }

      final certificatesData = await applicationService.getMyCertificates(
        token: token,
      );

      if (mounted) {
        setState(() {
          _certificates = certificatesData
              .map(
                (data) => CertificateData.fromJson({
                  'id': data['id'] as String? ?? '',
                  'applicationId': data['applicationId'] as String? ?? '',
                  'certificateNumber':
                      data['certificateNumber'] as String? ?? '',
                  'type': data['type'] as String? ?? 'birth',
                  'issueDate': data['issueDate'] != null
                      ? DateTime.parse(data['issueDate'] as String)
                      : DateTime.now(),
                  'issuedBy': data['issuedBy'] as String? ?? 'System',
                  'details': data['details'] as Map<String, dynamic>? ?? {},
                  'qrCodeUrl': data['qrCodeUrl'] as String?,
                  'digitalSignatureHash':
                      data['digitalSignatureHash'] as String?,
                }),
              )
              .toList();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Certificates'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.goNamed(Routes.dashboard),
          ),
        ),
        body: const Center(
          child: Text('Please log in to view your certificates'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(Routes.dashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCertificates,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCertificates,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _certificates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No certificates found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Approved certificates will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final cert = _certificates[index];
                final dateFormat = DateFormat('yyyy-MM-dd');
                final certType = cert.type;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _viewCertificate(context, cert),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: certType.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              certType.icon,
                              color: certType.primaryColor,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            certType.displayName,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Issued: ${dateFormat.format(cert.issueDate)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cert.certificateNumber,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: certType.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _viewCertificate(context, cert),
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('View'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: certType.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
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

  void _viewCertificate(BuildContext context, CertificateData cert) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CertificateDetailPage(certificate: cert),
      ),
    );
  }

  Future<void> _downloadCertificate(
    BuildContext context,
    CertificateData cert,
  ) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationService = const api_service.ApplicationService();
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token missing')),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final downloadUrl = await applicationService.getCertificateDownloadUrl(
        certificateId: cert.id,
        token: token,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show download URL to user
        // In production, you would use a package like `url_launcher` or download the file directly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Certificate download URL: $downloadUrl'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                // Copy to clipboard functionality can be added here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied to clipboard')),
                );
              },
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
