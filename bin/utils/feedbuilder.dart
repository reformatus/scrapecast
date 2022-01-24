import 'package:xml/xml.dart';

import 'types.dart';

String getFeed(List<Istentisztelet> list, PodcastProperties properties) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element('rss', attributes: {
    'xmlns:itunes': 'http://www.itunes.com/dtds/podcast-1.0.dtd',
    'xmlns:content': 'http://purl.org/rss/1.0/modules/content/',
    'version': '2.0'
  }, nest: () {
    builder.element('channel', nest: () {
      builder.element('title', nest: () {
        builder.text('![CDATA[${properties.title}]]'); //! Title
      });
      builder.element('description', nest: () {
        builder.text('![CDATA[${properties.description}]]'); //! Description
      });
      builder.element('link', nest: () {
        builder.text(properties.link); //! Link
      });
      builder.element('image', nest: () {
        builder.element('url', nest: () {
          builder.text(properties.artworkLink); //! Image
        });
        builder.element('title', nest: () {
          builder.text(properties.title);
        });
        builder.element('link', nest: () {
          builder.text(properties.link);
        });
      });
      builder.element('generator', nest: () {
        builder.text('ScrapeCast');
      });
      builder.element('lastBuildDate', nest: () {
        builder.text(DateTime.now().toIso8601String());
      });
      builder.element('author', nest: () {
        builder.text('![CDATA[${properties.author}]]'); //! Author
      });
      builder.element('language', nest: () {
        builder.text('![CDATA[${properties.language}]]'); //! Language
      });
      builder.element('itunes:author', nest: () {
        builder.text(properties.author); //! Author
      });
      builder.element('itunes:summary', nest: () {
        builder.text('![CDATA[${properties.description}]]'); //! Description
      });
      builder.element('itunes:category', nest: () {
        builder.text(properties.podcastType); //! Type
      });
      builder.element('itunes:owner', nest: () {
        builder.element('itunes:name', nest: () {
          builder.text('![CDATA[${properties.ownerName}]]'); //! Description
        });
        builder.element('itunes:email', nest: () {
          builder.text('![CDATA[${properties.ownerEmail}]]'); //! Description
        });
      });
      builder.element('itunes:explicit', nest: () {
        builder.text('${properties.explicit}'); //! Is explicit
      });
      builder.element('itunes:category',
          attributes: {"text": properties.iCategory}, nest: () {
        builder.element('itunes:category',
            attributes: {"text": properties.iCategorySecondary}); //! Category
      });
      builder.element('itunes:image',
          attributes: {"href": properties.artworkLink}); //! Image
    });
  });

  return builder.buildDocument().toXmlString(pretty: true);
}
