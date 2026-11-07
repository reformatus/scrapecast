import 'dart:io';
import 'dart:convert';

import 'utils/feedbuilder.dart';
import 'utils/getlength.dart';
import 'utils/types.dart';
import 'podcasts.dart';

String statusMdString =
    "\n\nKészítette: [Fodor Benedek](https://github.com/redyau)\\\nKezelt Podcastek:\n\n---\n";

const String usage = """Usage: scrapecast [--backfill[=PAGES]]

  --backfill        Scrape every page of podcasts that support it and add
                    episodes missing from the data. Existing episodes are
                    left untouched.
  --backfill=PAGES  Same, but only the newest PAGES pages.""";

void main(List<String> args) async {
  Backfill? backfill;
  for (String arg in args) {
    if (arg == '--backfill') {
      backfill = Backfill(null);
    } else if (arg.startsWith('--backfill=') &&
        (int.tryParse(arg.substring('--backfill='.length)) ?? 0) > 0) {
      backfill = Backfill(int.parse(arg.substring('--backfill='.length)));
    } else {
      print(usage);
      exit(64);
    }
  }

  for (Podcast podcast in podcasts) {
    await buildPodcast(podcast, backfill);
  }

  print('Updating index page');
  File mdFile = File("docs/index.md");
  mdFile.writeAsStringSync(statusMdString);
  print('Done!');
  exit(0); //Program just froze without this, weird
}

class Backfill {
  /// Number of pages to scrape; null means all of them.
  final int? pages;
  Backfill(this.pages);
}

Future buildPodcast(Podcast podcast, Backfill? backfill) async {
  try {
    print("\n\nBuilding ${podcast.properties.title}\n");

    List<Episode> episodes = [];
    List<Episode> errors = [];

    print('Loading existing data from json');
    if (!podcast.dataFile.existsSync()) {
      podcast.dataFile.createSync();
      podcast.dataFile.writeAsStringSync("[]");
    }
    List jsonEntries = jsonDecode(podcast.dataFile.readAsStringSync());
    for (Map entry in jsonEntries) {
      episodes.add(podcast.fromJson(entry));
    }

    int stored = episodes.length;
    episodes = dedupeByFile(episodes);
    if (episodes.length < stored) {
      print(
          'Removed ${stored - episodes.length} episodes with duplicate files');
    }

    // A scraped episode whose file is already stored updates that entry's
    // metadata (titles get corrected on the site) but keeps its uuid.
    // A backfill only adds missing episodes: rewriting the whole history
    // from the current site is not its job.
    bool backfilling = backfill != null && podcast.backfillScraper != null;
    List<Episode> scraped = backfilling
        ? await podcast.backfillScraper!(backfill.pages)
        : await podcast.scraper();
    Map<String, int> indexByFile = {
      for (int i = 0; i < episodes.length; i++) episodes[i].fileKey: i
    };
    int added = 0;
    for (Episode fresh in dedupeByFile(scraped)) {
      int? i = indexByFile[fresh.fileKey];
      if (i == null) {
        indexByFile[fresh.fileKey] = episodes.length;
        episodes.add(fresh);
        added++;
      } else if (!backfilling) {
        episodes[i] = fresh.keepingIdentityOf(episodes[i]);
      }
    }
    print('Added $added new episodes');
    episodes = newestFirst(episodes);

    save() {
      print("Saving database");
      podcast.dataFile.createSync();
      podcast.dataFile.writeAsStringSync(JsonEncoder.withIndent('  ')
          .convert(episodes.map((e) => podcast.toJson(e)).toList()));
    }

    int i = 0;
    for (Episode item in episodes) {
      if (item.length == null || item.fileSize == null) {
        String url = resolveDownloadUrl(podcast, item);
        item.length ??= await getLength(url);
        item.fileSize ??= await getSize(url);
        print(
            "Properties of ${item.date} | ${item.title} is\n   Length: ${item.length ?? "!!! NULL"} seconds\n   Size: ${item.fileSize ?? "!!! NULL"} bytes");
        i++;
        if (i > 30) {
          print("\n\nThrottling and saving progress...\n\n");
          await Future.delayed(Duration(seconds: 5));
          i = 0;
          save();
        }

        if (item.length == null) {
          //! If length request failed
          print("##> Error while getting length!\n");
          errors.add(item);
        }
      }
    }

    // Episodes whose length couldn't be read stay in the data, so the next
    // run retries them (a backfilled one won't be scraped again), but they
    // are left out of the feed until it succeeds.
    save();
    List<Episode> published = episodes.where((e) => e.length != null).toList();

    // "Last updated" means the last content change: rebuild with the
    // previous timestamp, and only stamp and write a new feed if anything
    // else differs. A run without changes then leaves every file untouched.
    print("Building rss feed");
    String? previousFeed = podcast.rssFile.existsSync()
        ? podcast.rssFile.readAsStringSync()
        : null;
    String? updated = previousFeed == null
        ? null
        : RegExp(r'<lastBuildDate>(.*?)</lastBuildDate>')
            .firstMatch(previousFeed)
            ?.group(1);
    if (updated == null ||
        getFeed(published, podcast, updated) != previousFeed) {
      updated = getRfcDate(DateTime.now());
      podcast.rssFile.createSync();
      podcast.rssFile.writeAsStringSync(getFeed(published, podcast, updated));
      print("Feed updated");
    } else {
      print("Feed unchanged");
    }

    print(errors.isNotEmpty ? 'Errors:' : '');
    for (Episode item in errors) {
      print(
          "${item.uuid} | ${item.date} | ${item.title} | ${item.download} | ${item.length}");
    }

    statusMdString +=
        """## [${podcast.properties.title}](${podcast.properties.link})
_${podcast.properties.description.replaceAll("\n", "\\\n")}_

✅ Legutóbb frissítve: $updated

Epizódok száma: ${published.length}

**Elérhető:**
""";
    for (String key in podcast.links.keys) {
      statusMdString += " - [$key](${podcast.links[key]})\n";
    }

    statusMdString += "\n**Legutóbbi epizódok:**\n";
    for (Episode episode in published.take(6)) {
      statusMdString +=
          " - ${dateFormat.format(episode.date)} - ${episode.title} - ${episode.author}\n";
    }
    statusMdString += "\n---\n\n";
  } catch (e) {
    print("Error while building ${podcast.properties.title}!\n$e");
  }
}
