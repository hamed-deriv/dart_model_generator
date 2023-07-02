import 'dart:convert';

import 'package:dart_model_generator/json_to_model.dart';

void main() {
  final json = '''{ 
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

  final jsonSchema = r'''{
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "age": {
          "type": "integer"
        },
        "isAdult": {
          "type": "boolean"
        },
        "height": {
          "type": "number"
        },
        "birthDate": {
          "type": "string",
          "format": "date-time"
        },
        "email": {
          "type": "string",
          "format": "email"
        },
        "address": {
          "type": "object",
          "properties": {
            "street": {
              "type": "string"
            },
            "city": {
              "type": "string"
            },
            "country": {
              "type": "string"
            }
          },
          "required": ["street", "city", "country"]
        },
        "phoneNumbers": {
          "type": "array",
          "items": {
            "type": "string",
            "pattern": "^[0-9]{3}-[0-9]{3}-[0-9]{4}$"
          }
        },
        "friends": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": {
                "type": "string"
              },
              "age": {
                "type": "integer"
              }
            },
            "required": ["name", "age"]
          }
        },
        "gender": {
          "type": "string",
          "enum": ["male", "female", "other"]
        },
        "favoriteColor": {
          "type": ["string", "null"],
          "enum": ["red", "green", "blue", null]
        }
      },
      "required": ["name", "age", "isAdult", "birthDate", "email", "address"]
    }''';

  Map<String, dynamic> jsonData = jsonDecode(json);
  generateModel("Sample", jsonData);
}
