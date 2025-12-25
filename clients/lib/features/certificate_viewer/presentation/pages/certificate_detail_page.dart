import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/certificate_data_model.dart';
import '../widgets/birth_certificate_widget.dart';
import '../widgets/marriage_certificate_widget.dart';
import '../widgets/death_certificate_widget.dart';
import '../widgets/divorce_certificate_widget.dart';

/// Certificate Detail Page
/// Displays full certificate with type-specific styling
class CertificateDetailPage extends StatelessWidget {
  final CertificateData certificate;

  const CertificateDetailPage({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(certificate.type.displayName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement PDF download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download feature coming soon'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          margin: const EdgeInsets.all(16),
          child: _buildCertificateWidget(),
        ),
      ),
    );
  }

  Widget _buildCertificateWidget() {
    switch (certificate.type) {
      case CertificateType.birth:
        return BirthCertificateWidget(certificate: certificate);
      case CertificateType.marriage:
        return MarriageCertificateWidget(certificate: certificate);
      case CertificateType.death:
        return DeathCertificateWidget(certificate: certificate);
      case CertificateType.divorce:
        return DivorceCertificateWidget(certificate: certificate);
    }
  }
}
