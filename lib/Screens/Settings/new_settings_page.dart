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
  bool get wantKeepAlive => sectionsToShow.value.contains('Settings');

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
        body: Column(
          children: [/*_searchBar(context),*/ _settingsItem(context)],
        ),
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
                      icon: const Icon(Icons.arrow_back),
                    )
                  : const Icon(Icons.search),
              // suffixIcon: widget.showClose
              //     ? ValueListenableBuilder(
              //   valueListenable: hide,
              //   builder: (
              //       BuildContext context,
              //       bool hidden,
              //       Widget? child,
              //       ) {
              //     return Visibility(
              //       visible: !hidden,
              //       child: IconButton(
              //         icon: const Icon(Icons.close_rounded),
              //         onPressed: () {
              //           widget.controller.text = '';
              //           suggestionsList.value = [];
              //           if (widget.onQueryCleared != null) {
              //             widget.onQueryCleared!.call();
              //           }
              //         },
              //       ),
              //     );
              //   },
              // )
              //     : null,
              border: InputBorder.none,
              hintText: 'Search settings',
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onSubmitted: (submittedQuery) {},
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
        'items': [
          AppLocalizations.of(context)!.darkMode,
          AppLocalizations.of(context)!.useSystemTheme,
          AppLocalizations.of(context)!.accent,
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
        'icon': Icons.add,
        'onTap': AppUIPage(
          callback: widget.callback,
        ),
        'items': [
          AppLocalizations.of(context)!.playerScreenBackground,
          AppLocalizations.of(context)!.useDenseMini,
          AppLocalizations.of(context)!.miniButtons,
          AppLocalizations.of(context)!.changeOrder,
          AppLocalizations.of(context)!.compactNotificationButtons,
          AppLocalizations.of(context)!.blacklistedHomeSections,
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
        'icon': Icons.music_note,
        'onTap': MusicPlaybackPage(
          callback: widget.callback,
        ),
        'items': [
          AppLocalizations.of(context)!.musicLang,
          AppLocalizations.of(context)!.chartLocation,
          AppLocalizations.of(context)!.streamQuality,
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
        'items': [
          AppLocalizations.of(context)!.downQuality,
          AppLocalizations.of(context)!.ytDownQuality,
          AppLocalizations.of(context)!.downLocation,
          AppLocalizations.of(context)!.downFilename,
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
        'icon': Icons.miscellaneous_services,
        'onTap': const OthersPage(),
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
        'icon': Icons.settings_backup_restore,
        'onTap': const BackupAndRestorePage(),
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
        'icon': Icons.info_outline,
        'onTap': const AboutPage(),
        'items': [
          AppLocalizations.of(context)!.version,
          AppLocalizations.of(context)!.shareApp,
          AppLocalizations.of(context)!.likedWork,
          AppLocalizations.of(context)!.donateGpay,
          AppLocalizations.of(context)!.contactUs,
          AppLocalizations.of(context)!.joinTg,
          AppLocalizations.of(context)!.moreInfo,
        ]
      },
    ];

    // todo: implement search
    // final List searchOptions = [];
    // searchedList.map((e) => searchOptions.addAll(e['items'] as List));

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 5),
        physics: const BouncingScrollPhysics(),
        itemCount: settingsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(settingsList[index]['icon'] as IconData),
            title: Text(settingsList[index]['title'].toString()),
            subtitle: Text(
              (settingsList[index]['items'] as List).join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => settingsList[index]['onTap'] as Widget,
              ),
            ),
          );
        },
      ),
    );
  }

  // todo: implement search.
  // Widget _searchSuggestions(BuildContext context, List searchOptions) {
  //   return ListView.builder(
  //     itemCount: searchOptions.length,
  //     itemBuilder: (context, index) => Card(
  //       child: Text(searchOptions[index].toString()),
  //     ),
  //   );
  // }
}
