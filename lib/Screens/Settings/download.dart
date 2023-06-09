import 'package:blackhole/CustomWidgets/box_switch_tile.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/Helpers/picker.dart';
import 'package:blackhole/Services/ext_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final Box settingsBox = Hive.box('settings');
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music') as String;
  String downloadQuality = Hive.box('settings')
      .get('downloadQuality', defaultValue: '320 kbps') as String;
  String ytDownloadQuality = Hive.box('settings')
      .get('ytDownloadQuality', defaultValue: 'High') as String;
  int downFilename =
      Hive.box('settings').get('downFilename', defaultValue: 0) as int;

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(
              context,
            )!
                .down,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .downQuality,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .downQualitySub,
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: downloadQuality,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(
                      () {
                        downloadQuality = newValue;
                        Hive.box('settings').put('downloadQuality', newValue);
                      },
                    );
                  }
                },
                items: <String>['96 kbps', '160 kbps', '320 kbps']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
              ),
              dense: true,
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .ytDownQuality,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .ytDownQualitySub,
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: ytDownloadQuality,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(
                      () {
                        ytDownloadQuality = newValue;
                        Hive.box('settings').put('ytDownloadQuality', newValue);
                      },
                    );
                  }
                },
                items: <String>['Low', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
              ),
              dense: true,
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .downLocation,
              ),
              subtitle: Text(downloadPath),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey[700],
                ),
                onPressed: () async {
                  downloadPath = await ExtStorageProvider.getExtStorage(
                        dirName: 'Music',
                        writeAccess: true,
                      ) ??
                      '/storage/emulated/0/Music';
                  Hive.box('settings').put('downloadPath', downloadPath);
                  setState(
                    () {},
                  );
                },
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!
                      .reset,
                ),
              ),
              onTap: () async {
                final String temp = await Picker.selectFolder(
                  context: context,
                  message: AppLocalizations.of(
                    context,
                  )!
                      .selectDownLocation,
                );
                if (temp.trim() != '') {
                  downloadPath = temp;
                  Hive.box('settings').put('downloadPath', temp);
                  setState(
                    () {},
                  );
                } else {
                  ShowSnackBar().showSnackBar(
                    context,
                    AppLocalizations.of(
                      context,
                    )!
                        .noFolderSelected,
                  );
                }
              },
              dense: true,
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .downFilename,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .downFilenameSub,
              ),
              dense: true,
              onTap: () {
                showModalBottomSheet(
                  isDismissible: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    return BottomGradientContainer(
                      borderRadius: BorderRadius.circular(
                        20.0,
                      ),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          10,
                          0,
                          10,
                        ),
                        children: [
                          CheckboxListTile(
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                            title: Text(
                              '${AppLocalizations.of(context)!.title} - ${AppLocalizations.of(context)!.artist}',
                            ),
                            value: downFilename == 0,
                            selected: downFilename == 0,
                            onChanged: (bool? val) {
                              if (val ?? false) {
                                downFilename = 0;
                                settingsBox.put('downFilename', 0);
                                Navigator.pop(context);
                              }
                            },
                          ),
                          CheckboxListTile(
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                            title: Text(
                              '${AppLocalizations.of(context)!.artist} - ${AppLocalizations.of(context)!.title}',
                            ),
                            value: downFilename == 1,
                            selected: downFilename == 1,
                            onChanged: (val) {
                              if (val ?? false) {
                                downFilename = 1;
                                settingsBox.put('downFilename', 1);
                                Navigator.pop(context);
                              }
                            },
                          ),
                          CheckboxListTile(
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                            title: Text(
                              AppLocalizations.of(context)!.title,
                            ),
                            value: downFilename == 2,
                            selected: downFilename == 2,
                            onChanged: (val) {
                              if (val ?? false) {
                                downFilename = 2;
                                settingsBox.put('downFilename', 2);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .createAlbumFold,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .createAlbumFoldSub,
              ),
              keyName: 'createDownloadFolder',
              isThreeLine: true,
              defaultValue: false,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .createYtFold,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .createYtFoldSub,
              ),
              keyName: 'createYoutubeFolder',
              isThreeLine: true,
              defaultValue: false,
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .downLyrics,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .downLyricsSub,
              ),
              keyName: 'downloadLyrics',
              defaultValue: false,
              isThreeLine: true,
            ),
          ],
        ),
      ),
    );
  }
}
