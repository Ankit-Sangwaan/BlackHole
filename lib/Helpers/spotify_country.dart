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

import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/Screens/Top Charts/top.dart' as top_screen;
import 'package:blackhole/constants/countrycodes.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SpotifyCountry {
  Future<String> changeCountry({required BuildContext context}) async {
    String region =
        Hive.box('settings').get('region', defaultValue: 'India') as String;
    if (!CountryCodes.localChartCodes.containsKey(region)) {
      region = 'India';
    }

    await showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        const Map<String, String> codes = CountryCodes.localChartCodes;
        final List<String> countries = codes.keys.toList();
        return BottomGradientContainer(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              0,
              10,
              0,
              10,
            ),
            itemCount: countries.length,
            itemBuilder: (context, idx) {
              return ListTileTheme(
                selectedColor: Theme.of(context).colorScheme.secondary,
                child: ListTile(
                  title: Text(
                    countries[idx],
                  ),
                  leading: Radio(
                    value: countries[idx],
                    groupValue: region,
                    onChanged: (value) {
                      top_screen.localSongs = [];
                      region = countries[idx];
                      top_screen.localFetched = false;
                      top_screen.localFetchFinished.value = false;
                      Hive.box('settings').put('region', region);
                      Navigator.pop(context);
                    },
                  ),
                  selected: region == countries[idx],
                  onTap: () {
                    top_screen.localSongs = [];
                    region = countries[idx];
                    top_screen.localFetchFinished.value = false;
                    Hive.box('settings').put('region', region);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        );
      },
    );
    return region;
  }
}
