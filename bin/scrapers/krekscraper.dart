import 'package:html/parser.dart';
import 'package:http/http.dart';

import '../utils/types.dart';

Future<List<Istentisztelet>> krekScrape() async {
  print('Scraping latest from krek.hu');

  var httpClient = Client();
  var resp = await httpClient.get(
    Uri.parse(//post(
        'https://www.krek.hu/sources/webshop/product_list.php'), //body: {'prod_page': '12'}
  );
  var document = parse(resp.body);
  var rows = document.querySelectorAll('div.data');

  List<Istentisztelet> list = [];

  for (var row in rows) {
    List<String> downloadLinks = [];
    row.querySelector('div.dwnld')!.querySelectorAll('a').forEach((element) {
      downloadLinks.add(element.attributes.values.first);
    });

    list.add(Istentisztelet(
        dateFormat.parse(row.querySelector('div.datum')!.text),
        row.querySelector('div.cim')!.text,
        row.querySelector('div.hirdeto')!.text,
        row.querySelector('div.igeresz')!.text,
        (downloadLinks.length > 1) ? downloadLinks.first : null,
        downloadLinks.last,
        null,
        null));
  }

  return list;
}
