import 'dart:convert';

import 'package:dart_model_generator/extension.dart';

class DartClassGenerator {
  final List<String> _enums = <String>[];
  final List<String> _nestedClasses = <String>[];

  String result(
    String jsonSchema, [
    String title = 'MyClass',
  ]) {
    final StringBuffer buffer = StringBuffer();

    buffer.write(_generateDartClassFromJsonSchema(jsonSchema, title));
    _enums.forEach(buffer.writeln);
    _nestedClasses.forEach(buffer.writeln);

    return '$buffer';
  }

  StringBuffer _generateDartClassFromJsonSchema(
    String jsonSchema,
    String title,
  ) {
    final dynamic schema = json.decode(jsonSchema);
    final String className = schema['title'] ?? title;
    final List<dynamic> requiredFields = schema['required'] ?? <String>[];

    final StringBuffer buffer = StringBuffer();

    buffer.writeln('class $className {');

    if (schema.containsKey('properties')) {
      final Map<String, dynamic> properties = schema['properties'];

      properties.forEach((String fieldName, dynamic fieldSchema) {
        final String fieldType = _getFieldType(fieldSchema, fieldName);
        final bool isRequired = requiredFields.contains(fieldName);
        final String fieldDeclaration =
            isRequired ? '$fieldType $fieldName;' : '$fieldType? $fieldName;';

        buffer.writeln('  $fieldDeclaration');
      });
    }

    buffer.writeln('}\n');

    return buffer;
  }

  String _getFieldType(
    Map<String, dynamic> fieldSchema,
    String fieldName,
  ) {
    if (fieldSchema.containsKey('enum')) {
      final String enumValues =
          fieldSchema['enum'].map((dynamic value) => value).join(', ');

      _enums.add('enum ${fieldName.capitalize} { $enumValues }\n');

      return fieldName.capitalize;
    }

    final String fieldType = fieldSchema['type'];

    switch (fieldType) {
      case 'object':
        final String nestedClassName = fieldName.capitalize;

        final StringBuffer nestedClassBuffer = _generateDartClassFromJsonSchema(
          jsonEncode(fieldSchema),
          nestedClassName,
        );

        _nestedClasses.add('$nestedClassBuffer');

        return nestedClassName;
      case 'array':
        final String nestedClassName = fieldName.capitalize;

        final StringBuffer nestedClassBuffer = _generateDartClassFromJsonSchema(
          jsonEncode(fieldSchema['items']),
          nestedClassName,
        );

        _nestedClasses.add('$nestedClassBuffer');

        return 'List<$nestedClassName>';
      case 'string':
        return 'String';
      case 'number':
        return 'double';
      case 'integer':
        return 'int';
      case 'boolean':
        return 'bool';

      default:
        return 'dynamic';
    }
  }
}

void main() {
  const String jsonSchema = '''
    {
      "title": "Person",
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "age": { "type": "integer" },
        "gender": {
          "type": "string",
          "enum": ["male", "female", "other"]
        },
        "email": { "type": "string" },
        "address1": {
            "type": "object",
            "properties": {
              "street": { "type": "string" },
              "city": { "type": "string" },
              "zipcode": { "type": "string" }
            }
          },
          "address2": {
          "type": "object",
          "properties": {
            "street": { "type": "string" },
            "city": { "type": "string" },
            "zipcode": { "type": "string" }
          },
          "required": ["street", "city"]
        },
        "phoneNumbers": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "number": { "type": "string" },
              "type": {
                "type": "string",
                "enum": ["home", "work", "fax"]
              }
            }
          }
        }
      },
      "required": ["name", "email"]
    }
  ''';

  final String dartClass = DartClassGenerator().result(jsonSchema);
  print(dartClass);
}
