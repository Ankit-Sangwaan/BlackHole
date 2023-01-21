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

import 'package:blackhole/CustomWidgets/empty_screen.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/miniplayer.dart';
import 'package:blackhole/CustomWidgets/search_bar.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:blackhole/Screens/YouTube/youtube_playlist.dart';
import 'package:blackhole/Services/player_service.dart';
import 'package:blackhole/Services/youtube_services.dart';
import 'package:blackhole/Services/yt_music.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class YouTubeSearchPage extends StatefulWidget {
  final String query;
  const YouTubeSearchPage({super.key, required this.query});
  @override
  _YouTubeSearchPageState createState() => _YouTubeSearchPageState();
}

class _YouTubeSearchPageState extends State<YouTubeSearchPage> {
  String query = '';
  bool status = false;
  List<Map> searchedList = [];
  bool fetched = false;
  bool done = true;
  bool liveSearch =
      Hive.box('settings').get('liveSearch', defaultValue: true) as bool;
  List searchHistory =
      Hive.box('settings').get('search', defaultValue: []) as List;
  // List ytSearch =
  // Hive.box('settings').get('ytSearch', defaultValue: []) as List;
  // bool showHistory =
  // Hive.box('settings').get('showHistory', defaultValue: true) as bool;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.query;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool rotated =
        MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;
    double boxSize = !rotated
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    if (!status) {
      status = true;
      if (query.isEmpty && widget.query.isEmpty) {
        fetched = true;
      } else {
        YtMusicService()
            .search(query == '' ? widget.query : query)
            .then((value) {
          setState(() {
            searchedList = value;
            fetched = true;
          });
        });
      }
      // YouTubeServices()
      //     .fetchSearchResults(query == '' ? widget.query : query)
      //     .then((value) {
      //   setState(() {
      //     searchedList = value;
      //     fetched = true;
      //   });
      // });
    }
    return GradientContainer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: SearchBar(
                  isYt: true,
                  controller: _controller,
                  liveSearch: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  hintText: AppLocalizations.of(context)!.searchYt,
                  onQueryChanged: (changedQuery) {
                    return YouTubeServices()
                        .getSearchSuggestions(query: changedQuery);
                  },
                  onSubmitted: (submittedQuery) async {
                    setState(() {
                      fetched = false;
                      query = submittedQuery;
                      _controller.text = submittedQuery;
                      status = false;
                      searchedList = [];
                    });
                  },
                  body: (!fetched)
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : (query.isEmpty && widget.query.isEmpty)
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 70,
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                      children: List<Widget>.generate(
                                        searchHistory.length,
                                        (int index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0,
                                            ),
                                            child: GestureDetector(
                                              child: Chip(
                                                label: Text(
                                                  searchHistory[index]
                                                      .toString(),
                                                ),
                                                labelStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .color,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                onDeleted: () {
                                                  setState(() {
                                                    searchHistory
                                                        .removeAt(index);
                                                    Hive.box('settings').put(
                                                      'search',
                                                      searchHistory,
                                                    );
                                                  });
                                                },
                                              ),
                                              onTap: () {
                                                setState(
                                                  () {
                                                    fetched = false;
                                                    query = searchHistory[index]
                                                        .toString()
                                                        .trim();
                                                    status = false;
                                                  },
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : searchedList.isEmpty
                              ? emptyScreen(
                                  context,
                                  0,
                                  ':( ',
                                  100,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .sorry,
                                  60,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .resultsNotFound,
                                  20,
                                )
                              : Stack(
                                  children: [
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 60,
                                      ),
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        children: searchedList.map(
                                          (Map section) {
                                            final List underDevelopment = [
                                              'Artists',
                                              'Albums',
                                              'Top result'
                                            ];
                                            if (section['items'] == null ||
                                                underDevelopment.contains(
                                                  section['title'],
                                                )) {
                                              return const SizedBox();
                                            }
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 15,
                                                    top: 20,
                                                    bottom: 5,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        section['title']
                                                            .toString(),
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                      //   if (section['title'] !=
                                                      //       'Top Result')
                                                      //     Row(
                                                      //       mainAxisAlignment:
                                                      //           MainAxisAlignment
                                                      //               .end,
                                                      //       children: [
                                                      //         GestureDetector(
                                                      //           onTap: () {},
                                                      //           child: Row(
                                                      //             children: [
                                                      //               Text(
                                                      //                 AppLocalizations
                                                      //                         .of(
                                                      //                   context,
                                                      //                 )!
                                                      //                     .viewAll,
                                                      //                 style:
                                                      //                     TextStyle(
                                                      //                   color: Theme
                                                      //                           .of(
                                                      //                     context,
                                                      //                   )
                                                      //                       .textTheme
                                                      //                       .caption!
                                                      //                       .color,
                                                      //                   fontWeight:
                                                      //                       FontWeight
                                                      //                           .w800,
                                                      //                 ),
                                                      //               ),
                                                      //               Icon(
                                                      //                 Icons
                                                      //                     .chevron_right_rounded,
                                                      //                 color: Theme
                                                      //                         .of(
                                                      //                   context,
                                                      //                 )
                                                      //                     .textTheme
                                                      //                     .caption!
                                                      //                     .color,
                                                      //               ),
                                                      //             ],
                                                      //           ),
                                                      //         ),
                                                      //       ],
                                                      //     ),
                                                    ],
                                                  ),
                                                ),
                                                ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      (section['items'] as List)
                                                          .length,
                                                  itemBuilder: (context, idx) {
                                                    final itemType =
                                                        section['items'][idx]
                                                                ['type']
                                                            .toString();
                                                    return ListTile(
                                                      title: Text(
                                                        section['items'][idx]
                                                                ['title']
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        section['items'][idx]
                                                                ['subtitle']
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                        left: 15.0,
                                                      ),
                                                      leading: Card(
                                                        margin: EdgeInsets.zero,
                                                        elevation: 8,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            itemType == 'Artist'
                                                                ? 50.0
                                                                : 7.0,
                                                          ),
                                                        ),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        child:
                                                            CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          errorWidget: (
                                                            context,
                                                            _,
                                                            __,
                                                          ) =>
                                                              const Image(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                              'assets/cover.jpg',
                                                            ),
                                                          ),
                                                          imageUrl:
                                                              section['items']
                                                                          [idx]
                                                                      ['image']
                                                                  .toString(),
                                                          placeholder:
                                                              (context, url) =>
                                                                  const Image(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                              'assets/cover.jpg',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      trailing: (itemType ==
                                                                  'Song' ||
                                                              itemType ==
                                                                  'Video')
                                                          ? YtSongTileTrailingMenu(
                                                              data: section[
                                                                      'items']
                                                                  [idx] as Map,
                                                            )
                                                          : null,
                                                      onTap: () async {
                                                        if (itemType ==
                                                            'Artist') {
                                                          // under Development
                                                          // YtMusicService()
                                                          //     .getArtistDetails(
                                                          //   section['items']
                                                          //           [idx]['id']
                                                          //       .toString(),
                                                          // );
                                                        }
                                                        if (itemType ==
                                                            'Playlist') {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  YouTubePlaylist(
                                                                playlistId: section[
                                                                            'items']
                                                                        [
                                                                        idx]['id']
                                                                    .toString(),
                                                                playlistName: section['items']
                                                                            [
                                                                            idx]
                                                                        [
                                                                        'title']
                                                                    .toString(),
                                                                playlistSubtitle:
                                                                    section['items'][idx]
                                                                            [
                                                                            'countSongs']
                                                                        .toString(),
                                                                playlistSecondarySubtitle:
                                                                    section['items'][idx]
                                                                            [
                                                                            'subtitle']
                                                                        .toString(),
                                                                playlistImage: (section['items'][idx]
                                                                            [
                                                                            'images']
                                                                        as List)
                                                                    .last
                                                                    .toString(),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        if (itemType ==
                                                                'Song' ||
                                                            itemType ==
                                                                'Video') {
                                                          setState(() {
                                                            done = false;
                                                          });
                                                          final Map? response =
                                                              await YouTubeServices()
                                                                  .formatVideoFromId(
                                                            id: section['items']
                                                                    [idx]['id']
                                                                .toString(),
                                                            data:
                                                                section['items']
                                                                        [idx]
                                                                    as Map,
                                                          );
                                                          if (itemType ==
                                                              'Song') {
                                                            final Map
                                                                response2 =
                                                                await YtMusicService()
                                                                    .getSongData(
                                                              videoId: section[
                                                                          'items']
                                                                      [
                                                                      idx]['id']
                                                                  .toString(),
                                                            );
                                                            if (response !=
                                                                    null &&
                                                                response2[
                                                                        'image'] !=
                                                                    null) {
                                                              response[
                                                                  'image'] = response2[
                                                                      'image'] ??
                                                                  response[
                                                                      'image'];
                                                            }
                                                          }
                                                          setState(() {
                                                            done = true;
                                                          });
                                                          if (response !=
                                                              null) {
                                                            PlayerInvoke.init(
                                                              songsList: [
                                                                response
                                                              ],
                                                              index: 0,
                                                              isOffline: false,
                                                              recommend: false,
                                                            );
                                                          }
                                                          response == null
                                                              ? ShowSnackBar()
                                                                  .showSnackBar(
                                                                  context,
                                                                  AppLocalizations
                                                                          .of(
                                                                    context,
                                                                  )!
                                                                      .ytLiveAlert,
                                                                )
                                                              : Navigator
                                                                  .pushNamed(
                                                                  context,
                                                                  '/player',
                                                                );
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                    if (!done)
                                      Center(
                                        child: SizedBox.square(
                                          dimension: boxSize,
                                          child: Card(
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: GradientContainer(
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                      ),
                                                      strokeWidth: 5,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!
                                                          .fetchingStream,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                ),
              ),
            ),
            MiniPlayer(),
          ],
        ),
      ),
    );
  }
}
