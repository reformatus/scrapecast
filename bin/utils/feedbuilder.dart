import 'package:xml/xml.dart';

import 'types.dart';

String getFeed(List<Episode> list, Podcast podcast) {
  String description = podcast.properties.description +
      ' \nLegutóbb frissítve: ${getRfcDate(DateTime.now())}';

  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element('rss', attributes: {
    'xmlns:itunes': 'http://www.itunes.com/dtds/podcast-1.0.dtd',
    'xmlns:content': 'http://purl.org/rss/1.0/modules/content/',
    'xmlns:atom': 'http://www.w3.org/2005/Atom',
    'version': '2.0'
  }, nest: () {
    builder.element('channel', nest: () {
      builder.element('title', nest: () {
        builder.text(podcast.properties.title); //! Title
      });
      builder.element('description', nest: () {
        builder.cdata(description); //! Descriion
      });
      builder.element('link', nest: () {
        builder.text(podcast.properties.link); //! Link
      });
      builder.element('image', nest: () {
        builder.element('url', nest: () {
          builder.text(podcast.properties.artworkLink); //! Image
        });
        builder.element('title', nest: () {
          builder.cdata(podcast.properties.title);
        });
        builder.element('link', nest: () {
          builder.text(podcast.properties.link);
        });
      });
      builder.element('generator', nest: () {
        builder.text('ScrapeCast');
      });
      builder.element('lastBuildDate', nest: () {
        builder.text(getRfcDate(DateTime.now()));
      });
      builder.element('author', nest: () {
        builder.cdata(podcast.properties.author); //! Author
      });
      builder.element('copyright', nest: () {
        builder.cdata(podcast.properties.copyright); //! Copyght
      });
      builder.element('language', nest: () {
        builder.cdata(podcast.properties.language); //! Lanage
      });
      builder.element('itunes:author', nest: () {
        builder.text(podcast.properties.author); //! Author
      });
      builder.element('itunes:summary', nest: () {
        builder.cdata(description); //! Descriion
      });
      builder.element('itunes:type', nest: () {
        builder.text(podcast.properties.podcastType); //! Type
      });
      builder.element('itunes:owner', nest: () {
        builder.element('itunes:name', nest: () {
          builder.text(podcast.properties.ownerName);
        });
        builder.element('itunes:email', nest: () {
          builder.text(podcast.properties.ownerEmail);
        });
      });
      builder.element('itunes:explicit', nest: () {
        builder
            .text(podcast.properties.explicit ? "yes" : "no"); //! Is explicit
      });
      builder.element('itunes:category',
          attributes: {"text": podcast.properties.iCategory}, nest: () {
        builder.element('itunes:category', attributes: {
          "text": podcast.properties.iCategorySecondary
        }); //! Category
      });
      builder.element('itunes:image',
          attributes: {"href": podcast.properties.artworkLink}); //! Image
      builder.element('atom:link', attributes: {
        "rel": "hub",
        "href": "https://pubsubhubbub.appspot.com/"
      });

      for (Episode episode in list) {
        builder.element('item', nest: () {
          builder.element('title', nest: () {
            builder.text(podcast.titleBuilder(episode));
          });
          builder.element('description', nest: () {
            builder.cdata(podcast.descriptionBuilder(podcast, episode));
          });
          builder.element('guid', attributes: {"isPermaLink": "false"},
              nest: () {
            builder.text(episode.uuid);
          });
          builder.element('pubDate', nest: () {
            builder.text(getRfcDate(episode.date));
          });
          builder.element('enclosure', attributes: {
            "url": (podcast.properties.baseUrl + episode.download),
            "length": '${episode.fileSize}',
            "type": 'audio/mpeg'
          });
          builder.element('itunes:summary', nest: () {
            builder.cdata(podcast.descriptionBuilder(podcast, episode));
          });
          builder.element('itunes:explicit', nest: () {
            builder.text(podcast.properties.explicit ? "yes" : "no");
          });
          builder.element('itunes:duration', nest: () {
            builder.text('${episode.length}');
          });
          builder.element('itunes:image',
              attributes: {"href": podcast.artworkBuilder(podcast, episode)});
          builder.element('itunes:episodeType', nest: () {
            builder.text('full');
          });
        });
      }
    });
  });

  return builder.buildDocument().toXmlString(pretty: true);
}
