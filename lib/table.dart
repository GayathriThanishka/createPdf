import 'package:flutter/material.dart';

class TableFormat extends StatefulWidget {
  final int? rows;
  final int? columns;
  final List<List<TextEditingController>> controllers;
  final List<TextEditingController> headerControllers;

  const TableFormat({
    Key? key,
    required this.rows,
    required this.columns,
    required this.controllers,
    required this.headerControllers,
  }) : super(key: key);

  @override
  _TableFormatState createState() => _TableFormatState();
}

class _TableFormatState extends State<TableFormat> {
  @override
  Widget build(BuildContext context) {
    if (widget.rows == null || widget.columns == null) {
      return Container();
    }

    return DataTable(
      border: TableBorder.all(),
      columns: List.generate(
        widget.columns!,
        (index) => DataColumn(
          label: SizedBox(
            width: 100,
            child: TextField(
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: null,
              controller: widget.headerControllers[index],
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ),
      rows: List.generate(
        widget.rows!,
        (rowIndex) => DataRow(
          cells: List.generate(
            widget.columns!,
            (colIndex) => DataCell(
              SizedBox(
                width: 100,
                child: TextField(
                  maxLines: null,
                  controller: widget.controllers[rowIndex][colIndex],
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
