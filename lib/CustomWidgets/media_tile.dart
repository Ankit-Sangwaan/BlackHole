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

import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:flutter/material.dart';

class MediaTile extends StatelessWidget {
  final EdgeInsetsGeometry contentPadding;
  final String title;
  final String? subtitle;
  final bool isThreeLine;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final Function()? onTap;

  const MediaTile({
    super.key,
    this.contentPadding = const EdgeInsets.only(left: 15.0),
    required this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.leadingWidget,
    this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: contentPadding,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              overflow: TextOverflow.ellipsis,
            ),
      isThreeLine: isThreeLine,
      leading: leadingWidget,
      trailing: trailingWidget,
      onLongPress: () {
        copyToClipboard(
          context: context,
          text: title,
        );
      },
      onTap: onTap,
    );
  }
}
