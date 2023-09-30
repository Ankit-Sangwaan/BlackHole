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

import 'package:blackhole/CustomWidgets/box_switch_tile.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/Helpers/backup_restore.dart';
import 'package:blackhole/Helpers/config.dart';
import 'package:blackhole/constants/countrycodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:sizer/sizer.dart';

class PrefScreen extends StatefulWidget {
  const PrefScreen({super.key});

  @override
  _PrefScreenState createState() => _PrefScreenState();
}

class _PrefScreenState extends State<PrefScreen> {
  List<String> languages = [
    'Hindi',
    'English',
    'Punjabi',
    'Tamil',
    'Telugu',
    'Marathi',
    'Gujarati',
    'Bengali',
    'Kannada',
    'Bhojpuri',
    'Malayalam',
    'Urdu',
    'Haryanvi',
    'Rajasthani',
    'Odia',
    'Assamese',
  ];
  List<bool> isSelected = [true, false];
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['Hindi'])?.toList() as List;
  String region =
      Hive.box('settings').get('region', defaultValue: 'India') as String;
  bool useProxy =
      Hive.box('settings').get('useProxy', defaultValue: false) as bool;

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: MediaQuery.sizeOf(context).width / 1.85,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).width,
                  child: const Image(
                    image: AssetImage(
                      'assets/icon-white-trans.png',
                    ),
                  ),
                ),
              ),
              const GradientContainer(
                child: null,
                opacity: true,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await restore(context);
                          GetIt.I<MyTheme>().refresh();
                          Navigator.popAndPushNamed(context, '/');
                        },
                        child: Text(
                          AppLocalizations.of(context)!.restore,
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.popAndPushNamed(context, '/');
                        },
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.1,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text:
                                      '${AppLocalizations.of(context)!.welcome}\n',
                                  style: TextStyle(
                                    fontSize: 46.sp,
                                    height: 1.0,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          AppLocalizations.of(context)!.aboard,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 52.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '!\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 54.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          AppLocalizations.of(context)!.prefReq,
                                      style: TextStyle(
                                        height: 1.5,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 5.0,
                                    ),
                                    title: Text(
                                      AppLocalizations.of(context)!.langQue,
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                        left: 10,
                                        right: 10,
                                      ),
                                      height: 57.0,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Colors.grey[900],
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 5.0,
                                            offset: Offset(0.0, 3.0),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          preferredLanguage.isEmpty
                                              ? 'None'
                                              : preferredLanguage.join(', '),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ),
                                    dense: true,
                                    onTap: () {
                                      showModalBottomSheet(
                                        isDismissible: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (BuildContext context) {
                                          final List checked =
                                              List.from(preferredLanguage);
                                          return StatefulBuilder(
                                            builder: (
                                              BuildContext context,
                                              StateSetter setStt,
                                            ) {
                                              return BottomGradientContainer(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  20.0,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: ListView.builder(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        shrinkWrap: true,
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                          0,
                                                          10,
                                                          0,
                                                          10,
                                                        ),
                                                        itemCount:
                                                            languages.length,
                                                        itemBuilder:
                                                            (context, idx) {
                                                          return CheckboxListTile(
                                                            activeColor:
                                                                Theme.of(
                                                              context,
                                                            )
                                                                    .colorScheme
                                                                    .secondary,
                                                            value: checked
                                                                .contains(
                                                              languages[idx],
                                                            ),
                                                            title: Text(
                                                              languages[idx],
                                                            ),
                                                            onChanged: (
                                                              bool? value,
                                                            ) {
                                                              value!
                                                                  ? checked.add(
                                                                      languages[
                                                                          idx],
                                                                    )
                                                                  : checked
                                                                      .remove(
                                                                      languages[
                                                                          idx],
                                                                    );
                                                              setStt(() {});
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Theme.of(
                                                              context,
                                                            )
                                                                    .colorScheme
                                                                    .secondary,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!
                                                                .cancel,
                                                          ),
                                                        ),
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Theme.of(
                                                              context,
                                                            )
                                                                    .colorScheme
                                                                    .secondary,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              preferredLanguage =
                                                                  checked;
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                              Hive.box(
                                                                'settings',
                                                              ).put(
                                                                'preferredLanguage',
                                                                checked,
                                                              );
                                                            });
                                                            if (preferredLanguage
                                                                .isEmpty) {
                                                              ShowSnackBar()
                                                                  .showSnackBar(
                                                                context,
                                                                AppLocalizations
                                                                        .of(
                                                                  context,
                                                                )!
                                                                    .noLangSelected,
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!
                                                                .ok,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 5.0,
                                    ),
                                    title: Text(
                                      AppLocalizations.of(context)!.countryQue,
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                        left: 10,
                                        right: 10,
                                      ),
                                      height: 57.0,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Colors.grey[900],
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 5.0,
                                            offset: Offset(0.0, 3.0),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          region,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ),
                                    dense: true,
                                    onTap: () {
                                      showModalBottomSheet(
                                        isDismissible: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (BuildContext context) {
                                          const Map<String, String> codes =
                                              CountryCodes.localChartCodes;
                                          final List<String> countries =
                                              codes.keys.toList();
                                          return BottomGradientContainer(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: ListView.builder(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                0,
                                                10,
                                                0,
                                                10,
                                              ),
                                              itemCount: countries.length,
                                              itemBuilder: (context, idx) {
                                                return ListTileTheme(
                                                  selectedColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                  child: ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                      left: 25.0,
                                                      right: 25.0,
                                                    ),
                                                    title: Text(
                                                      countries[idx],
                                                    ),
                                                    trailing: region ==
                                                            countries[idx]
                                                        ? const Icon(
                                                            Icons.check_rounded,
                                                          )
                                                        : const SizedBox(),
                                                    selected: region ==
                                                        countries[idx],
                                                    onTap: () {
                                                      region = countries[idx];
                                                      Hive.box('settings').put(
                                                        'region',
                                                        region,
                                                      );
                                                      Navigator.pop(
                                                        context,
                                                      );
                                                      if (region != 'India') {
                                                        ShowSnackBar()
                                                            .showSnackBar(
                                                          context,
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .useVpn,
                                                          duration:
                                                              const Duration(
                                                            seconds: 10,
                                                          ),
                                                          action:
                                                              SnackBarAction(
                                                            textColor: Theme.of(
                                                              context,
                                                            )
                                                                .colorScheme
                                                                .secondary,
                                                            label: AppLocalizations
                                                                    .of(context)!
                                                                .useProxy,
                                                            onPressed: () {
                                                              Hive.box(
                                                                'settings',
                                                              ).put(
                                                                'useProxy',
                                                                true,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      }
                                                      setState(() {});
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Visibility(
                                    visible: region != 'India',
                                    child: BoxSwitchTile(
                                      title: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!
                                            .useProxy,
                                      ),
                                      keyName: 'useProxy',
                                      defaultValue: false,
                                      contentPadding: EdgeInsets.zero,
                                      onChanged: ({
                                        required bool val,
                                        required Box box,
                                      }) {
                                        useProxy = val;
                                        setState(
                                          () {},
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.popAndPushNamed(
                                        context,
                                        '/',
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                      ),
                                      height: 55.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 5.0,
                                            offset: Offset(0.0, 3.0),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.finish,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
