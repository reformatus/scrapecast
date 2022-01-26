import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'getlength.dart';

Uuid _uuid = Uuid();

// ignore: must_be_immutable
class Episode extends Equatable {
  late final DateTime date;
  final String title;
  final String pastor;
  final String bible;
  final String? youTube;
  final String download;
  late final String uuid;
  int? length;
  int? fileSize;

  Episode(DateTime date, this.title, this.pastor, this.bible, this.youTube,
      this.download, String? uuid, this.length, this.fileSize) {
    if (title.toLowerCase().contains('9h')) {
      date = date.add(Duration(hours: 9));
    } else if (title.toLowerCase().contains('katonatelep')) {
      date = date.add(Duration(hours: 10, minutes: 30));
    } else if (title.toLowerCase().contains('11h')) {
      date = date.add(Duration(hours: 11));
    } else if (title.toLowerCase().contains('kert')) {
      date = date.add(Duration(hours: 18));
    }
    this.date = date.toLocal();
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
        "length": length,
        "size": fileSize,
      };

  @override
  List<Object> get props => [title, pastor, date];
}

DateFormat dateFormat = DateFormat("yyyy.MM.dd");

DateFormat rfcDateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss");
String getRfcDate(DateTime date) => rfcDateFormat.format(date) + " +0100";

const String krekBase = "https://krek.hu";

class PodcastProperties {
  final int id;
  final String title;
  String description;
  final String iCategory;
  final String iCategorySecondary;
  final String artworkLink;
  final List<String>? episodeArtworks;
  final String author;
  final String link;
  final String baseUrl;
  final String ownerEmail;
  final String ownerName;
  final String podcastType;
  final String copyright;
  final bool explicit;
  final String language;

  PodcastProperties(
    this.id,
    this.title,
    this.description,
    this.iCategory,
    this.iCategorySecondary,
    this.artworkLink,
    this.episodeArtworks,
    this.author,
    this.link,
    this.baseUrl,
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
  final Map links;

  Podcast(
      this.properties, this.scraper, this.rssFile, this.dataFile, this.links);
}
