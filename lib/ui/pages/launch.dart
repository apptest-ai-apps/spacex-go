import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:row_collection/row_collection.dart';
import 'package:share/share.dart';
import 'package:sliver_fab/sliver_fab.dart';

import '../../models/index.dart';
import '../../repositories/index.dart';
import '../../util/menu.dart';
import '../../util/photos.dart';
import '../../util/url.dart';
import '../widgets/index.dart';
import 'index.dart';

/// This view displays all information about a specific launch.
class LaunchPage extends StatelessWidget {
  final int number;

  const LaunchPage(this.number);

  @override
  Widget build(BuildContext context) {
    final Launch _launch = context.read<LaunchesRepository>().getLaunch(number);
    return Scaffold(
      body: SliverFab(
        expandedHeight: MediaQuery.of(context).size.height * 0.3,
        floatingWidget: SafeArea(
          top: false,
          bottom: false,
          left: false,
          child: _launch.hasVideo
              ? FloatingActionButton(
                  heroTag: null,
                  tooltip: FlutterI18n.translate(
                    context,
                    'spacex.other.tooltip.watch_replay',
                  ),
                  onPressed: () => FlutterWebBrowser.openWebPage(
                    url: _launch.getVideo,
                    androidToolbarColor: Theme.of(context).primaryColor,
                  ),
                  child: Icon(Icons.ondemand_video),
                )
              : Builder(
                  builder: (context) => FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Theme.of(context).accentColor,
                    tooltip: FlutterI18n.translate(
                      context,
                      'spacex.other.tooltip.add_event',
                    ),
                    onPressed: () async {
                      if (await Add2Calendar.addEvent2Cal(Event(
                        title: _launch.name,
                        description: _launch.details ??
                            FlutterI18n.translate(
                              context,
                              'spacex.launch.page.no_description',
                            ),
                        location: _launch.launchpadName,
                        startDate: _launch.launchDate,
                        endDate: _launch.launchDate.add(
                          Duration(minutes: 30),
                        ),
                      ))) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Event added to the calendar'),
                          ),
                        );
                      } else {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error while trying to add the event'),
                          ),
                        );
                      }
                    },
                    child: Icon(Icons.event),
                  ),
                ),
        ),
        slivers: <Widget>[
          SliverBar(
            title: _launch.name,
            header: SwiperHeader(
              list: _launch.hasPhotos
                  ? _launch.photos
                  : List.from(SpaceXPhotos.upcoming)
                ..shuffle(),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => Share.share(
                  FlutterI18n.translate(
                    context,
                    _launch.launchDate.isAfter(DateTime.now())
                        ? 'spacex.other.share.launch.future'
                        : 'spacex.other.share.launch.past',
                    translationParams: {
                      'number': _launch.number.toString(),
                      'name': _launch.name,
                      'launchpad': _launch.launchpadName,
                      'date': _launch.getTentativeDate,
                      'details': Url.shareDetails
                    },
                  ),
                ),
                tooltip: FlutterI18n.translate(
                  context,
                  'spacex.other.menu.share',
                ),
              ),
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  for (final url in Menu.launch)
                    PopupMenuItem(
                      value: url,
                      enabled: _launch.isUrlEnabled(context, url),
                      child: Text(FlutterI18n.translate(context, url)),
                    )
                ],
                onSelected: (name) => FlutterWebBrowser.openWebPage(
                  url: _launch.getUrl(context, name),
                  androidToolbarColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverToBoxAdapter(
              child: RowLayout.cards(children: <Widget>[
                _missionCard(context),
                _firstStageCard(context),
                _secondStageCard(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard(BuildContext context) {
    final Launch _launch = context.read<LaunchesRepository>().getLaunch(number);
    return CardPage.header(
      leading: AbsorbPointer(
        absorbing: !_launch.hasPatch,
        child: HeroImage.card(
          url: _launch.patchUrl,
          tag: _launch.getNumber,
          onTap: () => FlutterWebBrowser.openWebPage(
            url: _launch.patchUrl,
            androidToolbarColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
      title: _launch.name,
      subtitle: RowLayout(
        crossAxisAlignment: CrossAxisAlignment.start,
        space: 6,
        children: <Widget>[
          ItemSnippet(
            icon: Icons.calendar_today,
            text: _launch.getLaunchDate(context),
          ),
          ItemSnippet(
            icon: Icons.location_on,
            text: _launch.launchpadName ??
                FlutterI18n.translate(context, 'spacex.other.unknown'),
            onTap: _launch.launchpadName == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeNotifierProvider<LaunchpadRepository>(
                          create: (context) => LaunchpadRepository(
                            _launch.launchpadId,
                            _launch.launchpadName,
                          ),
                          child: LaunchpadPage(),
                        ),
                        fullscreenDialog: true,
                      ),
                    ),
          ),
        ],
      ),
      details: _launch.getDetails(context),
    );
  }

  Widget _firstStageCard(BuildContext context) {
    final Launch _launch = context.read<LaunchesRepository>().getLaunch(number);
    final Rocket rocket = _launch.rocket;

    return CardPage.body(
      title: FlutterI18n.translate(
        context,
        'spacex.launch.page.rocket.title',
      ),
      body: RowLayout(children: <Widget>[
        RowText(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.model',
          ),
          rocket.name,
        ),
        RowText(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.static_fire_date',
          ),
          _launch.getStaticFireDate(context),
        ),
        RowText(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.launch_window',
          ),
          _launch.getLaunchWindow(context),
        ),
        RowIcon(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.launch_success',
          ),
          _launch.launchSuccess,
        ),
        if (_launch.launchSuccess == false) ...<Widget>[
          Separator.divider(),
          RowText(
            FlutterI18n.translate(
              context,
              'spacex.launch.page.rocket.failure.time',
            ),
            _launch.failureDetails.getTime,
          ),
          RowText(
            FlutterI18n.translate(
              context,
              'spacex.launch.page.rocket.failure.altitude',
            ),
            _launch.failureDetails.getAltitude(context),
          ),
          TextExpand(_launch.failureDetails.getReason)
        ],
        for (final core in _launch.rocket.firstStage) _getCores(context, core),
      ]),
    );
  }

  Widget _secondStageCard(BuildContext context) {
    final Launch _launch = context.read<LaunchesRepository>().getLaunch(number);
    final SecondStage secondStage = _launch.rocket.secondStage;
    final Fairing fairing = _launch.rocket.fairing;

    return CardPage.body(
      title: FlutterI18n.translate(
        context,
        'spacex.launch.page.payload.title',
      ),
      body: RowLayout(children: <Widget>[
        RowText(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.payload.second_stage.model',
          ),
          secondStage.getBlock(context),
        ),
        if (_launch.rocket.hasFairing) ...<Widget>[
          Separator.divider(),
          RowIcon(
            FlutterI18n.translate(
              context,
              'spacex.launch.page.payload.fairings.reused',
            ),
            fairing.reused,
          ),
          if (fairing.recoveryAttempt == true)
            RowIcon(
              FlutterI18n.translate(
                context,
                'spacex.launch.page.payload.fairings.recovery_success',
              ),
              fairing.recoverySuccess,
            )
          else
            RowIcon(
              FlutterI18n.translate(
                context,
                'spacex.launch.page.payload.fairings.recovery_attempt',
              ),
              fairing.recoveryAttempt,
            ),
        ],
        // If the launch has multiple payloads
        _getPayload(context, secondStage.getPayload(0)),
        if (secondStage.payloads.length > 1)
          ExpandList(Column(children: <Widget>[
            for (final Payload payload in secondStage.payloads.sublist(1))
              _getPayload(context, payload),
          ]))
      ]),
    );
  }

  Widget _getCores(BuildContext context, Core core) {
    return RowLayout(children: <Widget>[
      Separator.divider(),
      RowDialog(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.rocket.core.serial',
        ),
        core.getId(context),
        screen: ChangeNotifierProvider<CoreRepository>(
          create: (context) => CoreRepository(core.id),
          child: CoreDialog(),
        ),
      ),
      RowText(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.rocket.core.model',
        ),
        core.getBlock(context),
      ),
      RowIcon(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.rocket.core.reused',
        ),
        core.reused,
      ),
      if (core.landingIntent == true) ...<Widget>[
        RowDialog(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.core.landing_zone',
          ),
          core.getLandingZone(context),
          screen: ChangeNotifierProvider<LandpadRepository>(
            create: (context) => LandpadRepository(core.landingZone),
            child: LandpadPage(),
          ),
        ),
        RowIcon(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.core.landing_success',
          ),
          core.landingSuccess,
        )
      ] else
        RowIcon(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.core.landing_attempt',
          ),
          core.landingIntent,
        ),
      RowExpand(RowLayout(children: <Widget>[
        RowIcon(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.core.landing_legs',
          ),
          core.legs,
        ),
        RowIcon(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.rocket.core.gridfins',
          ),
          core.gridfins,
        ),
      ])),
    ]);
  }

  Widget _getPayload(BuildContext context, Payload payload) {
    return RowLayout(children: <Widget>[
      Separator.divider(),
      RowText(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.payload.name',
        ),
        payload.getId(context),
      ),
      if (payload.isNasaPayload) ...<Widget>[
        RowDialog(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.payload.capsule_serial',
          ),
          payload.getCapsuleSerial(context),
          screen: ChangeNotifierProvider<CapsuleRepository>(
            create: (context) => CapsuleRepository(payload.capsuleSerial),
            child: CapsulePage(),
          ),
        ),
        RowIcon(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.payload.capsule_reused',
          ),
          payload.reused,
        ),
      ],
      RowText(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.payload.manufacturer',
        ),
        payload.getManufacturer(context),
      ),
      RowText(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.payload.customer',
        ),
        payload.getCustomer(context),
      ),
      RowText(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.payload.nationality',
        ),
        payload.getNationality(context),
      ),
      RowText(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.payload.mass',
        ),
        payload.getMass(context),
      ),
      RowText(
        FlutterI18n.translate(
          context,
          'spacex.launch.page.payload.orbit',
        ),
        payload.getOrbit(context),
      ),
      RowExpand(RowLayout(children: <Widget>[
        RowText(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.payload.periapsis',
          ),
          payload.getPeriapsis(context),
        ),
        RowText(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.payload.apoapsis',
          ),
          payload.getApoapsis(context),
        ),
        RowText(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.payload.inclination',
          ),
          payload.getInclination(context),
        ),
        RowText(
          FlutterI18n.translate(
            context,
            'spacex.launch.page.payload.period',
          ),
          payload.getPeriod(context),
        ),
      ]))
    ]);
  }
}
