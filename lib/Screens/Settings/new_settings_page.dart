import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/Screens/Settings/about.dart';
import 'package:blackhole/Screens/Settings/app_ui.dart';
import 'package:blackhole/Screens/Settings/backup_and_restore.dart';
import 'package:blackhole/Screens/Settings/download.dart';
import 'package:blackhole/Screens/Settings/music_playback.dart';
import 'package:blackhole/Screens/Settings/others.dart';
import 'package:blackhole/Screens/Settings/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class NewSettingsPage extends StatefulWidget {
  final Function? callback;
  const NewSettingsPage({this.callback});

  @override
  State<NewSettingsPage> createState() => _NewSettingsPageState();
}

class _NewSettingsPageState extends State<NewSettingsPage>
    with AutomaticKeepAliveClientMixin<NewSettingsPage> {
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<List> sectionsToShow = ValueNotifier<List>(
    Hive.box('settings').get(
      'sectionsToShow',
      defaultValue: ['Home', 'Top Charts', 'YouTube', 'Library'],
    ) as List,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => sectionsToShow.value.contains('Settings');

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: _searchBar(context),
          // Text(
          //   AppLocalizations.of(
          //     context,
          //   )!
          //       .settings,
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     color: Theme.of(context).iconTheme.color,
          //   ),
          // ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: _settingsItem(context),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
        0.0,
        10.0,
        0.0,
        15.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      elevation: 8.0,
      child: SizedBox(
        height: 52.0,
        child: Center(
          child: TextField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: Colors.transparent,
                ),
              ),
              fillColor: Theme.of(context).colorScheme.secondary,
              prefixIcon: Navigator.canPop(context)
                  ? IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  : const Icon(Icons.search),
              suffixIcon: controller.text.trim() != ''
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
              border: InputBorder.none,
              hintText: 'Search settings',
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Widget _settingsItem(BuildContext context) {
    final List<Map<String, dynamic>> settingsList = [
      {
        'title': AppLocalizations.of(
          context,
        )!
            .theme,
        'icon': MdiIcons.themeLightDark,
        'onTap': ThemePage(
          callback: widget.callback,
        ),
        'isThreeLine': true,
        'items': [
          AppLocalizations.of(context)!.darkMode,
          AppLocalizations.of(context)!.accent,
          AppLocalizations.of(context)!.useSystemTheme,
          AppLocalizations.of(context)!.bgGrad,
          AppLocalizations.of(context)!.cardGrad,
          AppLocalizations.of(context)!.bottomGrad,
          AppLocalizations.of(context)!.canvasColor,
          AppLocalizations.of(context)!.cardColor,
          AppLocalizations.of(context)!.useAmoled,
          AppLocalizations.of(context)!.currentTheme,
          AppLocalizations.of(context)!.saveTheme,
        ]
      },
      {
        'title': AppLocalizations.of(
          context,
        )!
            .ui,
        'icon': Icons.design_services_rounded,
        'onTap': AppUIPage(
          callback: widget.callback,
        ),
        'isThreeLine': true,
        'items': [
          AppLocalizations.of(context)!.playerScreenBackground,
          AppLocalizations.of(context)!.miniButtons,
          AppLocalizations.of(context)!.useDenseMini,
          AppLocalizations.of(context)!.blacklistedHomeSections,
          AppLocalizations.of(context)!.changeOrder,
          AppLocalizations.of(context)!.compactNotificationButtons,
          AppLocalizations.of(context)!.showPlaylists,
          AppLocalizations.of(context)!.showLast,
          AppLocalizations.of(context)!.showTopCharts,
          AppLocalizations.of(context)!.enableGesture,
        ]
      },
      {
        'title': AppLocalizations.of(
          context,
        )!
            .musicPlayback,
        'icon': Icons.music_note_rounded,
        'onTap': MusicPlaybackPage(
          callback: widget.callback,
        ),
        'isThreeLine': true,
        'items': [
          AppLocalizations.of(context)!.musicLang,
          AppLocalizations.of(context)!.streamQuality,
          AppLocalizations.of(context)!.chartLocation,
          AppLocalizations.of(context)!.streamWifiQuality,
          AppLocalizations.of(context)!.ytStreamQuality,
          AppLocalizations.of(context)!.loadLast,
          AppLocalizations.of(context)!.resetOnSkip,
          AppLocalizations.of(context)!.enforceRepeat,
          AppLocalizations.of(context)!.autoplay,
          AppLocalizations.of(context)!.cacheSong,
        ]
      },
      {
        'title': AppLocalizations.of(
          context,
        )!
            .down,
        'icon': Icons.download_done_rounded,
        'onTap': const DownloadPage(),
        'isThreeLine': true,
        'items': [
          AppLocalizations.of(context)!.downQuality,
          AppLocalizations.of(context)!.downLocation,
          AppLocalizations.of(context)!.downFilename,
          AppLocalizations.of(context)!.ytDownQuality,
          AppLocalizations.of(context)!.createAlbumFold,
          AppLocalizations.of(context)!.createYtFold,
          AppLocalizations.of(context)!.downLyrics,
        ]
      },
      {
        'title': AppLocalizations.of(
          context,
        )!
            .others,
        'icon': Icons.miscellaneous_services_rounded,
        'onTap': const OthersPage(),
        'isThreeLine': true,
        'items': [
          AppLocalizations.of(context)!.lang,
          AppLocalizations.of(context)!.includeExcludeFolder,
          AppLocalizations.of(context)!.minAudioLen,
          AppLocalizations.of(context)!.liveSearch,
          AppLocalizations.of(context)!.useDown,
          AppLocalizations.of(context)!.getLyricsOnline,
          AppLocalizations.of(context)!.supportEq,
          AppLocalizations.of(context)!.stopOnClose,
          AppLocalizations.of(context)!.checkUpdate,
          AppLocalizations.of(context)!.useProxy,
          AppLocalizations.of(context)!.proxySet,
          AppLocalizations.of(context)!.clearCache,
          AppLocalizations.of(context)!.shareLogs,
        ]
      },
      {
        'title': AppLocalizations.of(
          context,
        )!
            .backNRest,
        'icon': Icons.settings_backup_restore_rounded,
        'onTap': const BackupAndRestorePage(),
        'isThreeLine': false,
        'items': [
          AppLocalizations.of(context)!.createBack,
          AppLocalizations.of(context)!.restore,
          AppLocalizations.of(context)!.autoBack,
          AppLocalizations.of(context)!.autoBackLocation,
        ]
      },
      {
        'title': AppLocalizations.of(
          context,
        )!
            .about,
        'icon': Icons.info_outline_rounded,
        'onTap': const AboutPage(),
        'isThreeLine': false,
        'items': [
          AppLocalizations.of(context)!.version,
          AppLocalizations.of(context)!.shareApp,
          AppLocalizations.of(context)!.contactUs,
          AppLocalizations.of(context)!.likedWork,
          AppLocalizations.of(context)!.donateGpay,
          AppLocalizations.of(context)!.joinTg,
          AppLocalizations.of(context)!.moreInfo,
        ]
      },
    ];

    final List searchOptions = [];
    for (final Map e in settingsList) {
      searchOptions.addAll(e['items'] as List);
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 15.0,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: settingsList.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(settingsList[index]['icon'] as IconData),
              title: Text(settingsList[index]['title'].toString()),
              subtitle: Text(
                (settingsList[index]['items'] as List).take(3).join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: settingsList[index]['isThreeLine'] as bool? ?? false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => settingsList[index]['onTap'] as Widget,
                ),
              ),
            );
          },
        ),
        if (controller.text.trim() != '')
          _searchSuggestions(context, searchOptions),
      ],
    );
  }

  Widget _searchSuggestions(BuildContext context, List searchOptions) {
    final List options = controller.text.trim() != ''
        ? searchOptions
            .where(
              (element) => element
                  .toString()
                  .toLowerCase()
                  .contains(controller.text.toLowerCase()),
            )
            .toList()
        : [];
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 18.0,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      elevation: 8.0,
      child: SizedBox(
        height: options.length * 70,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 10, top: 10),
          physics: const BouncingScrollPhysics(),
          itemCount: options.length,
          itemExtent: 70,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text(options[index].toString()),
              onTap: () {
                // todo
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ));
              },
            );
          },
        ),
      ),
    );
  }
}
