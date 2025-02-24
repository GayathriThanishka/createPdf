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
  int? rows;
  int? columns;
  List<List<TextEditingController>> controllers = [];
  List<TextEditingController> headerControllers = [];

  void initializeControllers() {
    if (rows == null || columns == null) return;
    headerControllers = List.generate(
      columns!,
      (index) => TextEditingController(),
    );

    controllers = List.generate(
      rows!,
      (rowIndex) =>
          List.generate(columns!, (colIndex) => TextEditingController()),
    );
  }

  void showSelectionDialog() {
    int selectedRows = 2;
    int selectedColumns = 2;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Select Rows and Columns"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rows: "),
                      DropdownButton<int>(
                        value: selectedRows,
                        items:
                            List.generate(10, (index) => index + 1)
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("$e"),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedRows = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Columns: "),
                      DropdownButton<int>(
                        value: selectedColumns,
                        items:
                            List.generate(10, (index) => index + 1)
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("$e"),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedColumns = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      rows = selectedRows;
                      columns = selectedColumns;
                      initializeControllers();
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController partController = TextEditingController();
  final TextEditingController techniqueController = TextEditingController();
  final TextEditingController findingController = TextEditingController();
  final TextEditingController scanContoller1 = TextEditingController();
  final TextEditingController scanContollrt2 = TextEditingController();
  final TextEditingController scanContollrt3 = TextEditingController();
  File? signaturefile;
  File? scanningfile;
  String? outputpath;

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
            SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: showSelectionDialog,
                        child: Text("Select Table Size"),
                      ),
                      if (rows != null && columns != null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Expanded(
                            // Give a fixed height
                            child: DataTable(
                              border: TableBorder.all(),
                              columns: List.generate(
                                columns!,
                                (index) => DataColumn(
                                  label: SizedBox(width: 50,
                                    child: TextField(
                                      controller: headerControllers[index],
                                    ),
                                  ),
                                ),
                              ),
                              rows: List.generate(
                                rows!,
                                (rowIndex) => DataRow(
                                  cells: List.generate(
                                    columns!,
                                    (colIndex) => DataCell(
                                      SizedBox(width: 50,
                                        child: TextField(
                                          maxLines: null,
                                          controller:
                                              controllers[rowIndex][colIndex],
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(type: FileType.image);
                              if (result != null) {
                                setState(() {
                                  signaturefile = File(
                                    result.files.single.path!,
                                  );
                                });
                              }
                            },
                            child: const Text("Import Signature"),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            signaturefile != null
                                ? "Signature Updated"
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

                              outputpath =
                                  await FilePicker.platform.getDirectoryPath();
                              if (outputpath != null) {
                                final file = File('$outputpath/ Report.pdf');
                                await file.writeAsBytes(pdfBytes);
                              }
                            },
                            child: const Text("Save "),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            outputpath != null ? "Pdf Saved" : "Save Pdf",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
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
                pw.SizedBox(height: 100),
                if (rows != null && columns != null)
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      // Table Headers
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
                      // Table Rows
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
