import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart' as xml;

import '../utils/types.dart';

/// Serves both old and new sermon files (new ones 404 on krek.hu).
const String krekStoreHost = 'https://store.krek.hu';
const String krekStoreBase = '$krekStoreHost/media/files/igehirdetesek/';

const String krekListUrl =
    'https://www.krek.hu/sources/webshop/product_list.php';

/// Scrapes the first page of the sermon list (newest 20).
Future<List<Episode>> krekScrape() => krekScrapePages(1);

/// Scrapes up to [maxPages] pages of the sermon list (20 per page, newest
/// first), or every page when null. Stops at the first page without rows.
Future<List<Episode>> krekScrapePages(int? maxPages) async {
  print('Scraping latest from krek.hu'
      '${maxPages == 1 ? '' : ' (${maxPages ?? 'all'} pages)'}');

  var httpClient = Client();
  List<Episode> list = [];
  try {
    for (int page = 0; maxPages == null || page < maxPages; page++) {
      if (page > 0) await Future.delayed(Duration(milliseconds: 300));
      var resp = await httpClient.post(Uri.parse(krekListUrl),
          body: {'prod_page': '$page', 'f_value': '', 'f_spec': ''});
      if (resp.statusCode != 200) {
        throw Exception('krek.hu page ${page + 1}: HTTP ${resp.statusCode}');
      }
      List<Episode> pageEpisodes = _parseKrekPage(resp.body);
      if (pageEpisodes.isEmpty && !resp.body.contains('class="data"')) break;
      if (maxPages != 1) {
        print('  Page ${page + 1}: ${pageEpisodes.length} episodes');
      }
      list.addAll(pageEpisodes);
    }
  } finally {
    httpClient.close();
  }
  return list;
}

bool _isYoutube(String href) {
  String host = Uri.tryParse(href.trim())?.host.toLowerCase() ?? '';
  return host == 'youtu.be' ||
      host == 'youtube.com' ||
      host.endsWith('.youtube.com');
}

/// Resolves a file reference from the list to an absolute http(s) URL:
/// absolute URLs are kept, protocol-relative ones get https, root-relative
/// paths go to store.krek.hu and bare filenames to its sermon folder.
/// Returns null for empty references and non-http(s) schemes.
String? _resolveKrekFile(String? ref) {
  ref = ref?.trim();
  if (ref == null || ref.isEmpty) return null;
  if (ref.startsWith('//')) ref = 'https:$ref';
  Uri? uri = Uri.tryParse(ref);
  if (uri == null) return null;
  if (uri.hasScheme) {
    return (uri.scheme == 'http' || uri.scheme == 'https') ? ref : null;
  }
  return ref.startsWith('/') ? '$krekStoreHost$ref' : '$krekStoreBase$ref';
}

List<Episode> _parseKrekPage(String body) {
  var document = parse(body);
  var rows = document.querySelectorAll('div.data');

  List<Episode> list = [];

  for (var row in rows) {
    try {
      List<String> hrefs = row
          .querySelectorAll('div.dwnld a')
          .map((a) => a.attributes['href'])
          .whereType<String>()
          .where((href) => href.isNotEmpty)
          .toList();

      // The download link is now a bare filename; the audio player's source
      // (a sibling of div.data) holds the absolute URL on store.krek.hu.
      // Fall back to the last non-YouTube download link.
      List<String> files = hrefs
          .where((href) => !_isYoutube(href))
          .map(_resolveKrekFile)
          .whereType<String>()
          .toList();
      String? download = _resolveKrekFile(
              row.parent?.querySelector('audio source')?.attributes['src']) ??
          (files.isEmpty ? null : files.last);
      if (download == null) continue;

      List<String> youtubeLinks = hrefs.where(_isYoutube).toList();
      String? youtube = youtubeLinks.isEmpty ? null : youtubeLinks.first;

      list.add(Episode(
          PodcastID.krek, //! id
          dateFormat.parse(row
              .querySelector('div.datum')!
              .text
              .trim()
              .replaceAll(RegExp(r'\.$'), '')), //! date
          row.querySelector('div.cim')!.text, //! title
          row.querySelector('div.hirdeto')!.text, //! author
          row.querySelector('div.igeresz')!.text, //! field1 (bible)
          youtube, //! field2 (youtube)
          download, //! download
          null,
          null,
          null));
    } catch (e) {
      print(
          '##> Skipping unreadable row (${row.text.trim().replaceAll(RegExp(r"\s+"), " ")}): $e');
    }
  }

  return list;
}

Episode krekFromJson(Map entry) => Episode(
    PodcastID.krek,
    dateFormat.parse(entry["date"]),
    entry["title"],
    entry["pastor"],
    entry["bible"],
    entry["youtube"],
    entry["download"],
    entry["uuid"],
    entry["length"],
    entry["size"]);

Map krekToJson(Episode episode) => {
      "title": episode.title,
      "bible": episode.field1,
      "date": dateFormat.format(episode.date),
      "pastor": episode.author,
      "youtube": episode.field2,
      "download": episode.download,
      "uuid": episode.uuid,
      "length": episode.length,
      "size": episode.fileSize,
    };

String krekTitle(Episode element) =>
    '${element.title} | ${element.author} | ${dateFormat.format(element.date)}';

String krekDescription(Podcast podcast, Episode element) {
  xml.XmlBuilder builder = xml.XmlBuilder();

  if (element.field2 != null) {
    builder.element('p', nest: () {
      builder.element('a', attributes: {"href": element.field2!}, nest: () {
        builder
            .text('Az alkalomról videófelvétel is elérhető: ${element.field2}');
      });
    });
  }

  builder.element('br', isSelfClosing: true);

  builder.element('p', nest: () {
    builder.text('Igerész: ${element.field1}');
  });
  builder.element('p', nest: () {
    builder.text('Lelkész: ${element.author}');
  });

  builder.element('br', isSelfClosing: true);
  builder.element('hr', isSelfClosing: true);

  builder.element('p', nest: () {
    builder.text('Lejátszás közvetlen fájlból (hiba esetén): ');
    builder.element('a',
        attributes: {"href": resolveDownloadUrl(podcast, element)}, nest: () {
      builder.text(resolveDownloadUrl(podcast, element));
    });
  });

  builder.element('br', isSelfClosing: true);

  builder.element('p', nest: () {
    builder.text('Becsült hossz: ${element.length} mp');
  });
  builder.element('p', nest: () {
    builder.text('Generálta: ');
    builder.element('a',
        attributes: {"href": "https://reformatus.github.io/scrapecast"},
        nest: () {
      builder.text('ScrapeCast');
    });
    builder.text(' by Fodor Benedek');
  });
  builder.element('p', nest: () {
    builder.text('UUID: ${element.uuid}');
  });

  return builder
      .buildDocument()
      .toXmlString(pretty: true, preserveWhitespace: (_) => true);
}

String krekArtworkBuilder(Podcast podcast, Episode episode) {
  assert(podcast.properties.episodeArtworks!.length == 5);
  switch (episode.date.hour) {
    case 9:
      return podcast.properties.episodeArtworks![1];
    case 10:
      return podcast.properties.episodeArtworks![2];
    case 11:
      return podcast.properties.episodeArtworks![3];
    case 18:
      return podcast.properties.episodeArtworks![4];
    default:
      return podcast.properties.episodeArtworks![0];
  }
}
