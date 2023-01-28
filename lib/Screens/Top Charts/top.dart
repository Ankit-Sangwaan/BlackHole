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
import 'package:blackhole/CustomWidgets/custom_physics.dart';
import 'package:blackhole/CustomWidgets/empty_screen.dart';
import 'package:blackhole/Helpers/countrycodes.dart';
import 'package:blackhole/Helpers/spotify_helper.dart';
// import 'package:blackhole/Helpers/countrycodes.dart';
import 'package:blackhole/Screens/Search/search.dart';
import 'package:blackhole/Screens/Settings/setting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

List localSongs = [];
List globalSongs = [];
bool localFetched = false;
bool globalFetched = false;
final ValueNotifier<bool> localFetchFinished = ValueNotifier<bool>(false);
final ValueNotifier<bool> globalFetchFinished = ValueNotifier<bool>(false);

class TopCharts extends StatefulWidget {
  final PageController pageController;
  const TopCharts({super.key, required this.pageController});

  @override
  _TopChartsState createState() => _TopChartsState();
}

class _TopChartsState extends State<TopCharts>
    with AutomaticKeepAliveClientMixin<TopCharts> {
  final ValueNotifier<bool> localFetchFinished = ValueNotifier<bool>(false);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext cntxt) {
    super.build(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.my_location_rounded),
                onPressed: () async {
                  await SpotifyCountry().changeCountry(context: context);
                },
              ),
            ),
          ],
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                child: Text(
                  AppLocalizations.of(context)!.local,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  AppLocalizations.of(context)!.global,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            AppLocalizations.of(context)!.spotifyCharts,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: (rotated && screenWidth < 1050)
              ? null
              : Builder(
                  builder: (BuildContext context) {
                    return Transform.rotate(
                      angle: 22 / 7 * 2,
                      child: IconButton(
                        color: Theme.of(context).iconTheme.color,
                        icon: const Icon(
                          Icons.horizontal_split_rounded,
                        ),
                        onPressed: () {
                          Scaffold.of(cntxt).openDrawer();
                        },
                        tooltip: MaterialLocalizations.of(cntxt)
                            .openAppDrawerTooltip,
                      ),
                    );
                  },
                ),
        ),
        body: NotificationListener(
          onNotification: (overscroll) {
            if (overscroll is OverscrollNotification &&
                overscroll.overscroll != 0 &&
                overscroll.dragDetails != null) {
              widget.pageController.animateToPage(
                overscroll.overscroll < 0 ? 0 : 2,
                curve: Curves.ease,
                duration: const Duration(milliseconds: 150),
              );
            }
            return true;
          },
          child: TabBarView(
            physics: const CustomPhysics(),
            children: [
              ValueListenableBuilder(
                valueListenable: Hive.box('settings').listenable(),
                builder: (BuildContext context, Box box, Widget? widget) {
                  return TopPage(
                    type: box.get('region', defaultValue: 'India').toString(),
                  );
                },
              ),
              // TopPage(type: 'local'),
              const TopPage(type: 'Global'),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List> getChartDetails(String accessToken, String type) async {
  final String globalPlaylistId = ConstantCodes.localChartCodes['Global']!;
  final String localPlaylistId = ConstantCodes.localChartCodes.containsKey(type)
      ? ConstantCodes.localChartCodes[type]!
      : ConstantCodes.localChartCodes['India']!;
  final String playlistId =
      type == 'Global' ? globalPlaylistId : localPlaylistId;
  final List data = [];
  final List tracks =
      await SpotifyApi().getAllTracksOfPlaylist(accessToken, playlistId);
  for (final track in tracks) {
    final trackName = track['track']['name'];
    final imageUrlSmall = track['track']['album']['images'].last['url'];
    final imageUrlBig = track['track']['album']['images'].first['url'];
    final spotifyUrl = track['track']['external_urls']['spotify'];
    final artistName = track['track']['artists'][0]['name'].toString();
    data.add({
      'name': trackName,
      'artist': artistName,
      'image_url_small': imageUrlSmall,
      'image_url_big': imageUrlBig,
      'spotifyUrl': spotifyUrl,
    });
  }
  return data;
}

Future<void> scrapData(String type, {bool signIn = false}) async {
  final bool spotifySigned =
      Hive.box('settings').get('spotifySigned', defaultValue: false) as bool;

  if (!spotifySigned && !signIn) {
    return;
  }
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
          Hive.box('settings').put('spotifyAppCode', code);
          final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
          final List<String> data =
              await SpotifyApi().getAccessToken(code: code);
          if (data.isNotEmpty) {
            Hive.box('settings').put('spotifyAccessToken', data[0]);
            Hive.box('settings').put('spotifyRefreshToken', data[1]);
            Hive.box('settings').put('spotifySigned', true);
            Hive.box('settings')
                .put('spotifyTokenExpireAt', currentTime + int.parse(data[2]));
          }

          final temp = await getChartDetails(data[0], type);
          if (temp.isNotEmpty) {
            Hive.box('cache').put('${type}_chart', temp);
            if (type == 'Global') {
              globalSongs = temp;
            } else {
              localSongs = temp;
            }
          }
          if (type == 'Global') {
            globalFetchFinished.value = true;
          } else {
            localFetchFinished.value = true;
          }
        }
      },
    );
  } else {
    final temp = await getChartDetails(accessToken, type);
    if (temp.isNotEmpty) {
      Hive.box('cache').put('${type}_chart', temp);
      if (type == 'Global') {
        globalSongs = temp;
      } else {
        localSongs = temp;
      }
    }
    if (type == 'Global') {
      globalFetchFinished.value = true;
    } else {
      localFetchFinished.value = true;
    }
  }
}

class TopPage extends StatefulWidget {
  final String type;
  const TopPage({super.key, required this.type});
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage>
    with AutomaticKeepAliveClientMixin<TopPage> {
  Future<void> getCachedData(String type) async {
    if (type == 'Global') {
      globalFetched = true;
    } else {
      localFetched = true;
    }
    if (type == 'Global') {
      globalSongs = await Hive.box('cache')
          .get('${type}_chart', defaultValue: []) as List;
    } else {
      localSongs = await Hive.box('cache')
          .get('${type}_chart', defaultValue: []) as List;
    }
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getCachedData(widget.type);
    scrapData(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isGlobal = widget.type == 'Global';
    if ((isGlobal && !globalFetched) || (!isGlobal && !localFetched)) {
      getCachedData(widget.type);
      scrapData(widget.type);
    }
    return ValueListenableBuilder(
      valueListenable: isGlobal ? globalFetchFinished : localFetchFinished,
      builder: (BuildContext context, bool value, Widget? child) {
        final List showList = isGlobal ? globalSongs : localSongs;
        return Column(
          children: [
            if (!(Hive.box('settings').get('spotifySigned', defaultValue: false)
                as bool))
              Expanded(
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      scrapData(widget.type, signIn: true);
                    },
                    child: Text(AppLocalizations.of(context)!.signInSpotify),
                  ),
                ),
              )
            else if (showList.isEmpty)
              Expanded(
                child: value
                    ? emptyScreen(
                        context,
                        0,
                        ':( ',
                        100,
                        'ERROR',
                        60,
                        'Service Unavailable',
                        20,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                        ],
                      ),
              )
            else
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: showList.length,
                  itemExtent: 70.0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Card(
                        margin: EdgeInsets.zero,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            const Image(
                              image: AssetImage('assets/cover.jpg'),
                            ),
                            if (showList[index]['image_url_small'] != '')
                              CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: showList[index]['image_url_small']
                                    .toString(),
                                errorWidget: (context, _, __) => const Image(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/cover.jpg'),
                                ),
                                placeholder: (context, url) => const Image(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/cover.jpg'),
                                ),
                              ),
                          ],
                        ),
                      ),
                      title: Text(
                        '${index + 1}. ${showList[index]["name"]}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        showList[index]['artist'].toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        onSelected: (int? value) async {
                          if (value == 0) {
                            await launchUrl(
                              Uri.parse(
                                showList[index]['spotifyUrl'].toString(),
                              ),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Row(
                              children: [
                                const Icon(Icons.open_in_new_rounded),
                                const SizedBox(width: 10.0),
                                Text(
                                  AppLocalizations.of(context)!.openInSpotify,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchPage(
                              query: showList[index]['name'].toString(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
