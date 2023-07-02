import 'dart:convert';

import 'package:dart_model_generator/json_to_model.dart';

void main() {
  final jsonString = '''{ 
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

  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  generateModel("Order", jsonData);
}
