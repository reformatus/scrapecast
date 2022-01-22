import 'dart:io';

void main(List<String> arguments) {
  print('Hello world!');
  print('This should still build.');
  print('Aand still should build.');
  File html = File("docs/index.html");
  List<String> lines = html.readAsLinesSync();
  lines.removeLast();
  html.writeAsString(lines.reduce((value, element) => value + "\n" + element));
}
