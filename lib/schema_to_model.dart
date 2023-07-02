import 'dart:convert';

class JsonSchemaConverter {
  String convertToDartClass(Map<String, dynamic> schema, String className) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('class $className {');

    if (schema.containsKey('properties')) {
      var properties = schema['properties'] as Map<String, dynamic>;
      properties.forEach((propertyName, property) {
        var propertyType = _getPropertyType(property, propertyName);
        var isRequired = schema['required'] != null &&
            schema['required'].contains(propertyName);

        buffer.writeln(
            '  ${isRequired ? 'required' : 'optional'} $propertyType $propertyName;');
      });
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String _getPropertyType(Map<String, dynamic> property, String propertyName) {
    if (property.containsKey('type')) {
      var type = property['type'];
      if (type is String) {
        return _getTypeFromJsonType(type);
      } else if (type is List) {
        var typeList = type.cast<String>();
        if (typeList.contains('null')) {
          typeList.remove('null');
        }
        return typeList.map(_getTypeFromJsonType).join(' | ');
      }
    } else if (property.containsKey('enum')) {
      var enumValues = property['enum'] as List<dynamic>;
      var enumType =
          '${propertyName[0].toUpperCase()}${propertyName.substring(1)}';
      var enumValuesString = enumValues.map((value) => "'$value'").join(', ');
      return 'enum $enumType { $enumValuesString }';
    } else if (property.containsKey('properties')) {
      var nestedSchema = property['properties'] as Map<String, dynamic>;
      var nestedClassName =
          '${propertyName[0].toUpperCase()}${propertyName.substring(1)}';
      return convertToDartClass(nestedSchema, nestedClassName);
    }

    return 'dynamic';
  }

  String _getTypeFromJsonType(String jsonType) {
    switch (jsonType) {
      case 'null':
        return 'Null';
      case 'boolean':
        return 'bool';
      case 'integer':
        return 'int';
      case 'number':
        return 'double';
      case 'string':
        return 'String';
      case 'array':
        return 'List<dynamic>';
      case 'object':
        return 'dynamic'; // We handle nested schemas separately
      default:
        return 'dynamic';
    }
  }
}

void main() {
  var className = 'Person';

  var converter = JsonSchemaConverter();
  var dartClass =
      converter.convertToDartClass(jsonDecode(jsonSchema), className);

  print(dartClass);
}

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
