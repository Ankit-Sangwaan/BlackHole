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

import 'dart:async';

import 'package:blackhole/CustomWidgets/bouncy_playlist_header_scroll_view.dart';
import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/image_card.dart';
import 'package:blackhole/Models/song_item.dart';
import 'package:blackhole/Models/url_image_generator.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class SongsListViewPage extends StatefulWidget {
  final String? imageUrl;
  final String? placeholderImageUrl;
  final String title;
  final String? subtitle;
  final String? secondarySubtitle;
  final Function(int, List)? onTap;
  final Function? onPlay;
  final Function? onShuffle;
  final String? listItemsTitle;
  final EdgeInsetsGeometry? listItemsPadding;
  final List<SongItem> listItems;
  final List<Widget>? actions;
  final List<Widget>? dropDownActions;
  final Future<List> Function()? loadFunction;
  final Future<List> Function()? loadMoreFunction;

  const SongsListViewPage({
    super.key,
    this.imageUrl,
    this.placeholderImageUrl,
    required this.title,
    this.subtitle,
    this.secondarySubtitle,
    this.onTap,
    this.onPlay,
    this.onShuffle,
    this.listItemsTitle,
    this.listItemsPadding,
    this.listItems = const [],
    this.actions,
    this.dropDownActions,
    this.loadFunction,
    this.loadMoreFunction,
  });

  @override
  _SongsListViewPageState createState() => _SongsListViewPageState();
}

class _SongsListViewPageState extends State<SongsListViewPage> {
  int page = 1;
  bool loading = false;
  List<SongItem> itemsList = [];
  bool fetched = false;
  bool isSharePopupShown = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    if (widget.loadMoreFunction != null) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent &&
            !loading) {
          page += 1;
          _loadMore();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _loadInitial() async {
    loading = true;
    try {
      if (widget.loadFunction == null) {
        setState(() {
          fetched = true;
          loading = false;
        });
      } else {
        final value = await widget.loadFunction!.call();
        setState(() {
          itemsList = value as List<SongItem>;
          fetched = true;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        fetched = true;
        loading = false;
      });
      Logger.root.severe(
        'Error in song_list_view loadInitial: $e',
      );
    }
  }

  Future<void> _loadMore() async {
    try {
      if (widget.loadMoreFunction != null) {
        loading = true;
        final value = await widget.loadMoreFunction!.call();
        setState(() {
          itemsList = value as List<SongItem>;
          fetched = true;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        fetched = true;
        loading = false;
      });
      Logger.root.severe(
        'Error in song_list_view loadMore: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: !fetched
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : BouncyPlaylistHeaderScrollView(
                scrollController: _scrollController,
                actions: widget.actions,
                title: widget.title,
                subtitle: widget.subtitle,
                secondarySubtitle: widget.secondarySubtitle,
                onPlayTap: widget.onPlay,
                onShuffleTap: widget.onShuffle,
                placeholderImage:
                    widget.placeholderImageUrl ?? 'assets/cover.jpg',
                imageUrl: UrlImageGetter([widget.imageUrl]).mediumQuality,
                sliverList: SliverList(
                  delegate: SliverChildListDelegate([
                    if (itemsList.isNotEmpty && widget.listItemsTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          top: 5.0,
                          bottom: 5.0,
                        ),
                        child: Text(
                          widget.listItemsTitle!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ...itemsList.map((entry) {
                      return ListTile(
                        contentPadding: widget.listItemsPadding ??
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        title: Text(
                          entry.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onLongPress: () {
                          copyToClipboard(
                            context: context,
                            text: entry.title,
                          );
                        },
                        subtitle: entry.subtitle != null
                            ? Text(
                                entry.subtitle!,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        leading: imageCard(
                          elevation: 8,
                          imageUrl: entry.image,
                        ),
                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     DownloadButton(
                        //       data: entry as Map,
                        //       icon: 'download',
                        //     ),
                        //     LikeButton(
                        //       mediaItem: null,
                        //       data: entry.mapData,
                        //     ),
                        //     if (entry.mapData != null)
                        //       SongTileTrailingMenu(data: entry.mapData!),
                        //   ],
                        // ),
                        onTap: () {
                          final idx = itemsList.indexWhere(
                            (element) => element == entry,
                          );
                          widget.onTap?.call(idx, itemsList);
                        },
                      );
                    }),
                  ]),
                ),
              ),
      ),
    );
  }
}
