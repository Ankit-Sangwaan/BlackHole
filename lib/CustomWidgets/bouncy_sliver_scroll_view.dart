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
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BouncyImageSliverScrollView extends StatelessWidget {
  final ScrollController scrollController;
  final SliverList sliverList;
  final bool shrinkWrap;
  final List<Widget>? actions;
  final String title;
  final String? imageUrl;
  final bool localImage;
  final String placeholderImage;
  final bool fromYt;
  BouncyImageSliverScrollView({
    super.key,
    required this.scrollController,
    this.shrinkWrap = false,
    required this.sliverList,
    required this.title,
    this.placeholderImage = 'assets/cover.jpg',
    this.localImage = false,
    this.fromYt = false,
    this.imageUrl,
    this.actions,
  });

  final ValueNotifier<double> _opacity = ValueNotifier<double>(1.0);

  @override
  Widget build(BuildContext context) {
    final Widget image = imageUrl == null
        ? Image(
            fit: BoxFit.cover,
            image: AssetImage(placeholderImage),
          )
        : localImage
            ? Image(
                image: FileImage(
                  File(
                    imageUrl!,
                  ),
                ),
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                fit: BoxFit.cover,
                errorWidget: (context, _, __) => Image(
                  fit: BoxFit.cover,
                  image: AssetImage(placeholderImage),
                ),
                imageUrl: imageUrl!,
                placeholder: (context, url) => Image(
                  fit: BoxFit.cover,
                  image: AssetImage(placeholderImage),
                ),
              );
    // final bool rotated =
    // MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;
    final double expandedHeight =
        MediaQuery.of(context).size.height * (fromYt ? 0.2 : 0.4);

    return CustomScrollView(
      controller: scrollController,
      shrinkWrap: shrinkWrap,
      physics: const BouncingScrollPhysics(),
      slivers: [
        AnimatedBuilder(
          animation: scrollController,
          child: SizedBox.expand(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.transparent,
                  ],
                ).createShader(
                  Rect.fromLTRB(
                    0,
                    0,
                    rect.width,
                    rect.height,
                  ),
                );
              },
              blendMode: BlendMode.dstIn,
              child: image,
            ),
          ),
          builder: (context, child) {
            if (scrollController.offset.roundToDouble() > expandedHeight - 80) {
              _opacity.value = 1;
            } else {
              scrollController.offset.roundToDouble() / (expandedHeight - 80) >
                      0
                  ? _opacity.value = scrollController.offset.roundToDouble() /
                      (expandedHeight - 80)
                  : _opacity.value = 0;
            }
            return SliverAppBar(
              elevation: 0,
              stretch: true,
              pinned: true,
              centerTitle: true,
              // floating: true,
              backgroundColor: _opacity.value < 0.6 ? Colors.transparent : null,
              expandedHeight: expandedHeight,
              actions: actions,
              flexibleSpace: FlexibleSpaceBar(
                title: Opacity(
                  opacity: max(0, min(1 - _opacity.value, 1)),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                centerTitle: true,
                background: child,
              ),
            );
          },
        ),
        sliverList,
      ],
    );
  }
}
