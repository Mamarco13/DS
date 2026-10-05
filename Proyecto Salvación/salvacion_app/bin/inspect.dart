import 'dart:io';

void main() {
  print('CWD: ' + Directory.current.path);
  final dir = Directory('assets');
  print('assets exists: ' + dir.existsSync().toString());
  if (dir.existsSync()) {
    for (var f in dir.listSync()) {
      print(f.path);
    }
  }
}
