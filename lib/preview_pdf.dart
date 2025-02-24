import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfView extends StatelessWidget {
  final String name;
  final String age;
  final String part;
  final String technique;
  final String finding;
  final int? rows;
  final int? columns;
  final List<TextEditingController> headerControllers;
  final List<List<TextEditingController>> controllers;
  final Uint8List? signatureImage;

  const PdfView({
    Key? key,
    required this.name,
    required this.age,
    required this.part,
    required this.technique,
    required this.finding,
    required this.rows,
    required this.columns,
    required this.headerControllers,
    required this.controllers,
    this.signatureImage,
  }) : super(key: key);

  Future<Uint8List> generateCertificate(PdfPageFormat pageFormat) async {
    final pdf = pw.Document();

    pdf.addPage(
     
      pw.Page(
        pageTheme: pw.PageTheme(
          margin: pw.EdgeInsets.only(left: 50, right: 100),
          pageFormat: pageFormat,
          theme: pw.ThemeData.withFont(),
        ),
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Asthra Medtech',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('213B6D'),
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text(
                      'Patient Name: $name',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Age: $age',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Part: ',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text('$part', style: pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Technique: ',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text('$technique', style: pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Findings:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text('$finding', style: pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 100),
                if (rows != null && columns != null)
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: List.generate(
                          columns!,
                          (index) => pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              headerControllers[index].text,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      for (int rowIndex = 0; rowIndex < rows!; rowIndex++)
                        pw.TableRow(
                          children: List.generate(
                            columns!,
                            (colIndex) => pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                controllers[rowIndex][colIndex].text,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                pw.Spacer(),
                if (signatureImage != null)
                  pw.Align(
                    alignment: pw.Alignment.bottomRight,
                    child: pw.Column(
                      children: [
                        pw.Container(
                          height: 50,
                          width: 50,
                          child: pw.Image(pw.MemoryImage(signatureImage!)),
                        ),
                        pw.Text("Signature"),
                      ],
                    ),
                  ),
              ],
            ),
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              // Generate the PDF
              final pdfBytes = await generateCertificate(PdfPageFormat.a4);

              // Print the PDF
              await Printing.layoutPdf(onLayout: (format) => pdfBytes);
            },
          ),
        ],
      ),
      body: PdfPreview(
        useActions: false,
        build: (format) => generateCertificate(format),
      ),
    );
  }
}
