import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Istentisztelet extends Equatable {
  final DateTime date;
  final String title;
  final String pastor;
  final String bible;
  final String? youTube;
  final String download;

  Istentisztelet(this.date, this.title, this.pastor, this.bible, this.youTube,
      this.download);

  get toJson => {
        "title": title,
        "bible": bible,
        "date": dateFormat.format(date),
        "pastor": pastor,
        "youtube": youTube,
        "download": download
      };

  @override
  List<Object> get props => [title, pastor, date];
}

DateFormat dateFormat = DateFormat("yyyy.MM.dd");