import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportTemplate extends StatefulWidget {
  const ReportTemplate({super.key});

  @override
  State<ReportTemplate> createState() => _ReportTemplateState();
}

class _ReportTemplateState extends State<ReportTemplate> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController partController = TextEditingController();
  final TextEditingController techniqueController = TextEditingController();
  final TextEditingController findingController = TextEditingController();
  File? signaturefile;
  File? scanningfile;
  List tableHeaders = ['Aortic', 'Pulmonic', 'Tricuspit', 'Mitral'];
  List dataTable = [
    ['Phone', 80, 95],
    ['Internet', 250, 230],
    ['Electricity', 300, 375],
    ['Movies', 85, 80],
    ['Food', 300, 350],
    ['Fuel', 650, 550],
    ['Insurance', 250, 310],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdfBytes = await generateCertificate(
                PdfPageFormat.a4,
                nameController.text,
                ageController.text,
                techniqueController.text,
                findingController.text,
                partController.text,
              );
              await Printing.layoutPdf(onLayout: (format) => pdfBytes);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 100),
        child: Row(
          children: [
            Column(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: partController,
                    decoration: const InputDecoration(labelText: 'Part'),
                    maxLines: null,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: techniqueController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Technique",
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: findingController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Finding the Purpose",
                    ),
                    maxLines: 3,
                  ),
                ),
                SizedBox(
                  child: Container(
                    height: 200,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.image);
                        if (result != null) {
                          setState(() {
                            scanningfile = File(result.files.single.path!);
                          });
                        }
                      },
                      child: const Text("scanning image"),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(type: FileType.image);
                            if (result != null) {
                              setState(() {
                                signaturefile = File(result.files.single.path!);
                              });
                            }
                          },
                          child: const Text("Import Signature"),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          signaturefile != null
                              ? "Signature Imported"
                              : "Upload Signature",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final pdfBytes = await generateCertificate(
                              PdfPageFormat.a4,
                              nameController.text,
                              ageController.text,
                              partController.text,
                              techniqueController.text,
                              findingController.text,
                            );

                            String? outputPath =
                                await FilePicker.platform.getDirectoryPath();
                            if (outputPath != null) {
                              final file = File('$outputPath/Report.pdf');
                              await file.writeAsBytes(pdfBytes);
                            }
                          },
                          child: const Text("Save PDF"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 60),
            Expanded(
              child: PdfPreview(
                useActions: false,
                build:
                    (format) => generateCertificate(
                      format,
                      nameController.text,
                      ageController.text,
                      partController.text,
                      techniqueController.text,
                      findingController.text,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> generateCertificate(
    PdfPageFormat pageFormat,
    String name,
    String age,
    String part,
    String technique,
    String finding,
  ) async {
    final pdf = pw.Document();

    final libreBaskerville = await PdfGoogleFonts.libreBaskervilleRegular();
    final libreBaskervilleBold = await PdfGoogleFonts.libreBaskervilleBold();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          theme: pw.ThemeData.withFont(
            base: libreBaskerville,
            bold: libreBaskervilleBold,
          ),
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
                      'Patient Name:$name',
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
                pw.SizedBox(height: 150),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(width: 0.5),
                  headers: tableHeaders,
                  data: List<List<dynamic>>.generate(
                    dataTable.length,
                    (index) => <dynamic>[
                      dataTable[index][0],
                      dataTable[index][1],
                      dataTable[index][2],
                    ],
                  ),
                  headerStyle: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    // color: pw,
                  ),
                  rowDecoration: const pw.BoxDecoration(
                    border: pw.Border( 
                      bottom: pw.BorderSide(
                        // color: baseColor,
                        width: .5,
                      ),
                    ),
                  ),
                  cellAlignment: pw.Alignment.centerRight,
                  cellAlignments: {0: pw.Alignment.centerLeft},
                ),
                pw.Spacer(),
                if (signaturefile != null)
                  pw.Align(
                    alignment: pw.Alignment.bottomRight,
                    child: pw.Column(
                      children: [
                        pw.Container(
                          height: 50,
                          width: 50,
                          child: pw.Image(
                            pw.MemoryImage(signaturefile!.readAsBytesSync()),
                          ),
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
}
