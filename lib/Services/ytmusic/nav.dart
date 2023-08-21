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

// ignore: avoid_classes_with_only_static_members
class NavClass {
  static const content = ['contents', 0];
  static const runText = ['runs', 0, 'text'];
  static const tabContent = ['tabs', 0, 'tabRenderer', 'content'];
  static const tab1Content = ['tabs', 1, 'tabRenderer', 'content'];
  static const singleColumn = ['contents', 'singleColumnBrowseResultsRenderer'];
  static const singleColumnTab = [...singleColumn, ...tabContent];
  static const sectionList = ['sectionListRenderer', 'contents'];
  static const sectionListItem = ['sectionListRenderer', ...content];
  static const itemSection = ['itemSectionRenderer', ...content];
  static const musicShelf = ['musicShelfRenderer'];
  static const musicShelfContent = [...musicShelf, ...content];
  static const musicShelfContents = [...musicShelf, 'contents'];
  static const grid = ['gridRenderer'];
  static const gridItems = [...grid, 'items'];
  static const menu = ['menu', 'menuRenderer'];
  static const menuItems = [...menu, 'items'];
  static const menuLikeStatus = [
    ...menu,
    'topLevelButtons',
    0,
    'likeButtonRenderer',
    'likeStatus',
  ];
  static const menuService = ['menuServiceItemRenderer', 'serviceEndpoint'];
  static const toggleMenu = 'toggleMenuServiceItemRenderer';
  static const playButton = [
    'overlay',
    'musicItemThumbnailOverlayRenderer',
    'content',
    'musicPlayButtonRenderer',
  ];
  static const navigationBrowse = ['navigationEndpoint', 'browseEndpoint'];
  static const navigationBrowseId = [...navigationBrowse, 'browseId'];
  static const pageType = [
    'browseEndpointContextSupportedConfigs',
    'browseEndpointContextMusicConfig',
    'pageType',
  ];
  static const navigationVideoId = [
    'navigationEndpoint',
    'watchEndpoint',
    'videoId',
  ];
  static const navigationPlaylistId = [
    'navigationEndpoint',
    'watchEndpoint',
    'playlistId',
  ];
  static const navigationWatchPlaylistId = [
    'navigationEndpoint',
    'watchPlaylistEndpoint',
    'playlistId',
  ];
  static const navigationVideoType = [
    'watchEndpoint',
    'watchEndpointMusicSupportedConfigs',
    'watchEndpointMusicConfig',
    'musicVideoType',
  ];
  static const headerDetail = ['header', 'musicDetailHeaderRenderer'];
  static const headerCardShelf = [
    'header',
    'musicCardShelfHeaderBasicRenderer',
  ];
  static const immersiveHeaderDetail = [
    'header',
    'musicImmersiveHeaderRenderer',
  ];
  static const descriptionShelf = ['musicDescriptionShelfRenderer'];
  static const description = ['description', ...runText];
  static const carousel = ['musicCarouselShelfRenderer'];
  static const immersiveCarousel = ['musicImmersiveCarouselShelfRenderer'];
  static const carouselContents = [...carousel, 'contents'];
  static const carouselTitle = [
    'header',
    'musicCarouselShelfBasicHeaderRenderer',
    'title',
    'runs',
    0,
  ];
  static const frameworkMutations = [
    'frameworkUpdates',
    'entityBatchUpdate',
    'mutations',
  ];
  static const title = ['title', 'runs', 0];
  static const titleText = ['title', ...runText];
  static const titleRuns = ['title', 'runs'];
  static const titleRun = [...titleRuns, 0];
  static const textRuns = ['text', 'runs'];
  static const textRun = [...textRuns, 0];
  static const textRunText = [...textRun, 'text'];
  static const subtitle = ['subtitle', runText];
  static const subtitleRuns = ['subtitle', 'runs'];
  static const secondSubtitleRuns = ['secondSubtitle', 'runs'];
  static const subtitle2 = ['subtitle', 'runs', 2, 'text'];
  static const subtitle3 = ['subtitle', 'runs', 4, 'text'];
  static const thumbnail = ['thumbnail', 'thumbnails'];
  static const thumbnails = [
    'thumbnail',
    'musicThumbnailRenderer',
    ...thumbnail,
  ];
  static const thumbnailRenderer = [
    'thumbnailRenderer',
    'musicThumbnailRenderer',
    ...thumbnail,
  ];
  static const thumbnailCropped = [
    'thumbnail',
    'croppedSquareThumbnailRenderer',
    ...thumbnail,
  ];
  static const feedbackToken = ['feedbackEndpoint', 'feedbackToken'];
  static const badgePath = [
    0,
    'musicInlineBadgeRenderer',
    'accessibilityData',
    'accessibilityData',
    'label',
  ];
  static const badgeLabel = ['badges', ...badgePath];
  static const subtitleBadgeLabel = ['subtitleBadges', ...badgePath];
  static const categoryTitle = [
    'musicNavigationButtonRenderer',
    'buttonText',
    ...runText,
  ];
  static const categoryParams = [
    'musicNavigationButtonRenderer',
    'clickCommand',
    'browseEndpoint',
    'params',
  ];
  static const mTRIR = 'musicTwoRowItemRenderer';
  static const mRLIR = 'musicResponsiveListItemRenderer';
  static const mRLIRFlex = ['musicResponsiveListItemRenderer', 'flexColumns'];
  static const mRLIFCR = 'musicResponsiveListItemFlexColumnRenderer';
  static const mrlirPlaylistId = [mRLIR, 'playlistItemData', 'videoId'];
  static const mrlirBrowseId = [mRLIR, ...navigationBrowseId];
  static const tasteProfileItems = [
    'contents',
    'tastebuilderRenderer',
    'contents',
  ];
  static const tasteProfileArtist = ['title', 'runs'];
  static const sectionListContinuation = [
    'continuationContents',
    'sectionListContinuation',
  ];
  static const menuPlaylistId = [
    ...menuItems,
    0,
    'menuNavigationItemRenderer',
    ...navigationWatchPlaylistId,
  ];

  static dynamic nav(dynamic root, List items) {
    try {
      dynamic res = root;
      for (final item in items) {
        res = res[item];
      }
      return res;
    } catch (e) {
      return null;
    }
  }

  static String joinRunTexts(List? runs) {
    if (runs == null) return '';
    return runs.map((e) => e['text']).toList().join();
  }

  static List runUrls(List? runs) {
    if (runs == null) return [];
    return runs.map((e) => e['url']).toList();
  }

  static List runThumnbails(List? runs) {
    if (runs == null) return [];
    return runs.map((e) => e['url']).toList();
  }
}
