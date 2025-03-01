class EditingTemplateData {
  String name;
  String age;
  String part;
  String technique;
  String finding;
  List<String> headers;
  List<List<String>> tableData;
  String? signaturePath;

  EditingTemplateData({
    required this.name,
    required this.age,
    required this.part,
    required this.technique,
    required this.finding,
    required this.headers,
    required this.tableData,
    this.signaturePath,
  });
  
  // to json used for storing

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'part': part,
      'technique': technique,
      'finding': finding,
      'headers': headers,
      'tableData': tableData,
      'signaturePath': signaturePath,
    };
  }

  // fromjson used to retrive data from db

  factory EditingTemplateData.fromJsonData(Map<String, dynamic> json) {
    return EditingTemplateData(
      name: json['name'],
      age: json['age'],
      part: json['part'],
      technique: json['technique'],
      finding: json['finding'],
      headers: List<String>.from(json['headers']),
      tableData: List<List<String>>.from(
        json['tableData'].map((row) => List<String>.from(row)),
      ),
      signaturePath: json['signaturePath'],
    );
  }
}

