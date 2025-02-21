import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdftemplate/preview_pdf.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  TextEditingController ageController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController statementController = TextEditingController();

  String? pdfPath;
  File? signaturefile;
  List tableHeaders = ['Category', 'Budget', 'Expense', 'Result'];

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
      appBar: AppBar(title: Center(child: Text("Task For PDF Generator"))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Patient Name'),
                 SizedBox(width: 300,
                   child: TextField(
                      controller: nameController,
                      minLines: 1,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Name",
                      ),
                    ),
                 ),Text("Age"),
                   SizedBox(width: 300,
                     child: TextField(
                      controller: ageController,
                      minLines: 1,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Age",
                      ),
                                       ),
                   ),
        Text("Statement of Purpose"),
                 SizedBox(width: 300,
                   child: TextField(
                     controller: statementController,
                     minLines: 1,
                     maxLines: null,
                     decoration: InputDecoration(
                       border: OutlineInputBorder(),
                       hintText: "Statement of Purpose",
                     ),
                   ),
                 ),Text("Report Content"),
                SizedBox(width: 300,
                  child: TextField(
                    controller: contentController,
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Report Content",
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final pdf = pw.Document();
                        pdf.addPage(
                          pw.Page(
                            pageFormat: PdfPageFormat.a4,
            
                            build:
                                (pw.Context context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      nameController.text,
                                      style: pw.TextStyle(
                                        font: pw.Font.helvetica(),
                                        fontSize: 12,
                                      ),
                                    ),
                                    pw.Text(
                                      ageController.text,
                                      style: pw.TextStyle(
                                        font: pw.Font.helvetica(),
                                        fontSize: 12,
                                      ),
                                    ),
                                     pw.Text(
                                      statementController.text,
                                      style: pw.TextStyle(
                                        font: pw.Font.helvetica(),
                                        fontSize: 12,
                                      ),
                                    ),
                                     pw.Text(
                                      contentController.text,
                                      style: pw.TextStyle(
                                        font: pw.Font.helvetica(),
                                        fontSize: 12,
                                      ),
                                    ),
                                    pw.Spacer(flex: 40),
                                    pw.TableHelper.fromTextArray(
                                      border: null,
                                      headers: tableHeaders,
                                      data: List<List<dynamic>>.generate(
                                        dataTable.length,
                                        (index) => <dynamic>[
                                          dataTable[index][0],
                                          dataTable[index][1],
                                          dataTable[index][2],
                                          (dataTable[index][1] as num) -
                                              (dataTable[index][2] as num),
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
              pw.Spacer(flex: 30),
                                    pw.Align(
                                      alignment: pw.Alignment.bottomRight,
                                      child: pw.Column(
                                        children: [
                                          pw.Container(
                                            height: 50,
                                            width: 50,
                                            child: pw.Image(
                                              pw.MemoryImage(
                                                signaturefile!.readAsBytesSync(),
                                              ),
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
            
                        final output = await getTemporaryDirectory();
                        final file = File("${output.path}/pdfpreview.pdf");
                        await file.writeAsBytes(await pdf.save());
            
                        setState(() => pdfPath = file.path);
                      },
                      child: Text("Generate PDF"),
                    ),
                    SizedBox(width: 10),
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
                      child: Text("Import Signature"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PdfPreviewScreen(pdfPath: pdfPath!),
                          ),
                        );
                      },
                      child: Text("Preview PDF"),
                    ),
                    SizedBox(width: 10),
            
                    // ElevatedButton(
                    //   onPressed: () {
                    //     OpenFile.open(pdfPath);
                    //   },
            
                    //   child: Text("Open PDF"),
                    // ),
                  ],
                ),
              ],
            ),
          
        ),
      ),
    );
  }
}
