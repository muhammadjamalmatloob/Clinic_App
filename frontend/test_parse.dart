import 'dart:convert';
import 'lib/domain/entities/token_entity.dart';

void main() {
  String jsonStr = '''
[
  {
    "id": "67fa5307-d861-474b-8f95-781304566579",
    "queue_session_id": "70ed5c17-5638-491e-9dc8-ef98d0b68f07",
    "patient_id": "ae425aa2-d11e-469d-908b-7e75f2f2a220",
    "dependent_id": null,
    "token_number": 1,
    "status": "waiting",
    "issued_at": "2026-09-21T18:30:40.022099Z",
    "estimated_wait_minutes": 0,
    "called_at": null,
    "completed_at": null
  }
]
  ''';
  
  try {
    List<dynamic> jsonList = jsonDecode(jsonStr);
    for (var json in jsonList) {
      final entity = TokenEntity.fromJson(json);
      print('Parsed token \${entity.tokenNumber} successfully!');
    }
  } catch (e, stack) {
    print('Failed to parse: \$e');
    print(stack);
  }
}
