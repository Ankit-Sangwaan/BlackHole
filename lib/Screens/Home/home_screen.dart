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

import 'dart:math';

import 'package:blackhole/CustomWidgets/drawer.dart';
import 'package:blackhole/CustomWidgets/textinput_dialog.dart';
import 'package:blackhole/Screens/Home/saavn.dart';
import 'package:blackhole/Screens/Search/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name =
        Hive.box('settings').get('name', defaultValue: 'Guest') as String;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool rotated = MediaQuery.sizeOf(context).height < screenWidth;
    return SafeArea(
      child: Stack(
        children: [
          NestedScrollView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxScrolled,
            ) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 135,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  // pinned: true,
                  toolbarHeight: 65,
                  // floating: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      return FlexibleSpaceBar(
                        // collapseMode: CollapseMode.parallax,
                        background: GestureDetector(
                          onTap: () async {
                            showTextInputDialog(
                              context: context,
                              title: 'Name',
                              initialText: name,
                              keyboardType: TextInputType.name,
                              onSubmitted:
                                  (String value, BuildContext context) {
                                Hive.box('settings').put(
                                  'name',
                                  value.trim(),
                                );
                                name = value.trim();
                                Navigator.pop(context);
                              },
                            );
                            // setState(() {});
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                height: 60,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 15.0,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .homeGreet,
                                      style: TextStyle(
                                        letterSpacing: 2,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: Hive.box(
                                        'settings',
                                      ).listenable(),
                                      builder: (
                                        BuildContext context,
                                        Box box,
                                        Widget? child,
                                      ) {
                                        return Text(
                                          (box.get('name') == null ||
                                                  box.get('name') == '')
                                              ? 'Guest'
                                              : box
                                                  .get(
                                                    'name',
                                                  )
                                                  .split(
                                                    ' ',
                                                  )[0]
                                                  .toString(),
                                          style: const TextStyle(
                                            letterSpacing: 2,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  stretch: true,
                  toolbarHeight: 65,
                  title: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedBuilder(
                      animation: _scrollController,
                      builder: (context, child) {
                        return GestureDetector(
                          child: AnimatedContainer(
                            width: (!_scrollController.hasClients ||
                                    _scrollController.positions.length > 1)
                                ? MediaQuery.sizeOf(context).width
                                : max(
                                    MediaQuery.sizeOf(context).width -
                                        _scrollController.offset
                                            .roundToDouble(),
                                    MediaQuery.sizeOf(context).width -
                                        (rotated ? 0 : 75),
                                  ),
                            height: 55.0,
                            duration: const Duration(
                              milliseconds: 150,
                            ),
                            padding: const EdgeInsets.all(2.0),
                            // margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                              color: Theme.of(context).cardColor,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5.0,
                                  offset: Offset(1.5, 1.5),
                                  // shadow direction: bottom right
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Icon(
                                  CupertinoIcons.search,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .searchText,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchPage(
                                query: '',
                                fromHome: true,
                                autofocus: true,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ];
            },
            body: SaavnHomePage(),
          ),
          if (!rotated)
            homeDrawer(
              context: context,
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            ),
        ],
      ),
    );
  }
}
