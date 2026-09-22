import 'dart:io';

void main() {
  final dir = Directory('lib/presentation/screens');
  for (var file in dir.listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    var originalContent = content;

    // SingleChildScrollView
    if (content.contains('Center(') && content.contains('SingleChildScrollView(') && content.contains('maxWidth: 800')) {
      content = content.replaceAll(RegExp(r'child:\s*Center\(\s*child:\s*ConstrainedBox\(\s*constraints:\s*const\s*BoxConstraints\(maxWidth:\s*800\),\s*child:\s*SingleChildScrollView\('), '''child: Builder(
          builder: (context) {
            final sw = MediaQuery.of(context).size.width;
            final pad = sw > 800 ? (sw - 800) / 2 : 16.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: pad),''');
      
      // Fix closing brackets for SingleChildScrollView
      content = content.replaceAll(RegExp(r'\),\s*\),\s*\),\s*\],\s*\),\s*\);'), '''); }, ), ], ), );''');
      content = content.replaceAll(RegExp(r'\),\s*\),\s*\),\s*\)\s*;\s*}'), '''); }, ) ; }''');
    }

    if (content != originalContent) {
      file.writeAsStringSync(content);
      print('Fixed ${file.path}');
    }
  }
}
