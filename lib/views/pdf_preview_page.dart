
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewPage extends StatelessWidget {
  /* properti */
  final Uint8List pdfBytes;
  final String title;

  /* konstruksi */
  const PdfPreviewPage({
    super.key,
    required this.pdfBytes,
    this.title = 'pdf preview',
  });

  /* metode */
  Future<void> _sharePdf(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/pet_catalog_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(pdfBytes, flush: true);

      final params = ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: 'here is the pet catalog report.',
      );
      SharePlus.instance.share(params);

      /*await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'here is the pet catalog report.',
      );*/

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed to share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              _sharePdf(context);
            },
            icon: Icon(Icons.share),
            tooltip: 'share / export pdf',
          ),
        ],
      ),
      body: SfPdfViewer.memory(
        pdfBytes,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      ),
    );
  }
}
