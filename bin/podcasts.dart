import 'dart:io';
import 'scrapers/krekscraper.dart';
import 'utils/types.dart';

List<Podcast> podcasts = [
  Podcast(
      PodcastProperties(
          "KREK.hu Igehirdetések",
          "A Kecskeméti Református Gyülekezetben elhangzott istentiszteletek, egyéb alkalmak felvételei.\nAutomatikusan frissül a krek.hu/igehirdetesek oldal alapján.",
          "Religion &amp; Spirituality",
          "Christianity",
          "https://reformatus.github.io/scrapecast/assets/logo.png",
          "Kecskeméti Református Egyházközség",
          "https://krek.hu",
          "fodor.benedek2001+scrapecast@gmail.com",
          "Fodor András Benedek",
          PodcastType.episodic,
          "Kecskeméti Református Egyházközség",
          false),
      krekScrape,
      File("docs/krek.rss"),
      File("data/krek-data.json"),
      "https://krek.hu")
];
