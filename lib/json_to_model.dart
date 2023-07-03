import 'dart:convert';

import 'package:dart_model_generator/extension.dart';

class ClassInfo {
  String className;
  Map<String, dynamic> jsonData;

  ClassInfo(this.className, this.jsonData);
}

void generateModel(String className, Map<String, dynamic> jsonData) {
  StringBuffer modelBuffer = StringBuffer();

  List<ClassInfo> classesToGenerate = [];

  void processJsonData(String className, Map<String, dynamic> jsonData) {
    if (classesToGenerate
        .any((classInfo) => compareClassData(classInfo.jsonData, jsonData))) {
      return;
    }

    classesToGenerate.add(ClassInfo(className, jsonData));

    jsonData.forEach((key, value) {
      if (value is Map) {
        String nestedClassName = '${className.capitalize}$key';
        processJsonData(nestedClassName, value as Map<String, dynamic>);
      } else if (value is List && value.isNotEmpty && value.first is Map) {
        String nestedClassName = '${className.capitalize}$key';
        processJsonData(nestedClassName, value.first);
      }
    });
  }

  processJsonData(className, jsonData);

  for (var classInfo in classesToGenerate) {
    String className = classInfo.className;
    Map<String, dynamic> jsonData = classInfo.jsonData;

    modelBuffer.writeln("class $className {");

    jsonData.forEach((key, value) {
      if (value is String) {
        modelBuffer.writeln("  final String $key;");
      } else if (value is int) {
        modelBuffer.writeln("  final int $key;");
      } else if (value is double) {
        modelBuffer.writeln("  final double $key;");
      } else if (value is bool) {
        modelBuffer.writeln("  final bool $key;");
      } else if (value is Map) {
        String nestedClassName = '${className.capitalize}$key';
        modelBuffer.writeln("  final $nestedClassName $key;");
      } else if (value is List) {
        if (value.isNotEmpty && value.first is Map) {
          String nestedClassName = '${className.capitalize}$key';
          modelBuffer.writeln("  final List<$nestedClassName> $key;");
        } else {
          modelBuffer.writeln("  final List<dynamic> $key;");
        }
      }
    });

    modelBuffer.writeln("\n  $className({");

    jsonData.forEach((key, value) {
      modelBuffer.writeln("    required this.$key,");
    });

    modelBuffer.writeln("  });");

    modelBuffer.writeln("}\n");
  }

  print(modelBuffer.toString());
}

bool compareClassData(
  Map<String, dynamic> classData1,
  Map<String, dynamic> classData2,
) {
  if (classData1.keys.length != classData2.keys.length) {
    return false;
  }

  for (var key in classData1.keys) {
    if (!classData2.containsKey(key)) {
      return false;
    }

    if (classData1[key].runtimeType != classData2[key].runtimeType) {
      return false;
    }

    if (classData1[key] is Map && classData2[key] is Map) {
      if (!compareClassData(classData1[key], classData2[key])) {
        return false;
      }
    }
  }

  return true;
}

void main() {
  const String json = '''{ 
      "coffee": {
          "region": [
              {"id":1,"name":"John Doe"},
              {"id":2,"name":"Don Joeh"}
          ],
          "country": {"id":2,"company":"ACME"}
      }, 
      "brewing": {
          "region": [
              {"id":1,"name":"John Doe"},
              {"id":2,"name":"Don Joeh"}
          ],
          "country": {"id":2,"company":"ACME"}
      }
  }''';

  Map<String, dynamic> jsonData = jsonDecode(json);
  generateModel("Sample", jsonData);
}
