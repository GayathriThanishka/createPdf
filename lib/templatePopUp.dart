import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftemplate/Edit%20Template.dart';
import 'package:pdftemplate/jsonformat.dart';

class TemplatePopup extends StatefulWidget {
  final Function(String) onTemplateSelected;

  const TemplatePopup({Key? key, required this.onTemplateSelected})
    : super(key: key);

  @override
  _TemplatePopupState createState() => _TemplatePopupState();
}

class _TemplatePopupState extends State<TemplatePopup> {
  List<EditingTemplateData> templates = [];

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/template_data.json');

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);

      if (jsonData is List) {
        setState(() {
          templates =
              jsonData
                  .map((data) => EditingTemplateData.fromJsonData(data))
                  .toList();
        });
      }
    }
  }

  Future<void> navigateToEditTemplate(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTemp()),
    );
    loadTemplates(); // Reload templates when returning
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Select a Template'),
          ElevatedButton(
            onPressed: () => navigateToEditTemplate(context),
            child: const Text("Add Template"),
          ),
        ],
      ),
      content:
          templates.isEmpty
              ? const Center(child: Text('No templates found.'))
              : SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditTemp(templateData: template);
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 180, 180, 180),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Asthra Medtech',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFF213B6D),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Patient Name: ${template.name}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Age: ${template.age}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 20),
                            const Text(
                              'Part:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              template.part,
                              style: const TextStyle(fontSize: 8),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Technique: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              template.technique,
                              style: const TextStyle(fontSize: 8),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Findings:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              template.finding,
                              style: const TextStyle(fontSize: 8),
                            ),
                            const SizedBox(height: 40),
                            if (template.tableData != null &&
                                template.tableData.isNotEmpty)
                              Table(
                                border: TableBorder.all(),
                                children: [
                                  if (template.headers != null &&
                                      template.headers.isNotEmpty)
                                    TableRow(
                                      children:
                                          template.headers
                                              .map(
                                                (header) => Padding(
                                                  padding: const EdgeInsets.all(
                                                    5,
                                                  ),
                                                  child: Text(
                                                    header,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  for (var row in template.tableData)
                                    TableRow(
                                      children:
                                          row
                                              .map(
                                                (cell) => Padding(
                                                  padding: const EdgeInsets.all(
                                                    5,
                                                  ),
                                                  child: Text(cell),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
