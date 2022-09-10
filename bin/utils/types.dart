import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

Uuid _uuid = Uuid();

enum PodcastID { krek, gref, krekPodcast, marco }

// ignore: must_be_immutable
class Episode extends Equatable {
  late final DateTime date;
  final String title;
  final String
      author; //! not an official podcast episode field -- must be manually included in title or description
  final String? field1;
  final String? field2;
  final String download;
  late final String uuid;
  int? length;
  int? fileSize;

  Episode(PodcastID id, DateTime date, this.title, this.author, this.field1,
      this.field2, this.download, String? uuid, this.length, this.fileSize) {
    if (id == PodcastID.krek) {
      //HACK
      if (title.toLowerCase().contains('9h')) {
        date = date.add(Duration(hours: 9));
      } else if (title.toLowerCase().contains('katonatelep')) {
        date = date.add(Duration(hours: 10, minutes: 30));
      } else if (title.toLowerCase().contains('11h')) {
        date = date.add(Duration(hours: 11));
      } else if (title.toLowerCase().contains('kert')) {
        date = date.add(Duration(hours: 18));
      }
    }
    this.date = date.toLocal();
    this.uuid = uuid ?? _uuid.v4();
  }

  @override
  List<Object> get props => [title, author, date];
}

DateFormat dateFormat = DateFormat("yyyy.MM.dd");

DateFormat rfcDateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss");
String getRfcDate(DateTime date) => rfcDateFormat.format(date) + " +0100";

//const String krekBase = "https://krek.hu";

class PodcastProperties {
  final String title;
  final String description;
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
  final PodcastID id;
  final PodcastProperties properties;
  Function scraper;
  Function titleBuilder;
  Function descriptionBuilder;
  Function fromJson;
  Function toJson;
  final File rssFile;
  final File dataFile;
  final Map links;
  Function artworkBuilder;

  Podcast(
      this.id,
      this.properties,
      this.rssFile,
      this.dataFile,
      this.links,
      this.scraper,
      this.titleBuilder,
      this.descriptionBuilder,
      this.fromJson,
      this.toJson,
      {this.artworkBuilder = defaultCoverBuilder});
}

String defaultCoverBuilder(Podcast podcast, Episode episode) =>
    podcast.properties.artworkLink;
