import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:pdftemplate/preview_pdf.dart';
//import 'package:printing/printing.dart';

class PdfScreen extends StatefulWidget {
  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  TextEditingController textController = TextEditingController();
  String? pdfPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Task For PDF Generator"))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter text for PDF",
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
                            (pw.Context context) => pw.FullPage(
                              child: pw.Text(
                                textController.text,
                                style: pw.TextStyle(
                                  font: pw.Font.helvetica(),
                                  fontSize: 10,
                                ),
                              ),
                              ignoreMargins: false,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PdfPreviewScreen(

                              pdfPath: pdfPath!),
                      ),
                    );
                  },
                  child: Text("Preview PDF"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    OpenFile.open(pdfPath);
                  },

                  child: Text("Open PDF"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
