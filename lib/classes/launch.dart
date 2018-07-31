import 'package:cherry/classes/rocket.dart';
import 'package:intl/intl.dart';

class Launch {
  final int missionNumber;
  final String missionName;
  final DateTime missionDate;
  final String missionDetails;
  final String missionLaunchSiteId;
  final String missionLaunchSite;
  final String missionImageUrl;
  final Rocket rocket;
  final bool fairingReused;
  final bool capsuleReused;
  final String linkReddit;
  final String linkYouTube;
  final String linkPress;

  Launch({
    this.missionNumber,
    this.missionName,
    this.missionDate,
    this.missionDetails,
    this.missionLaunchSiteId,
    this.missionLaunchSite,
    this.missionImageUrl,
    this.rocket,
    this.fairingReused,
    this.capsuleReused,
    this.linkReddit,
    this.linkYouTube,
    this.linkPress,
  });

  factory Launch.fromJson(Map<String, dynamic> json) {
    return Launch(
      missionNumber: json['flight_number'],
      missionName: json['mission_name'],
      missionDate:
          DateTime.fromMillisecondsSinceEpoch(json['launch_date_unix'] * 1000),
      missionDetails: json['details'],
      missionLaunchSiteId: json['launch_site']['site_id'],
      missionLaunchSite: json['launch_site']['site_name'],
      missionImageUrl: json['links']['mission_patch_small'],
      rocket: Rocket.fromJson(json['rocket']),
      fairingReused: json['reuse']['fairings'],
      capsuleReused: json['reuse']['capsule'],
      linkReddit: json['links']['reddit_launch'],
      linkYouTube: json['links']['video_link'],
      linkPress: json['links']['presskit'],
    );
  }

  String get getMissionNumber => '#$missionNumber';

  String get getDate =>
      '${DateFormat('d MMMM yyyy · HH:mm').format(missionDate)} ${missionDate.timeZoneName}';

  String get getImageUrl =>
      missionImageUrl ??
      'https://firebasestorage.googleapis.com/v0/b/cherry-3ca39.appspot.com/o/rocket.png?alt=media&token=66f2dde6-e6ff-4f64-a4a4-9fab6dbe90c5';

  String get getDetails =>
      missionDetails ?? 'This mission has currently no details.';
}
