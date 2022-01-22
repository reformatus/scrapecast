import 'dart:io';

void main(List<String> arguments) {
  print('Hello world!');
  print('This should still build.');
  print('Aand still should build.');
  File html = File("docs/index.html");
  html.writeAsString(
      "<h1>CrawlCast</h1>\nLast update: ${DateTime.now().toIso8601String()}");
}
