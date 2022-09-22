import 'dart:io';

import 'utils/types.dart';

import 'specifics/krek-podcast.dart';
import 'specifics/krek.dart';
import 'specifics/marco.dart';

List<Podcast> podcasts = [
  Podcast(
    PodcastID.krek,
    PodcastProperties(
      "KREK.hu Igehirdetések",
      """A Kecskeméti Református Gyülekezetben elhangzott istentiszteletek, egyéb alkalmak felvételei.
Automatikusan frissül a krek.hu/igehirdetesek oldal alapján.
Köszönjük az utómunkát: Alföldy-Boruss Illés, Csősz Győző, Molnár Tamás, Papp Attila""",
      "Religion & Spirituality",
      "Christianity",
      "https://reformatus.github.io/scrapecast/assets/krek/logo.png",
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
      "scrapecast@fodor.pro",
      "Fodor András Benedek",
      "episodic",
      "Kecskeméti Református Egyházközség",
      false,
      "hu",
    ),
    File("docs/krek.rss"),
    File("data/krek-data.json"),
    {
      "Spotify": "https://open.spotify.com/show/6xtPzwRylDoUcGQtX92ZBT",
      "PocketCasts (ajánlott!)": "https://pca.st/j7pxwtz3",
      "CastBox": "https://castbox.fm/channel/KREK.hu-Igehirdetések-id4762991",
      "Google Podcasts":
          "https://podcasts.google.com/feed/aHR0cHM6Ly9yZWZvcm1hdHVzLmdpdGh1Yi5pby9zY3JhcGVjYXN0L2tyZWsucnNz",
      "Apple Podcasts":
          "https://podcasts.apple.com/us/podcast/krek-hu-igehirdetések/id1606886562",
      "TuneIn":
          "https://tunein.com/podcasts/Religion--Spirituality-Podcasts/KREKhu-Igehirdetesek-p1611771/",
      "RadioPublic": "https://radiopublic.com/krekhu-igehirdetsek-6V4z9M",
      "RSS (kézi hozzáadáshoz)":
          "https://reformatus.github.io/scrapecast/krek.rss"
    },
    krekScrape,
    krekTitle,
    krekDescription,
    krekFromJson,
    krekToJson,
    artworkBuilder: krekArtworkBuilder,
  ),
  Podcast(
    PodcastID.krekPodcast,
    PodcastProperties(
      "KREK.hu Podcast",
      """A Kecskeméti Református Gyülekezet Podcastja. 
Szerkeszti: Papp Attila""",
      "Religion & Spirituality",
      "Christianity",
      "https://reformatus.github.io/scrapecast/assets/krekPodcast/logo.png",
      null,
      "Kecskeméti Református Egyházközség",
      "https://krek.hu/podcast",
      "https://krek.hu",
      "scrapecast@fodor.pro",
      "Fodor András Benedek",
      "episodic",
      "Kecskeméti Református Egyházközség",
      false,
      "hu",
    ),
    File("docs/krekPodcast.rss"),
    File("data/krekPodcast-data.json"),
    {
      "Spotify": "https://open.spotify.com/show/6LA5xcckdjpSbougqHGsFb",
      "PocketCasts": "https://pca.st/f932spzv",
      "CastBox": "https://castbox.fm/channel/id4772853",
      "Apple Podcasts":
          "https://podcasts.apple.com/us/podcast/krek-hu-podcast/id1607891600",
      "RadioPublic": "https://radiopublic.com/krekhu-podcast-WdmlkL",
      "RSS (kézi hozzáadáshoz)":
          "https://reformatus.github.io/scrapecast/krekPodcast.rss"
    },
    krekPodcastScrape,
    krekPodcastTitle,
    krekPodcastDescription,
    krekPodcastFromJson,
    krekPodcastToJson,
  ),
  Podcast(
      PodcastID.marco,
      PodcastProperties(
        "Marco igehirdetései",
        """
Marco de Leeuw van Weenen, a Tolnai Református Egyházmegye missziói munkatársának igehirdetései.
Automatikusan frissül a https://marko.reformatus.hu/ oldal alapján.""",
        "Religion & Spirituality",
        "Christianity",
        "https://reformatus.github.io/scrapecast/assets/marco/marco.png",
        null,
        "Marco de Leeuw van Weenen",
        "https://marko.reformatus.hu/",
        "https://marko.reformatus.hu/",
        "marcopodcast@fodor.pro",
        "Marco de Leeuw van Weenen",
        "episodic",
        "Marco de Leeuw van Weenen",
        false,
        "hu",
      ),
      File("docs/marco.rss"),
      File("data/marco-data.json"),
      {
        "Spotify": "https://open.spotify.com/show/7ETtVJt3N9QxHxVNo60C9J",
        "Google Podcasts": "https://podcasts.google.com/feed/aHR0cHM6Ly9yZWZvcm1hdHVzLmdpdGh1Yi5pby9zY3JhcGVjYXN0L21hcmNvLnJzcw",
        "PocketCasts": "https://pca.st/14nmdojx",
        "TuneIn": "https://tunein.com/podcasts/Religion--Spirituality-Podcas/Marco-igehirdetesei-p1785905/",
        "CastBox": "https://castbox.fm/ch/5087121",
        "RSS (kézi hozzáadáshoz)":
            "https://reformatus.github.io/scrapecast/marco.rss"
      },
      marcoScraper,
      marcoTitleBuilder,
      marcoDescriptionBuilder,
      marcoFromJson,
      marcoToJson)
];
