import 'package:xml/xml.dart';

import 'types.dart';

String getFeed(List<Istentisztelet> list) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element('rss', attributes: {
    'xmlns:itunes': 'http://www.itunes.com/dtds/podcast-1.0.dtd',
    'xmlns:content': 'http://purl.org/rss/1.0/modules/content/'
  }, nest: () {
    builder.element('channel', nest: () {
      builder.element('title', nest: () {
        builder.text('KREK.hu Igehirdetések'); //!
      });
      builder.element('description', nest: () {
        builder.text(
            'A Kecskeméti Református Gyülekezetben elhangzott istentiszteletek, egyéb alkalmak felvételei.<br />Automatikusan frissül a krek.hu/igehirdetesek oldal alapján.'); //!
      });
      builder.element('link', nest: () {
        builder.text('https://krek.hu/igehirdetesek');
      });
      builder.element('image', nest: () {
        builder.element('url', nest: () {
          builder
              .text('https://reformatus.github.io/scrapecast/assets/logo.png');
        });
      });
    });
  });

  return builder.buildDocument().toXmlString(pretty: true);
}
