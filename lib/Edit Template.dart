import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftemplate/table.dart';

import 'jsonformat.dart';

class EditTemp extends StatefulWidget {
  final EditingTemplateData? templateData;

  const EditTemp({Key? key, this.templateData}) : super(key: key);

  @override
  _EditTempState createState() => _EditTempState();
}

class _EditTempState extends State<EditTemp> {
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

  @override
  void initState() {
    super.initState();
    if (widget.templateData != null) {
      loadTemplateData(widget.templateData!);
    }
  }

  void loadTemplateData(EditingTemplateData templateData) {
    nameController.text = templateData.name;
    ageController.text = templateData.age;
    partController.text = templateData.part;
    techniqueController.text = templateData.technique;
    findingController.text = templateData.finding;

    rows = templateData.tableData.length;
    columns = templateData.headers.length;

    initializeControllers();

    for (int i = 0; i < templateData.headers.length; i++) {
      headerControllers[i].text = templateData.headers[i];
    }

    for (int i = 0; i < templateData.tableData.length; i++) {
      for (int j = 0; j < templateData.tableData[i].length; j++) {
        controllers[i][j].text = templateData.tableData[i][j];
      }
    }

    if (templateData.signaturePath != null) {
      signaturefile = File(templateData.signaturePath!);
    }
  }

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
                      const Text("Columns: "),
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
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  EditingTemplateData getTemplateDataf() {
    return EditingTemplateData(
      name: nameController.text,
      age: ageController.text,
      part: partController.text,
      technique: techniqueController.text,
      finding: findingController.text,
      headers: headerControllers.map((controller) => controller.text).toList(),
      tableData:
          controllers
              .map((row) => row.map((controller) => controller.text).toList())
              .toList(),
      signaturePath: signaturefile?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Edit Your Template',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
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
                            final templateData = getTemplateDataf();
                            await saveJsonToFile(templateData);

                            Navigator.pop(context);
                          },
                          child: const Text("Save Template"),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          outputpath != null ? "PDF Template" : "",
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
        ),
      ),
    );
  }
}

Future<void> saveJsonToFile(EditingTemplateData templateData) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/template_data.json');

  List<EditingTemplateData> templates = [];

  // Check if the file exists and read existing templates
   if (await file.exists()) {
    final jsonString = await file.readAsString();
     final jsonData = jsonDecode(jsonString);

    // Ensure jsonData is a List
    if (jsonData is List) {
      templates =
           jsonData
              .map((data) => EditingTemplateData.fromJsonData(data))
              .toList();
    } else {
      // If jsonData is not a List, initialize templates as an empty list
     templates = [];
     }
   }

  // Add the new template to the list
  templates.add(templateData);

  // Convert the list to JSON and save it
  final jsonString = jsonEncode(
    templates.map((template) => template.toJson()).toList(),
  );
  await file.writeAsString(jsonString);
}
