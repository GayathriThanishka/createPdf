import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String pdfPath;

  const PdfPreviewScreen({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Preview and Print"),
        actionsPadding: EdgeInsets.only(right: 40),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              File pdfFile = File(pdfPath);
              if (await pdfFile.exists()) {
                final pdfBytes = await pdfFile.readAsBytes();
                await Printing.layoutPdf(onLayout: (format) => pdfBytes);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 300, right: 300),
        child: PdfPreview(
          useActions: false,
        build: (format) async {
            final File pdfFile = File(pdfPath);
            return pdfFile.readAsBytes();
          },
        ),
      ),
    );
  }
}
