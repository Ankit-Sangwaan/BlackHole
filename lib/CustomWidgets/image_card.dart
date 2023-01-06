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

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget imageCard(
  String imageUrl, {
  bool localImage = false,
  double elevation = 5,
  double radius = 15.0,
  ImageProvider? placeholderImage,
}) {
  return Card(
    elevation: elevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    ),
    clipBehavior: Clip.antiAlias,
    child: localImage
        ? Image(
            fit: BoxFit.cover,
            errorBuilder: (context, _, __) => const Image(
              fit: BoxFit.cover,
              image: AssetImage('assets/cover.jpg'),
            ),
            image: FileImage(
              File(
                imageUrl,
              ),
            ),
          )
        : CachedNetworkImage(
            fit: BoxFit.cover,
            errorWidget: (context, _, __) => const Image(
              fit: BoxFit.cover,
              image: AssetImage('assets/cover.jpg'),
            ),
            imageUrl: imageUrl,
            placeholder: placeholderImage == null
                ? null
                : (context, url) => Image(
                      fit: BoxFit.cover,
                      image: placeholderImage,
                    ),
          ),
  );
}
