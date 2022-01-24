import 'dart:math';
import 'package:xml/xml.dart';

import 'types.dart';

String getFeed(List<Episode> list, PodcastProperties properties) {
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
      builder.element('copyright', nest: () {
        builder.text('![CDATA[${properties.copyright}]]'); //! Copyright
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
          builder.text('![CDATA[${properties.ownerName}]]');
        });
        builder.element('itunes:email', nest: () {
          builder.text('![CDATA[${properties.ownerEmail}]]');
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

      for (Episode element in list) {
        builder.element('item', nest: () {
          builder.element('title', nest: () {
            builder.text('![CDATA[${element.title} | ${element.pastor}]]');
          });
          builder.element('description', nest: () {
            builder.text('![CDATA[${getDescription(element)}]]');
          });
          builder.element('guid', nest: () {
            builder.text(element.uuid);
          });
          builder.element('dc:creator', nest: () {
            builder.text('![CDATA[${properties.author}]]');
          });
          builder.element('pubDate', nest: () {
            builder.text(element.date
                .toIso8601String()); //! Date in ISO format (is good?)
          });
          builder.element('enclosure', attributes: {
            "url": (properties.baseUrl + element.download),
            "length": '${element.fileSize}',
            "type": 'audio/mpeg'
          });
          builder.element('itunes:summary', nest: () {
            builder.text('![CDATA[${getDescription(element)}]]');
          });
          builder.element('itunes:explicit', nest: () {
            builder.text('${properties.explicit}');
          });
          builder.element('itunes:duration', nest: () {
            builder.text('${element.length}');
          });
          builder.element('itunes:image',
              attributes: {"href": properties.artworkLink});
          builder.element('itunes:season', nest: () {
            builder.text('${element.date.year - 2000}');
          });
          builder.element('itunes:episodeType', nest: () {
            builder.text('full');
          });
        });
      }
    });
  });

  return builder.buildDocument().toXmlString(pretty: true);
}

String getDescription(Episode element) {
  XmlBuilder builder = XmlBuilder();

  if (element.youTube != null) {
    builder.element('p', nest: () {
      builder.element('a', attributes: {"href": element.youTube!}, nest: () {
        builder.text('> Az alkalomról videófelvétel is elérhető <');
      });
    });
  }

  builder.element('p', nest: () {
    builder.text('Lelkész/Előadó: ${element.pastor}');
  });
  builder.element('p', nest: () {
    builder.text('Igerész: ${element.bible}');
  });
  builder.element('p', nest: () {
    builder.text('Igerész: ${element.bible}');
  });

  builder.element('br', isSelfClosing: true);
  builder.element('hr', isSelfClosing: true);
  builder.element('br', isSelfClosing: true);

  builder.element('i', nest: () {
    builder.element('p', nest: () {
      builder.text('UUID: ${element.uuid}');
      builder.text('Becsült hossz: ${element.length} mp');
      builder.text('Generálta: ScrapeCast by Fodor Benedek');
    });
  });

  return builder
      .buildDocument()
      .toXmlString(pretty: true, preserveWhitespace: (_) => true);
}
