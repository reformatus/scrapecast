import 'dart:io';
import 'dart:typed_data';
import 'package:id3/id3.dart';
import 'package:mp3_info/mp3_info.dart';

Future<int?> getLength(String download) async {
  print('\nGetting length of $download');
  print('Downloading...');
  List<int> bytes = [];
  try {
    MP3Info? mp3;
    int? retry;
    final req = await HttpClient().getUrl(Uri.parse(download));
    final resp = await req.close();
    await for (List<int> current in resp.asBroadcastStream()) {
      bytes.addAll(current);
      if (bytes.length > 512 && retry == null) {
        try {
          mp3 = MP3Processor.fromBytes(Uint8List.fromList(bytes));
          break;
        } catch (e) {
          if (e is RangeError) {
            retry = e.invalidValue;
            print(
                "\n##> Error ($e) with 0.5 kB of data, retrying with ${e.invalidValue} bytes...");
          } else {
            return null;
          }
        }
      }
      if (bytes.length > retry! + 100) {
        mp3 = MP3Processor.fromBytes(Uint8List.fromList(bytes));
        retry = null;
        break;
      }
    }

    return ((resp.contentLength * 8) ~/ mp3!.bitrate) ~/ 1000;
  } catch (e) {
    print("Error while getting length for link $download!\n-------\n$e");
    return null;
  }
}

Future<int?> getSize(String download) async {
  print('Getting size of $download');
  final req = await HttpClient().getUrl(Uri.parse(download));
  final resp = await req.close();
  return resp.contentLength;
}
