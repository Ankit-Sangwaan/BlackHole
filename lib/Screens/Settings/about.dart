import 'dart:io';

import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/Helpers/github.dart';
import 'package:blackhole/Helpers/update.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? appVersion;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    setState(
      () {},
    );
  }

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
                .about,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10.0,
                    10.0,
                    10.0,
                    10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .version,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .versionSub,
                        ),
                        onTap: () {
                          ShowSnackBar().showSnackBar(
                            context,
                            AppLocalizations.of(
                              context,
                            )!
                                .checkingUpdate,
                            noAction: true,
                          );

                          GitHub.getLatestVersion().then(
                            (String latestVersion) async {
                              if (compareVersion(
                                latestVersion,
                                appVersion!,
                              )) {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  AppLocalizations.of(context)!.updateAvailable,
                                  duration: const Duration(seconds: 15),
                                  action: SnackBarAction(
                                    textColor:
                                        Theme.of(context).colorScheme.secondary,
                                    label: AppLocalizations.of(context)!.update,
                                    onPressed: () async {
                                      String arch = '';
                                      if (Platform.isAndroid) {
                                        List? abis = await Hive.box('settings')
                                            .get('supportedAbis') as List?;

                                        if (abis == null) {
                                          final DeviceInfoPlugin deviceInfo =
                                              DeviceInfoPlugin();
                                          final AndroidDeviceInfo
                                              androidDeviceInfo =
                                              await deviceInfo.androidInfo;
                                          abis =
                                              androidDeviceInfo.supportedAbis;
                                          await Hive.box('settings')
                                              .put('supportedAbis', abis);
                                        }
                                        if (abis.contains('arm64')) {
                                          arch = 'arm64';
                                        } else if (abis.contains('armeabi')) {
                                          arch = 'armeabi';
                                        }
                                      }
                                      Navigator.pop(context);
                                      launchUrl(
                                        Uri.parse(
                                          'https://sangwan5688.github.io/download?platform=${Platform.operatingSystem}&arch=$arch',
                                        ),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .latest,
                                );
                              }
                            },
                          );
                        },
                        trailing: Text(
                          'v$appVersion',
                          style: const TextStyle(fontSize: 12),
                        ),
                        dense: true,
                      ),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .shareApp,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .shareAppSub,
                        ),
                        onTap: () {
                          Share.share(
                            '${AppLocalizations.of(
                              context,
                            )!.shareAppText}: https://sangwan5688.github.io/',
                          );
                        },
                        dense: true,
                      ),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .likedWork,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .buyCoffee,
                        ),
                        dense: true,
                        onTap: () {
                          launchUrl(
                            Uri.parse(
                              'https://www.buymeacoffee.com/ankitsangwan',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .donateGpay,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .donateGpaySub,
                        ),
                        dense: true,
                        isThreeLine: true,
                        onTap: () {
                          const String upiUrl =
                              'upi://pay?pa=ankit.sangwan.5688@oksbi&pn=BlackHole';
                          launchUrl(
                            Uri.parse(upiUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        onLongPress: () {
                          copyToClipboard(
                            context: context,
                            text: 'ankit.sangwan.5688@oksbi',
                            displayText: AppLocalizations.of(
                              context,
                            )!
                                .upiCopied,
                          );
                        },
                        trailing: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey[700],
                          ),
                          onPressed: () {
                            copyToClipboard(
                              context: context,
                              text: 'ankit.sangwan.5688@oksbi',
                              displayText: AppLocalizations.of(
                                context,
                              )!
                                  .upiCopied,
                            );
                          },
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .copy,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .contactUs,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .contactUsSub,
                        ),
                        dense: true,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 100,
                                child: GradientContainer(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              MdiIcons.gmail,
                                            ),
                                            iconSize: 40,
                                            tooltip: AppLocalizations.of(
                                              context,
                                            )!
                                                .gmail,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              launchUrl(
                                                Uri.parse(
                                                  'https://mail.google.com/mail/?extsrc=mailto&url=mailto%3A%3Fto%3Dblackholeyoucantescape%40gmail.com%26subject%3DRegarding%2520Mobile%2520App',
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                          ),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .gmail,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              MdiIcons.telegram,
                                            ),
                                            iconSize: 40,
                                            tooltip: AppLocalizations.of(
                                              context,
                                            )!
                                                .tg,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              launchUrl(
                                                Uri.parse(
                                                  'https://t.me/joinchat/fHDC1AWnOhw0ZmI9',
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                          ),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .tg,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              MdiIcons.instagram,
                                            ),
                                            iconSize: 40,
                                            tooltip: AppLocalizations.of(
                                              context,
                                            )!
                                                .insta,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              launchUrl(
                                                Uri.parse(
                                                  'https://instagram.com/sangwan5688',
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                          ),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .insta,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
                              .joinTg,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .joinTgSub,
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 100,
                                child: GradientContainer(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              MdiIcons.telegram,
                                            ),
                                            iconSize: 40,
                                            tooltip: AppLocalizations.of(
                                              context,
                                            )!
                                                .tgGp,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              launchUrl(
                                                Uri.parse(
                                                  'https://t.me/joinchat/fHDC1AWnOhw0ZmI9',
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                          ),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .tgGp,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              MdiIcons.telegram,
                                            ),
                                            iconSize: 40,
                                            tooltip: AppLocalizations.of(
                                              context,
                                            )!
                                                .tgCh,
                                            onPressed: () {
                                              Navigator.pop(context);
                                              launchUrl(
                                                Uri.parse(
                                                  'https://t.me/blackhole_official',
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                          ),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .tgCh,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        dense: true,
                      ),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .moreInfo,
                        ),
                        dense: true,
                        onTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.madeBy,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
