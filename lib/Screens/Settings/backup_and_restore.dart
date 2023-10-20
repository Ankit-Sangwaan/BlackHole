import 'package:blackhole/CustomWidgets/box_switch_tile.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/Helpers/backup_restore.dart';
import 'package:blackhole/Helpers/config.dart';
import 'package:blackhole/Helpers/picker.dart';
import 'package:blackhole/Services/ext_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

class BackupAndRestorePage extends StatefulWidget {
  const BackupAndRestorePage({super.key});

  @override
  State<BackupAndRestorePage> createState() => _BackupAndRestorePageState();
}

class _BackupAndRestorePageState extends State<BackupAndRestorePage> {
  final Box settingsBox = Hive.box('settings');
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  String autoBackPath = Hive.box('settings').get(
    'autoBackPath',
    defaultValue: '/storage/emulated/0/BlackHole/Backups',
  ) as String;

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
                .backNRest,
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
                    .createBack,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .createBackSub,
              ),
              dense: true,
              onTap: () {
                showModalBottomSheet(
                  isDismissible: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    final List playlistNames = Hive.box('settings').get(
                      'playlistNames',
                      defaultValue: ['Favorite Songs'],
                    ) as List;
                    if (!playlistNames.contains('Favorite Songs')) {
                      playlistNames.insert(0, 'Favorite Songs');
                      settingsBox.put(
                        'playlistNames',
                        playlistNames,
                      );
                    }

                    final List<String> persist = [
                      AppLocalizations.of(
                        context,
                      )!
                          .settings,
                      AppLocalizations.of(
                        context,
                      )!
                          .playlists,
                    ];

                    final List<String> checked = [
                      AppLocalizations.of(
                        context,
                      )!
                          .settings,
                      AppLocalizations.of(
                        context,
                      )!
                          .downs,
                      AppLocalizations.of(
                        context,
                      )!
                          .playlists,
                    ];

                    final List<String> items = [
                      AppLocalizations.of(
                        context,
                      )!
                          .settings,
                      AppLocalizations.of(
                        context,
                      )!
                          .playlists,
                      AppLocalizations.of(
                        context,
                      )!
                          .downs,
                      AppLocalizations.of(
                        context,
                      )!
                          .cache,
                    ];

                    final Map<String, List> boxNames = {
                      AppLocalizations.of(
                        context,
                      )!
                          .settings: ['settings'],
                      AppLocalizations.of(
                        context,
                      )!
                          .cache: ['cache'],
                      AppLocalizations.of(
                        context,
                      )!
                          .downs: ['downloads'],
                      AppLocalizations.of(
                        context,
                      )!
                          .playlists: playlistNames,
                    };
                    return StatefulBuilder(
                      builder: (
                        BuildContext context,
                        StateSetter setStt,
                      ) {
                        return BottomGradientContainer(
                          borderRadius: BorderRadius.circular(
                            20.0,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    10,
                                    0,
                                    10,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (context, idx) {
                                    return CheckboxListTile(
                                      activeColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      checkColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary ==
                                              Colors.white
                                          ? Colors.black
                                          : null,
                                      value: checked.contains(
                                        items[idx],
                                      ),
                                      title: Text(
                                        items[idx],
                                      ),
                                      onChanged: persist.contains(items[idx])
                                          ? null
                                          : (bool? value) {
                                              value!
                                                  ? checked.add(
                                                      items[idx],
                                                    )
                                                  : checked.remove(
                                                      items[idx],
                                                    );
                                              setStt(
                                                () {},
                                              );
                                            },
                                    );
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .cancel,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    onPressed: () {
                                      createBackup(
                                        context,
                                        checked,
                                        boxNames,
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .ok,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
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
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .restore,
              ),
              subtitle: Text(
                '${AppLocalizations.of(
                  context,
                )!.restoreSub}\n(${AppLocalizations.of(
                  context,
                )!.restart})',
              ),
              dense: true,
              onTap: () async {
                await restore(context);
                currentTheme.refresh();
              },
            ),
            BoxSwitchTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .autoBack,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .autoBackSub,
              ),
              keyName: 'autoBackup',
              defaultValue: false,
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .autoBackLocation,
              ),
              subtitle: Text(autoBackPath),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey[700],
                ),
                onPressed: () async {
                  autoBackPath = await ExtStorageProvider.getExtStorage(
                        dirName: 'BlackHole/Backups',
                        writeAccess: true,
                      ) ??
                      '/storage/emulated/0/BlackHole/Backups';
                  Hive.box('settings').put('autoBackPath', autoBackPath);
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
                      .selectBackLocation,
                );
                if (temp.trim() != '') {
                  autoBackPath = temp;
                  Hive.box('settings').put('autoBackPath', temp);
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
          ],
        ),
      ),
    );
  }
}
