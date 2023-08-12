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
 * Copyright (c) 2021-2023, Ankit Sangwan
 */

import 'package:blackhole/APIs/api.dart';
import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:blackhole/CustomWidgets/download_button.dart';
import 'package:blackhole/CustomWidgets/empty_screen.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/image_card.dart';
import 'package:blackhole/CustomWidgets/like_button.dart';
import 'package:blackhole/CustomWidgets/search_bar.dart' as searchbar;
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:blackhole/Screens/Common/song_list.dart';
import 'package:blackhole/Screens/Search/albums.dart';
import 'package:blackhole/Screens/Search/artists.dart';
import 'package:blackhole/Services/player_service.dart';
import 'package:blackhole/Services/youtube_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class SearchPage extends StatefulWidget {
  final String query;
  final bool fromHome;
  final String? searchType;
  final bool autofocus;
  const SearchPage({
    super.key,
    required this.query,
    this.fromHome = false,
    this.searchType,
    this.autofocus = false,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  bool fetchResultCalled = false;
  bool fetched = false;
  bool alertShown = false;
  // bool albumFetched = false;
  bool? fromHome;
  List<Map<String, dynamic>> searchedList = [];
  String searchType =
      Hive.box('settings').get('searchType', defaultValue: 'saavn').toString();
  List searchHistory =
      Hive.box('settings').get('search', defaultValue: []) as List;
  // bool showHistory =
  //     Hive.box('settings').get('showHistory', defaultValue: true) as bool;
  bool liveSearch =
      Hive.box('settings').get('liveSearch', defaultValue: true) as bool;
  final ValueNotifier<List<String>> topSearch = ValueNotifier<List<String>>(
    [],
  );

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.query;
    if (widget.searchType != null) {
      searchType = widget.searchType!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchResults() async {
    // this fetches songs, albums, playlists, artists, etc
    searchedList =
        await SaavnAPI().fetchSearchResults(query == '' ? widget.query : query);
    setState(() {
      fetched = true;
    });
  }

  Future<void> getTrendingSearch() async {
    topSearch.value = await SaavnAPI().getTopSearches();
  }

  void addToHistory(String title) {
    final tempquery = title.trim();
    if (tempquery == '') {
      return;
    }
    final idx = searchHistory.indexOf(tempquery);
    if (idx != -1) {
      searchHistory.removeAt(idx);
    }
    searchHistory.insert(
      0,
      tempquery,
    );
    if (searchHistory.length > 10) {
      searchHistory = searchHistory.sublist(0, 10);
    }
    Hive.box('settings').put(
      'search',
      searchHistory,
    );
  }

  Widget nothingFound(BuildContext context) {
    if (!alertShown) {
      ShowSnackBar().showSnackBar(
        context,
        AppLocalizations.of(context)!.useVpn,
        duration: const Duration(seconds: 7),
        action: SnackBarAction(
          textColor: Theme.of(context).colorScheme.secondary,
          label: AppLocalizations.of(context)!.useProxy,
          onPressed: () {
            setState(() {
              Hive.box('settings').put('useProxy', true);
              fetched = false;
              fetchResultCalled = false;
              searchedList = [];
            });
          },
        ),
      );
      alertShown = true;
    }
    return emptyScreen(
      context,
      0,
      ':( ',
      100,
      AppLocalizations.of(context)!.sorry,
      60,
      AppLocalizations.of(context)!.resultsNotFound,
      20,
    );
  }

  @override
  Widget build(BuildContext context) {
    fromHome ??= widget.fromHome;
    if (!fetchResultCalled) {
      fetchResultCalled = true;
      fromHome! ? getTrendingSearch() : fetchResults();
    }
    return GradientContainer(
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: searchbar.SearchBar(
            isYt: false,
            controller: _controller,
            liveSearch: true,
            autofocus: widget.autofocus,
            hintText: AppLocalizations.of(context)!.searchText,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (fromHome ?? false) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    fromHome = true;
                  });
                }
              },
            ),
            body: (fromHome!)
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10.0,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 100,
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
                                        searchHistory[index].toString(),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          searchHistory.removeAt(index);
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
                                          query = searchHistory
                                              .removeAt(index)
                                              .toString()
                                              .trim();
                                          addToHistory(query);
                                          _controller.text = query;
                                          _controller.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                              offset: query.length,
                                            ),
                                          );
                                          fetchResultCalled = false;
                                          fromHome = false;
                                          searchedList = [];
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: topSearch,
                          builder: (
                            BuildContext context,
                            List<String> value,
                            Widget? child,
                          ) {
                            if (value.isEmpty) return const SizedBox();
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .trendingSearch,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Wrap(
                                    children: List<Widget>.generate(
                                      value.length,
                                      (int index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0,
                                          ),
                                          child: ChoiceChip(
                                            label: Text(value[index]),
                                            selectedColor: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.2),
                                            labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            selected: false,
                                            onSelected: (bool selected) {
                                              if (selected) {
                                                setState(
                                                  () {
                                                    fetched = false;
                                                    query = value[index].trim();
                                                    _controller.text = query;
                                                    _controller.selection =
                                                        TextSelection
                                                            .fromPosition(
                                                      TextPosition(
                                                        offset: query.length,
                                                      ),
                                                    );
                                                    fetchResultCalled = false;
                                                    fromHome = false;
                                                    searchedList = [];
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 70,
                          left: 20,
                        ),
                        child: (query.isEmpty && widget.query.isEmpty)
                            ? null
                            : Row(
                                children: getChoices(context, [
                                  {'label': 'Saavn', 'key': 'saavn'},
                                  {'label': 'YtMusic', 'key': 'ytm'},
                                  {'label': 'YouTube', 'key': 'yt'}
                                ]),
                              ),
                      ),
                      Expanded(
                        child: !fetched
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : (searchedList.isEmpty)
                                ? nothingFound(context)
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0,
                                      vertical: 5.0,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: searchedList.map(
                                        (Map section) {
                                          final String key =
                                              section.keys.first.toString();
                                          final List? value =
                                              section.values.first as List?;

                                          if (value == null) {
                                            return const SizedBox();
                                          }
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 25,
                                                  top: 10,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      key,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    if (key != 'Top Result')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                          25,
                                                          0,
                                                          25,
                                                          0,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (key == 'Albums' ||
                                                                    key ==
                                                                        'Playlists' ||
                                                                    key ==
                                                                        'Artists') {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    PageRouteBuilder(
                                                                      opaque:
                                                                          false,
                                                                      pageBuilder: (
                                                                        _,
                                                                        __,
                                                                        ___,
                                                                      ) =>
                                                                          AlbumSearchPage(
                                                                        query: query ==
                                                                                ''
                                                                            ? widget.query
                                                                            : query,
                                                                        type:
                                                                            key,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                if (key ==
                                                                    'Songs') {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    PageRouteBuilder(
                                                                      opaque:
                                                                          false,
                                                                      pageBuilder: (
                                                                        _,
                                                                        __,
                                                                        ___,
                                                                      ) =>
                                                                          SongsListPage(
                                                                        listItem: {
                                                                          'id': query == ''
                                                                              ? widget.query
                                                                              : query,
                                                                          'title':
                                                                              key,
                                                                          'type':
                                                                              'songs',
                                                                        },
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    AppLocalizations
                                                                            .of(
                                                                      context,
                                                                    )!
                                                                        .viewAll,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Theme
                                                                              .of(
                                                                        context,
                                                                      )
                                                                          .textTheme
                                                                          .bodySmall!
                                                                          .color,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .chevron_right_rounded,
                                                                    color: Theme
                                                                            .of(
                                                                      context,
                                                                    )
                                                                        .textTheme
                                                                        .bodySmall!
                                                                        .color,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              ListView.builder(
                                                itemCount: value.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                padding: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 10,
                                                ),
                                                itemBuilder: (context, index) {
                                                  final int count = value[index]
                                                          ['count'] as int? ??
                                                      0;
                                                  String countText =
                                                      value[index]['artist']
                                                          .toString();
                                                  count > 1
                                                      ? countText =
                                                          '$count ${AppLocalizations.of(context)!.songs}'
                                                      : countText =
                                                          '$count ${AppLocalizations.of(context)!.song}';
                                                  return ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                      left: 15.0,
                                                    ),
                                                    title: Text(
                                                      '${value[index]["title"]}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    subtitle: Text(
                                                      key == 'Albums' ||
                                                              (key == 'Top Result' &&
                                                                  value[0][
                                                                          'type'] ==
                                                                      'album')
                                                          ? '$countText\n${value[index]["subtitle"]}'
                                                          : '${value[index]["subtitle"]}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    isThreeLine: key ==
                                                            'Albums' ||
                                                        (key == 'Top Result' &&
                                                            value[0]['type'] ==
                                                                'album'),
                                                    leading: imageCard(
                                                      borderRadius: key ==
                                                                  'Artists' ||
                                                              (key == 'Top Result' &&
                                                                  value[0][
                                                                          'type'] ==
                                                                      'artist')
                                                          ? 50.0
                                                          : 7.0,
                                                      placeholderImage:
                                                          AssetImage(
                                                        key == 'Artists' ||
                                                                (key == 'Top Result' &&
                                                                    value[0][
                                                                            'type'] ==
                                                                        'artist')
                                                            ? 'assets/artist.png'
                                                            : key == 'Songs'
                                                                ? 'assets/cover.jpg'
                                                                : 'assets/album.png',
                                                      ),
                                                      imageUrl: value[index]
                                                              ['image']
                                                          .toString(),
                                                    ),
                                                    trailing: key != 'Albums'
                                                        ? key == 'Songs'
                                                            ? Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  DownloadButton(
                                                                    data: value[
                                                                            index]
                                                                        as Map,
                                                                    icon:
                                                                        'download',
                                                                  ),
                                                                  LikeButton(
                                                                    mediaItem:
                                                                        null,
                                                                    data: value[
                                                                            index]
                                                                        as Map,
                                                                  ),
                                                                  SongTileTrailingMenu(
                                                                    data: value[
                                                                            index]
                                                                        as Map,
                                                                  ),
                                                                ],
                                                              )
                                                            : null
                                                        : AlbumDownloadButton(
                                                            albumName: value[
                                                                        index]
                                                                    ['title']
                                                                .toString(),
                                                            albumId:
                                                                value[index]
                                                                        ['id']
                                                                    .toString(),
                                                          ),
                                                    onLongPress: () {
                                                      copyToClipboard(
                                                        context: context,
                                                        text:
                                                            '${value[index]["title"]}',
                                                      );
                                                    },
                                                    onTap: () {
                                                      if (key == 'Songs') {
                                                        PlayerInvoke.init(
                                                          songsList: [
                                                            value[index]
                                                          ],
                                                          index: 0,
                                                          isOffline: false,
                                                        );
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            opaque: false,
                                                            pageBuilder: (
                                                              _,
                                                              __,
                                                              ___,
                                                            ) =>
                                                                key == 'Artists' ||
                                                                        (key == 'Top Result' &&
                                                                            value[0]['type'] ==
                                                                                'artist')
                                                                    ? ArtistSearchPage(
                                                                        data: value[index]
                                                                            as Map,
                                                                      )
                                                                    : SongsListPage(
                                                                        listItem:
                                                                            value[index]
                                                                                as Map,
                                                                      ),
                                                          ),
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
                      ),
                    ],
                  ),
            onSubmitted: (String submittedQuery) {
              setState(
                () {
                  fetched = false;
                  fromHome = false;
                  fetchResultCalled = false;
                  query = submittedQuery;
                  _controller.text = submittedQuery;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(
                      offset: query.length,
                    ),
                  );
                  searchedList = [];
                },
              );
            },
            onQueryChanged: (changedQuery) {
              return YouTubeServices()
                  .getSearchSuggestions(query: changedQuery);
            },
          ),
        ),
      ),
    );
  }

  List<Widget> getChoices(
    BuildContext context,
    List<Map<String, String>> choices,
  ) {
    return choices.map((Map<String, String> element) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ChoiceChip(
          label: Text(element['label']!),
          selectedColor:
              Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: searchType == element['key']
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: searchType == element['key']
                ? FontWeight.w600
                : FontWeight.normal,
          ),
          selected: searchType == element['key'],
          onSelected: (bool selected) {
            if (selected) {
              searchType = element['key']!;
              fetched = false;
              fetchResultCalled = false;
              Hive.box('settings').put('searchType', element['key']);
              setState(() {});
            }
          },
        ),
      );
    }).toList();
  }
}
