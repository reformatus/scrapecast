import 'dart:io';
import 'scrapers/krekscraper.dart';
import 'utils/types.dart';

List<Podcast> podcasts = [
  Podcast(
    PodcastProperties(
      1,
      "KREK.hu Igehirdetések",
      """A Kecskeméti Református Gyülekezetben elhangzott istentiszteletek, egyéb alkalmak felvételei.
Automatikusan frissül a krek.hu/igehirdetesek oldal alapján.
Köszönjük az utómunkát: Alföldy-Boruss Illés, Csősz Győző, Molnár Tamás, Papp Attila""",
      "Religion & Spirituality",
      "Christianity",
      "https://reformatus.github.io/scrapecast/assets/logo.png",
      [
        "https://reformatus.github.io/scrapecast/assets/krek/episode-art/krek.png",
        "https://reformatus.github.io/scrapecast/assets/krek/episode-art/9.png",
        "https://reformatus.github.io/scrapecast/assets/krek/episode-art/10.png",
        "https://reformatus.github.io/scrapecast/assets/krek/episode-art/11.png",
        "https://reformatus.github.io/scrapecast/assets/krek/episode-art/18.png",
      ],
      "Kecskeméti Református Egyházközség",
      "https://krek.hu",
      "https://krek.hu",
      "fodor.benedek2001+scrapecast@gmail.com",
      "Fodor András Benedek",
      "episodic",
      "Kecskeméti Református Egyházközség",
      false,
      "hu",
    ),
    krekScrape,
    File("docs/krek.rss"),
    File("data/krek-data.json"),
    {
      "Spotify": "https://open.spotify.com/show/6xtPzwRylDoUcGQtX92ZBT",
      "PocketCasts (ajánlott!)": "https://pca.st/j7pxwtz3",
      "CastBox": "https://castbox.fm/channel/KREK.hu-Igehirdetések-id4762991",
      "Google Podcasts": "example.com", //TODO put link here
      "Apple Podcasts":
          "https://podcasts.apple.com/us/podcast/krek-hu-igehirdetések/id1606886562",
      "TuneIn":
          "https://tunein.com/podcasts/Religion--Spirituality-Podcasts/KREKhu-Igehirdetesek-p1611771/",
      "RadioPublic": "https://radiopublic.com/krekhu-igehirdetsek-6V4z9M",
      "RSS (kézi hozzáadáshoz)":
          "https://reformatus.github.io/scrapecast/krek.rss"
    },
  )
];
