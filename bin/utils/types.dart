import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'getlength.dart';

Uuid _uuid = Uuid();

// ignore: must_be_immutable
class Istentisztelet extends Equatable {
  final DateTime date;
  final String title;
  final String pastor;
  final String bible;
  final String? youTube;
  final String download;
  late final String uuid;
  int? length;

  Istentisztelet(this.date, this.title, this.pastor, this.bible, this.youTube,
      this.download, String? uuid, this.length) {
    this.uuid = uuid ?? _uuid.v4();
  }

  get toJson => {
        "title": title,
        "bible": bible,
        "date": dateFormat.format(date),
        "pastor": pastor,
        "youtube": youTube,
        "download": download,
        "uuid": uuid,
        "length": length
      };

  @override
  List<Object> get props => [title, pastor, date];
}

DateFormat dateFormat = DateFormat("yyyy.MM.dd");

const String krekBase = "https://krek.hu";

class PodcastProperties {
  final String title;
  final String description;
  final String iCategory;
  final String iCategorySecondary;
  final String artworkLink;
  final String author;
  final String link;
  final String ownerEmail;
  final String ownerName;
  final String podcastType;
  final String copyright;
  final bool explicit;
  final String language;

  PodcastProperties(
    this.title,
    this.description,
    this.iCategory,
    this.iCategorySecondary,
    this.artworkLink,
    this.author,
    this.link,
    this.ownerEmail,
    this.ownerName,
    this.podcastType,
    this.copyright,
    this.explicit,
    this.language,
  );
}

class Podcast {
  final PodcastProperties properties;
  final Function scraper;
  final File rssFile;
  final File dataFile;
  final String baseUrl;

  Podcast(
      this.properties, this.scraper, this.rssFile, this.dataFile, this.baseUrl);
}
