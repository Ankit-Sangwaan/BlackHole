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

String getImageUrl(String? imageUrl, {String quality = 'high'}) {
  if (imageUrl == null) return '';
  switch (quality) {
    case 'high':
      return imageUrl
          .trim()
          .replaceAll('http:', 'https:')
          .replaceAll('50x50', '500x500')
          .replaceAll('150x150', '500x500');
    case 'medium':
      return imageUrl
          .trim()
          .replaceAll('http:', 'https:')
          .replaceAll('50x50', '150x150')
          .replaceAll('500x500', '150x150');
    case 'low':
      return imageUrl
          .trim()
          .replaceAll('http:', 'https:')
          .replaceAll('150x150', '50x50')
          .replaceAll('500x500', '50x50');
    default:
      return imageUrl
          .trim()
          .replaceAll('http:', 'https:')
          .replaceAll('50x50', '500x500')
          .replaceAll('150x150', '500x500');
  }
}
