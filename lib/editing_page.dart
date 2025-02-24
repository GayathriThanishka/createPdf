import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdftemplate/preview_pdf.dart';
import 'package:pdftemplate/table.dart';
import 'package:printing/printing.dart';

class EditingPage extends StatefulWidget {
  const EditingPage({Key? key}) : super(key: key);

  @override
  _EditingPageState createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  int? rows;
  int? columns;
  List<List<TextEditingController>> controllers = [];
  List<TextEditingController> headerControllers = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController partController = TextEditingController();
  final TextEditingController techniqueController = TextEditingController();
  final TextEditingController findingController = TextEditingController();

  File? signaturefile;
  String? outputpath;

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
              title: const Text("Select Rows and Columns"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Rows: "),
                      DropdownButton<int>(
                        value: selectedRows,
                        items: List.generate(10, (index) => index + 1)
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
                      const Text("Columns: "),
                      DropdownButton<int>(
                        value: selectedColumns,
                        items: List.generate(10, (index) => index + 1)
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
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Edit Your Report'),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: partController,
                  decoration: const InputDecoration(
                    labelText: 'Part',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: techniqueController,
                  decoration: const InputDecoration(
                    labelText: 'Technique',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: findingController,
                  decoration: const InputDecoration(
                    labelText: 'Finding the Purpose',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 20),

           
              ElevatedButton(
                onPressed: showSelectionDialog,
                child: const Text("Select Table Size"),
              ),
              if (rows != null && columns != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TableFormat(
                    rows: rows,
                    columns: columns,
                    controllers: controllers,
                    headerControllers: headerControllers,
                  ),
                ),
              const SizedBox(height: 20),

            
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.image,
                          );
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
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final pdfBytes = await PdfView(
                            name: nameController.text,
                            age: ageController.text,
                            part: partController.text,
                            technique: techniqueController.text,
                            finding: findingController.text,
                            rows: rows,
                            columns: columns,
                            headerControllers: headerControllers,
                            controllers: controllers,
                            signatureImage: signaturefile?.readAsBytesSync(),
                          ).generateCertificate(PdfPageFormat.a4);

                          outputpath =
                              await FilePicker.platform.getDirectoryPath();
                          if (outputpath != null) {
                            final file = File('$outputpath/Report.pdf');
                            await file.writeAsBytes(pdfBytes);
                          }
                        },
                        child: const Text("Save PDF"),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        outputpath != null ? "PDF Saved" : "Save PDF",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfView(
                          name: nameController.text,
                          age: ageController.text,
                          part: partController.text,
                          technique: techniqueController.text,
                          finding: findingController.text,
                          rows: rows,
                          columns: columns,
                          headerControllers: headerControllers,
                          controllers: controllers,
                          signatureImage: signaturefile?.readAsBytesSync(),
                        ),
                      ),
                    ),
                    child: const Text('Preview PDF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}