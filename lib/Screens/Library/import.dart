/*
 *  This file is part of BlackHole (https://github.com/Sangwan5688/BlackHole).
 * 
 * BlackHole is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BlackHole is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BlackHole.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'package:app_links/app_links.dart';
import 'package:blackhole/APIs/spotify_api.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/miniplayer.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/CustomWidgets/textinput_dialog.dart';
import 'package:blackhole/Helpers/import_export_playlist.dart';
import 'package:blackhole/Helpers/playlist.dart';
import 'package:blackhole/Helpers/search_add_playlist.dart';
import 'package:blackhole/Helpers/spotify_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportPlaylist extends StatelessWidget {
  ImportPlaylist({super.key});

  final Box settingsBox = Hive.box('settings');
  final List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.importPlaylist,
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.secondary,
                elevation: 0,
              ),
              body: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: 5,
                itemBuilder: (cntxt, index) {
                  return ListTile(
                    title: Text(
                      index == 0
                          ? AppLocalizations.of(context)!.importFile
                          : index == 1
                              ? AppLocalizations.of(context)!.importSpotify
                              : index == 2
                                  ? AppLocalizations.of(context)!.importYt
                                  : index == 3
                                      ? AppLocalizations.of(
                                          context,
                                        )!
                                          .importJioSaavn
                                      : AppLocalizations.of(
                                          context,
                                        )!
                                          .importResso,
                    ),
                    leading: SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: Icon(
                          index == 0
                              ? MdiIcons.import
                              : index == 1
                                  ? MdiIcons.spotify
                                  : index == 2
                                      ? MdiIcons.youtube
                                      : Icons.music_note_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                    onTap: () {
                      index == 0
                          ? importFile(
                              cntxt,
                              playlistNames,
                              settingsBox,
                            )
                          : index == 1
                              ? connectToSpotify(
                                  cntxt,
                                  playlistNames,
                                  settingsBox,
                                )
                              : index == 2
                                  ? importYt(
                                      cntxt,
                                      playlistNames,
                                      settingsBox,
                                    )
                                  : index == 3
                                      ? importJioSaavn(
                                          cntxt,
                                          playlistNames,
                                          settingsBox,
                                        )
                                      : importResso(
                                          cntxt,
                                          playlistNames,
                                          settingsBox,
                                        );
                    },
                  );
                },
              ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}

Future<void> importFile(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  await importFilePlaylist(context, playlistNames);
}

Future<void> connectToSpotify(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  final String? accessToken = await retriveAccessToken();

  if (accessToken == null) {
    launchUrl(
      Uri.parse(
        SpotifyApi().requestAuthorization(),
      ),
      mode: LaunchMode.externalApplication,
    );
    AppLinks(
      onAppLink: (Uri uri, String link) async {
        closeInAppWebView();
        if (link.contains('code=')) {
          final code = link.split('code=')[1];
          settingsBox.put('spotifyAppCode', code);
          final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
          final List<String> data =
              await SpotifyApi().getAccessToken(code: code);
          if (data.isNotEmpty) {
            settingsBox.put('spotifyAccessToken', data[0]);
            settingsBox.put('spotifyRefreshToken', data[1]);
            settingsBox.put(
              'spotifyTokenExpireAt',
              currentTime + int.parse(data[2]),
            );
            await fetchPlaylists(
              data[0],
              context,
              playlistNames,
              settingsBox,
            );
          }
        }
      },
    );
  } else {
    await fetchPlaylists(
      accessToken,
      context,
      playlistNames,
      settingsBox,
    );
  }
}

Future<void> importYt(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  await showTextInputDialog(
    context: context,
    title: AppLocalizations.of(context)!.enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (value) async {
      final String link = value.trim();
      Navigator.pop(context);
      final Map data = await SearchAddPlaylist.addYtPlaylist(link);
      if (data.isNotEmpty) {
        if (data['title'] == '' && data['count'] == 0) {
          Logger.root.severe(
            'Failed to import YT playlist. Data not empty but title or the count is empty.',
          );
          ShowSnackBar().showSnackBar(
            context,
            '${AppLocalizations.of(context)!.failedImport}\n${AppLocalizations.of(context)!.confirmViewable}',
            duration: const Duration(seconds: 3),
          );
        } else {
          playlistNames.add(
            data['title'] == '' ? 'Yt Playlist' : data['title'],
          );
          settingsBox.put(
            'playlistNames',
            playlistNames,
          );

          await SearchAddPlaylist.showProgress(
            data['count'] as int,
            context,
            SearchAddPlaylist.ytSongsAdder(
              data['title'].toString(),
              data['tracks'] as List,
            ),
          );
        }
      } else {
        Logger.root.severe(
          'Failed to import YT playlist. Data is empty.',
        );
        ShowSnackBar().showSnackBar(
          context,
          AppLocalizations.of(context)!.failedImport,
        );
      }
    },
  );
}

Future<void> importResso(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  await showTextInputDialog(
    context: context,
    title: AppLocalizations.of(context)!.enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (value) async {
      final String link = value.trim();
      Navigator.pop(context);
      final Map data = await SearchAddPlaylist.addRessoPlaylist(link);
      if (data.isNotEmpty) {
        String playName = data['title'].toString();
        while (playlistNames.contains(playName) ||
            await Hive.boxExists(playName)) {
          // ignore: use_string_buffers
          playName = '$playName (1)';
        }
        playlistNames.add(playName);
        settingsBox.put(
          'playlistNames',
          playlistNames,
        );

        await SearchAddPlaylist.showProgress(
          data['count'] as int,
          context,
          SearchAddPlaylist.ressoSongsAdder(
            playName,
            data['tracks'] as List,
          ),
        );
      } else {
        Logger.root.severe(
          'Failed to import Resso playlist. Data is empty.',
        );
        ShowSnackBar().showSnackBar(
          context,
          AppLocalizations.of(context)!.failedImport,
        );
      }
    },
  );
}

Future<void> importSpotify(
  BuildContext context,
  String accessToken,
  String playlistId,
  String playlistName,
  Box settingsBox,
  List playlistNames,
) async {
  final Map data = await SearchAddPlaylist.addSpotifyPlaylist(
    playlistName,
    accessToken,
    playlistId,
  );
  if (data.isNotEmpty) {
    String playName = data['title'].toString();
    while (playlistNames.contains(playName) || await Hive.boxExists(playName)) {
      // ignore: use_string_buffers
      playName = '$playName (1)';
    }
    playlistNames.add(playName);
    settingsBox.put(
      'playlistNames',
      playlistNames,
    );

    await SearchAddPlaylist.showProgress(
      data['count'] as int,
      context,
      SearchAddPlaylist.spotifySongsAdder(
        playName,
        data['tracks'] as List,
      ),
    );
  } else {
    Logger.root.severe(
      'Failed to import Spotify playlist. Data is empty.',
    );
    ShowSnackBar().showSnackBar(
      context,
      AppLocalizations.of(context)!.failedImport,
    );
  }
}

Future<void> importSpotifyViaLink(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
  String accessToken,
) async {
  await showTextInputDialog(
    context: context,
    title: AppLocalizations.of(context)!.enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (String value) async {
      Navigator.pop(context);
      final String playlistId = value.split('?')[0].split('/').last;
      final playlistName = AppLocalizations.of(context)!.spotifyPublic;
      await importSpotify(
        context,
        accessToken,
        playlistId,
        playlistName,
        settingsBox,
        playlistNames,
      );
    },
  );
}

Future<void> importJioSaavn(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  await showTextInputDialog(
    context: context,
    title: AppLocalizations.of(context)!.enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (value) async {
      final String link = value.trim();
      Navigator.pop(context);
      final Map data = await SearchAddPlaylist.addJioSaavnPlaylist(
        link,
      );

      if (data.isNotEmpty) {
        final String playName = data['title'].toString();
        addPlaylist(playName, data['tracks'] as List);
        playlistNames.add(playName);
      } else {
        Logger.root.severe('Failed to import JioSaavn playlist. data is empty');
        ShowSnackBar().showSnackBar(
          context,
          AppLocalizations.of(context)!.failedImport,
        );
      }
    },
  );
}

Future<void> fetchPlaylists(
  String accessToken,
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  final List spotifyPlaylists =
      await SpotifyApi().getUserPlaylists(accessToken);
  showModalBottomSheet(
    isDismissible: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (BuildContext contxt) {
      return BottomGradientContainer(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          itemCount: spotifyPlaylists.length + 1,
          itemBuilder: (ctxt, idx) {
            if (idx == 0) {
              return ListTile(
                title: Text(
                  AppLocalizations.of(context)!.importPublicPlaylist,
                ),
                leading: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: Colors.transparent,
                  child: SizedBox.square(
                    dimension: 50,
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  await importSpotifyViaLink(
                    context,
                    playlistNames,
                    settingsBox,
                    accessToken,
                  );
                  Navigator.pop(context);
                },
              );
            }

            final String playName = spotifyPlaylists[idx - 1]['name']
                .toString()
                .replaceAll('/', ' ');
            final int playTotal =
                spotifyPlaylists[idx - 1]['tracks']['total'] as int;
            return playTotal == 0
                ? const SizedBox()
                : ListTile(
                    title: Text(playName),
                    subtitle: Text(
                      playTotal == 1
                          ? '$playTotal ${AppLocalizations.of(context)!.song}'
                          : '$playTotal ${AppLocalizations.of(context)!.songs}',
                    ),
                    leading: Card(
                      margin: EdgeInsets.zero,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          (spotifyPlaylists[idx - 1]['images'] as List).isEmpty
                              ? Image.asset('assets/cover.jpg')
                              : CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  errorWidget: (context, _, __) => const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/cover.jpg'),
                                  ),
                                  imageUrl:
                                      '${spotifyPlaylists[idx - 1]["images"][0]['url'].replaceAll('http:', 'https:')}',
                                  placeholder: (context, url) => const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/cover.jpg'),
                                  ),
                                ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final String playName = spotifyPlaylists[idx - 1]['name']
                          .toString()
                          .replaceAll('/', ' ');
                      final String playlistId =
                          spotifyPlaylists[idx - 1]['id'].toString();

                      importSpotify(
                        context,
                        accessToken,
                        playlistId,
                        playName,
                        settingsBox,
                        playlistNames,
                      );
                    },
                  );
          },
        ),
      );
    },
  );
  return;
}
