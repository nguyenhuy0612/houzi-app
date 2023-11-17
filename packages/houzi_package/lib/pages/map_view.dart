import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:houzi_package/files/app_preferences/app_preferences.dart';
import 'package:houzi_package/files/hooks_files/hooks_configurations.dart';
import 'package:houzi_package/models/map_marker_data.dart';
import 'package:houzi_package/providers/state_providers/user_log_provider.dart';
import 'package:houzi_package/models/article.dart';
import 'package:provider/provider.dart';

import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/widgets/data_loading_widget.dart';
import 'package:houzi_package/widgets/generic_text_widget.dart';

import 'package:houzi_package/widgets/search_result_widgets/label_marker.dart';


typedef MapViewListener = void Function({
  Map<String,String>? coordinatesMap,
  int? selectedMarkerPropertyId,
  bool? snapCameraToSelectedIndex,
  bool? showWaitingWidget,
});

class MapView extends StatefulWidget {

  final List<dynamic> listArticles;
  final MapViewListener? mapViewListener;
  final bool showWaitingWidget;
  final bool zoomToAllLocations;
  final int selectedArticleIndex;

  final bool snapCameraToSelectedIndex;

  final Key googleMapsKey;
  final bool hideMap;
  const MapView(
    this.listArticles, {
    Key? key,
    this.mapViewListener,
    required this.showWaitingWidget,
    required this.zoomToAllLocations,
    required this.selectedArticleIndex,
    required this.snapCameraToSelectedIndex,
    required this.googleMapsKey,
    required this.hideMap,
  }): super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with AutomaticKeepAliveClientMixin<MapView> {


  bool isUserLoggedIn = false;
  bool showSearchInThisArea = false;

  int counter = 0;

  //MAP_IMPROVES_BY_ADIL - Keep the first ever camera center, and last ever camera center, it'll help us in distance counting.
  double? cameraStartLat = null;
  double? cameraStartLng = null;
  double? cameraEndLat = null;
  double? cameraEndLng = null;
  
  double mapZoom = 11;
  double? x0, x1, y0, y1;

  Set<Marker> googleMapMarkers = {};

  List<String> addressCoordinatesList = [];
  List<dynamic> listArticles = [];

  LatLng? _lastMapPosition;

  GoogleMap? map, tempMap;

  GoogleMapController? _googleMapController;

  MarkerTitleHook markerTitleHook = HooksConfigurations.markerTitle;
  MarkerIconHook markerIconHook = HooksConfigurations.markerIcon;
  CustomMarkerHook customMarkerHook = HooksConfigurations.customMapMarker;

  EdgeInsets mapPaddingActive = EdgeInsets.only(left: 5, right: 5, top: 150, bottom: 200);

  bool hideMap = false;
  final _initialCameraPosition = CameraPosition(
    target: LatLng(37.4219999, -122.0862462),
    zoom: 11,
  );

  bool lock = false;
  int lastSelectedIndex = -1;

  @override
  void initState() {
    super.initState();
    if (Provider.of<UserLoggedProvider>(context, listen: false).isLoggedIn!) {
      isUserLoggedIn = true;
    }

  }

  setCustomImageIcons(Article article) async {
    String? iconStr = markerIconHook(context, article);

    BitmapDescriptor? icon;
    if (iconStr != null && iconStr.isNotEmpty) {
      icon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 3.2), iconStr);
      return icon;
    }
    double height = MediaQuery.of(context).size.height;
    MapMarkerData? markerData = customMarkerHook(context, article);
    if (markerData != null) {
      Color textColor = markerData.textColor == null ?  Colors.white : markerData.textColor!;
      TextStyle style = markerData.textStyle ?? TextStyle(
        fontSize: height * 5/100.0,
        color: textColor,
      );
      icon = await createCustomMarkerBitmap(
        markerData.text,
        backgroundColor: markerData.backgroundColor,
        textStyle: style,
      );
      return icon;
    }

    return icon ?? BitmapDescriptor.defaultMarker;
  }

  Map<int, Marker> markerCache = {};
  setupMarkersIfPossible() {
    googleMapMarkers.clear();
    x0 = null;
    x1 = null;
    y0 = null;
    y1 = null;

    widget.listArticles.removeWhere((element) => element is AdWidget);

    widget.listArticles.forEach((mapItem) async {
      Article item = mapItem;
      final heroId = item.id.toString() + "-marker";
      var tempAddress = item.address;
      if(tempAddress != null) {
        var address = tempAddress.coordinates.toString();
        if ((address.isNotEmpty) && (address != ',')) {
          var temp = address.split(",");

          double lat = double.parse(temp[0]);
          double lng = double.parse(temp[1]);

          if (x0 == null) {
            x0 = x1 = lat;
            y0 = y1 = lng;
          } else {
            if (lat > x1!) x1 = lat;
            if (lat < x0!) x0 = lat;
            if (lng > y1!) y1 = lng;
            if (lng < y0!) y0 = lng;
          }
          //MAP_IMPROVES_BY_ADIL - when we do something on ui, it clears markers for no reason,
          // Lets cache this based on heroId and fill from cache on next update.
          if (markerCache.containsKey(item.id)) {
            googleMapMarkers.add(markerCache[item.id]!);
            return;
          }
          Marker marker = Marker(
              markerId: MarkerId(heroId),
              position: LatLng(lat, lng),
              icon: await setCustomImageIcons(item),
              onTap: () {

                widget.mapViewListener!(
                    selectedMarkerPropertyId: item.id,
                        snapCameraToSelectedIndex: true
                );
              },
              infoWindow: InfoWindow(
                  title: markerTitleHook(context, item),
                  // title: item.title.toString(),
                  onTap: () {
                    if (item.propertyInfo!.requiredLogin) {
                      isUserLoggedIn
                          ? UtilityMethods.navigateToPropertyDetailPage(
                        context: context,
                        propertyID: item.id!,
                        heroId: heroId,
                      )
                          : UtilityMethods.navigateToLoginPage(context, false);
                    } else {
                      UtilityMethods.navigateToPropertyDetailPage(
                        context: context,
                        propertyID: item.id!,
                        heroId: heroId,
                      );
                    }
                  }));
          //MAP_IMPROVES_BY_ADIL - add to cache.

          markerCache[item.id!] = marker;
          googleMapMarkers.add(marker);
          // if(mounted) {
          //   setState(() {
          //     googleMapMarkers.add(marker);
          //   });
          // }
        }
      }

    });

    // if (x1 != null && x0 != null && y1 != null && x0 != null) {
    //   LatLngBounds latLngBounds =
    //   LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
    //   if (_googleMapController != null) {
    //     CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(latLngBounds, 190.0);
    //     _googleMapController.animateCamera(cameraUpdate);
    //     // setState(() {
    //     //   // showSearchInThisArea = false;
    //     //   // widget._enableCameraMovement = false;
    //     // });
    //   }
    // }
    // if (widget._snapCameraToSelectedIndex) {
    //   if (x1 != null && x0 != null && y1 != null && x0 != null) {
    //     LatLngBounds latLngBounds =
    //         LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
    //     if (_googleMapController != null) {
    //       CameraUpdate cameraUpdate =
    //           CameraUpdate.newLatLngBounds(latLngBounds, 190.0);
    //       _googleMapController.animateCamera(cameraUpdate);
    //       setState(() {
    //         // showSearchInThisArea = false;
    //         // widget._enableCameraMovement = false;
    //       });
    //
    //     }
    //   }
    // }

  }

  animateCameraToSelectedProperty(){
    if (_googleMapController != null) {
      if (widget.selectedArticleIndex != lastSelectedIndex &&
          lastSelectedIndex != -1 &&
          widget.listArticles.isNotEmpty &&
          widget.listArticles.length > lastSelectedIndex) {
        var item = widget.listArticles[lastSelectedIndex];
        //print("animateCameraToSelectedProperty():: hiding marker for: " +item.title);
        var tempAddress = item.address;

        if (tempAddress != null) {
          var address = tempAddress.getCoordinates();
          if (address != null && address.isNotEmpty) {
            final heroId = item.id.toString() + "-marker";
            var markerId = MarkerId(heroId);
            _googleMapController?.isMarkerInfoWindowShown(markerId).then((
                shown) {
              _googleMapController!.hideMarkerInfoWindow(markerId);
            });
            lastSelectedIndex = -1;
          }
        }
      }
    }

    if (widget.snapCameraToSelectedIndex &&
        widget.selectedArticleIndex >= 0 &&
        widget.listArticles.isNotEmpty &&
        widget.listArticles.length > widget.selectedArticleIndex) {
      var item = widget.listArticles[widget.selectedArticleIndex];
      //print("animateCameraToSelectedProperty():: showing marker for: " +item.title);
      final heroId = item.id.toString() + "-marker";

      var tempAddress = item.address;
      if (tempAddress != null) {
        var address = tempAddress.getCoordinates();
        if (address != null && address.isNotEmpty) {
          lastSelectedIndex = widget.selectedArticleIndex;
          var markerId = MarkerId(heroId);
          _googleMapController?.isMarkerInfoWindowShown(markerId).then((shown) {
            if (!shown) {
              _googleMapController!.showMarkerInfoWindow(MarkerId(heroId));

              var location = CameraPosition(
                target: LatLng(address[0], address[1]),
                zoom: mapZoom,
              );
              _googleMapController!
                  .animateCamera(CameraUpdate.newCameraPosition(location));
            }
          });
        }
      }
    }
  }

  attemptZoomToAllProperties(){
    if (widget.showWaitingWidget) {
      //print("attemptZoomToAllProperties():: something in progress, bailing");
      //if we're doing some web service work, don't attempt zoom.
      return;
    }
    if (widget.selectedArticleIndex != -1 && widget.listArticles.isNotEmpty &&
        widget.listArticles.length > widget.selectedArticleIndex) {
        //print("attemptZoomToAllProperties():: selectedArticleIndex available:: ${widget.selectedArticleIndex}");
        //if we're focusing on a single property, we should not zoom on all properties.
        return;
    }

    if(widget.zoomToAllLocations && _googleMapController != null
        && (x1 != null && x0 != null && y1 != null && x0 != null)){
      LatLngBounds latLngBounds = LatLngBounds(
        northeast: LatLng(x1!, y1!),
        southwest: LatLng(x0!, y0!),
      );

      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(latLngBounds, 50.0); // 190.0
      _googleMapController!.animateCamera(cameraUpdate).then((value) {
        //print("calling  widget.mapViewListener" );
        widget.mapViewListener!(
        );
      });
    }
    //MAP_IMPROVES_BY_ADIL - the first ever publishing should record the bounds center as start position
    if (x1 != null && x0 != null && y1 != null && x0 != null) {
      if (cameraStartLat == null || cameraStartLng == null) {
        LatLng centerLatLng = LatLng(
          (x1! + x0!) / 2,
          (y1! + y0!) / 2,
        );
        cameraStartLat = centerLatLng.latitude;
        cameraStartLng = centerLatLng.longitude;
      }
    }


  }

  @override
  void dispose() {

    if(_googleMapController != null){
      _googleMapController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    setupMarkersIfPossible();

    attemptZoomToAllProperties();

    animateCameraToSelectedProperty();



    return WillPopScope(
      onWillPop: () {
        setState(() {
          //A dirty hack for map showing when exiting back to
          hideMap = true;
        });

        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            //MAP_IMPROVES_BY_ADIL - Wrap Map in Listener widget to only get notified with map change made by user.
            //
            Listener(

              onPointerUp: (e) {
                //MAP_IMPROVES_BY_ADIL - we don't want to deal with nulls.
                if (cameraStartLat == null || cameraStartLng == null || cameraEndLat == null || cameraEndLng == null) return;

                //MAP_IMPROVES_BY_ADIL - calculate distance from start point to end point.
                double distance = findDistance(cameraStartLat!, cameraStartLng!, cameraEndLat!, cameraEndLng!);
                //MAP_IMPROVES_BY_ADIL - the minimum distance that should show Search In this Area button
                double threshold = 1;
                //MAP_IMPROVES_BY_ADIL - hide or show only when we pass or fail this threshold
                //MAP_IMPROVES_BY_ADIL - don't cause the set state to be called too much. only when threshold crossed
                if (distance < threshold && showSearchInThisArea){
                  if(mounted) setState(() {
                    showSearchInThisArea = false;
                  });
                }
                if (distance > threshold && !showSearchInThisArea){
                  if(mounted) setState(() {
                    showSearchInThisArea = true;
                  });
                }
              },
              child: (hideMap || widget.hideMap) ? Container() : GoogleMap(
                key: widget.googleMapsKey,
                myLocationButtonEnabled: false,
                zoomGesturesEnabled: true,
                tiltGesturesEnabled: false,
                zoomControlsEnabled: false,
                markers: googleMapMarkers,
                initialCameraPosition: _initialCameraPosition,
                padding: _googleMapController == null
                    ? EdgeInsets.zero
                    //MAP_IMPROVES_BY_ADIL - the padding for map marker should consider available real estate of screen
                    : EdgeInsets.only(left: 80, right: 80, top: 250, bottom: 250),
                onMapCreated: (controller) {
                  _googleMapController = controller;
                  if (mounted) setState(() {});
                },
                onCameraMove: (CameraPosition cameraPosition) {
                  mapZoom = cameraPosition.zoom;
                  _lastMapPosition = cameraPosition.target;
                  double targetLat = cameraPosition.target.latitude;
                  double targetLon = cameraPosition.target.longitude;

                  //MAP_IMPROVES_BY_ADIL - every camera move can be last, so keep it recorded.
                  cameraEndLat = targetLat;
                  cameraEndLng = targetLon;


                  // widget.mapViewListener!(
                  //
                  // );
                },
                onTap: (LatLng latLng) {
                  //when we get this event, it means, we're not tapping a marker.
                  //So if there's any marker showing window right now, hide that.
                  //print("map tapped");
                  widget.mapViewListener!(
                      selectedMarkerPropertyId: -1,
                      snapCameraToSelectedIndex: false,
                      showWaitingWidget: false
                  );
                },
                onCameraIdle: () {
                  // if(mounted){
                  //   setState(() {});
                  // }
                },
              ),
            ),
            if(showSearchInThisArea)
              Container(
                    margin: EdgeInsets.only(top: 120),
                    alignment: Alignment.topCenter,
                    child: FloatingActionButton.extended(
                      elevation: 0.0,
                      backgroundColor: AppThemePreferences().appTheme.searchBarBackgroundColor,
                      onPressed: () {
                        var visibleRegion = _googleMapController!.getVisibleRegion();
                        visibleRegion.then((value) {
                          var distance = Geolocator.distanceBetween(
                              value.northeast.latitude,
                              value.northeast.longitude,
                              value.southwest.latitude,
                              value.southwest.longitude,
                          );
                          //MAP_IMPROVES_BY_ADIL - save current center as start point for next camera move distance
                          cameraStartLat = _lastMapPosition!.latitude;
                          cameraStartLng = _lastMapPosition!.longitude;

                          double distanceInKiloMeters = distance / 1000;
                          double roundDistanceInKM = double.parse((distanceInKiloMeters).toStringAsFixed(2));

                          Map<String, String> coordinatesMap = {
                            LATITUDE: _lastMapPosition!.latitude.toString(),
                            LONGITUDE: _lastMapPosition!.longitude.toString(),
                            RADIUS: roundDistanceInKM.toString(),
                          };
                          if(mounted) {
                            setState(() {
                              showSearchInThisArea = false;
                            });
                          }
                          widget.mapViewListener!(

                              coordinatesMap: coordinatesMap,
                              showWaitingWidget: true
                          );
                        });
                      },
                      label: GenericTextWidget(
                          UtilityMethods.getLocalizedString("search_in_this_area"),
                          style: AppThemePreferences().appTheme.filterPageChoiceChipTextStyle,
                      ),
                    ),
                  ),

            if (widget.showWaitingWidget)
              Container(
                margin: const EdgeInsets.only(top: 160),
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: BallBeatLoadingWidget(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  static double findDistance(double lat1, double lon1, double lat2, double lon2){
    double distance = Geolocator.distanceBetween(
        lat1,
        lon1,
        lat2,
        lon2
    );
    return distance / 1000;
  }
}




// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:houzi_package/files/app_preferences/app_preferences.dart';
// import 'package:houzi_package/models/article.dart';
//
// import '../common/constants.dart';
// import '../files/generic_methods/general_notifier.dart';
// import '../files/generic_methods/utility_methods.dart';
// import '../widgets/data_loading_widget.dart';
// import '../widgets/generic_text_widget.dart';
//
// class Place with ClusterItem {
//   final String name;
//   final LatLng latLng;
//
//   Place({this.name, this.latLng});
//
//   @override
//   LatLng get location => latLng;
// }
//
// typedef MapViewListener = void Function(Map<String,String> coordinatesMap, bool stickToIndex);
// class MapView extends StatefulWidget {
//
//   final List<dynamic> _listArticles;
//   final MapViewListener mapViewListener;
//   bool showWaitingWidget;
//
//   MapView(this._listArticles, {Key key, this.mapViewListener,this.showWaitingWidget}) : super(key: key);
//
//   int _selectedArticleIndex = -1;
//   int _lastSelectedIndex = -1;
//
//   bool _showAllMap = false;
//   bool _snapCameraToSelectedIndex = false;
//
//
//   set snapCameraToSelectedIndex(bool value) {
//     _snapCameraToSelectedIndex = value;
//   }
//
//   set showAllMap(bool value) {
//     _showAllMap = value;
//   }
//
//   set selectedArticleIndex(int value) {
//     // _lastSelectedIndex = _selectedArticleIndex;
//     _selectedArticleIndex = value;
//   }
//
//   set lastSelectedIndex(int value) {
//     _lastSelectedIndex = value;
//   }
//
//   @override
//   State<MapView> createState() => _MapViewState();
// }
//
// class _MapViewState extends State<MapView> with AutomaticKeepAliveClientMixin<MapView> {
//
//   // GeoCode geoCode = GeoCode();
//
//   bool showSearchInThisArea = false;
//
//   double mapZoom = 11;//11;
//   bool showMap = true;
//
//   Set<Marker> googleMapMarkers = {};
//
//   List<String> addressCoordinatesList = [];
//   final _initialCameraPosition =
//   // CameraPosition(target: LatLng(48.856613, 2.352222), zoom: 12.0);
//   CameraPosition(target: LatLng(37.4219999, -122.0862462), zoom: 14,);
//   GoogleMapController _googleMapController;
//   Completer<GoogleMapController> _controller = Completer();
//   LatLng _lastMapPosition;
//   int counter = 0;
//   int latestLatInInt;
//   int latestLngInInt;
//
//   bool mapViewAll = true;
//
//   double x0, x1, y0, y1;
//   GoogleMap map, tempMap;
//   ClusterManager manager;
//
//   VoidCallback generalNotifierListener;
//
//
//   @override
//   void initState() {
//
//
//
//     setupMarkersIfPossible();
//     manager = _initClusterManager();
//     super.initState();
//
//     // if (GeneralNotifier().change == GeneralNotifier.DATA_FETCH_FROM_API) {
//     //     setupMarkersIfPossible();
//     // }
//     //
//     // GeneralNotifier().addListener(generalNotifierListener);
//
//   }
//
//   List<Place> items = [];
//   int itemsListLength = 0;
//
//   ClusterManager _initClusterManager() {
//     return ClusterManager<Place>(items, _updateMarkers, markerBuilder: _markerBuilder,levels: [1, 3, 5, 7, 9, 11, 13, 15, 17]);
//   }
//
//   void _updateMarkers(Set<Marker> markers) {
//     print('Updated ${markers.length} markers');
//     setState(() {
//       googleMapMarkers = markers;
//     });
//   }
//
//   Future<Marker> Function(Cluster<dynamic>) get _markerBuilder {
//     return (cluster) async {
//       // print("location: ${cluster.location}");
//       return Marker(
//         markerId: MarkerId(cluster.getId()),
//         position: cluster.location,
//         onTap: () {
//           // print('---- $cluster');
//           for (var p in cluster.items) {
//             // print(p);
//           }
//         },
//         icon: cluster.count != 1 ?  await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
//             text: cluster.isMultiple ? cluster.count.toString() : null) : BitmapDescriptor.defaultMarker
//         // await BitmapDescriptor.fromAssetImage(
//         //     ImageConfiguration(size: Size(96, 96)),
//         //     'assets/location.jpg'),
//       );
//     };
//   }
//
//   Future<BitmapDescriptor> _getMarkerBitmap(int size, {String text}) async {
//     if (kIsWeb) size = (size / 2).floor();
//
//     final PictureRecorder pictureRecorder = PictureRecorder();
//     final Canvas canvas = Canvas(pictureRecorder);
//     final Paint paint1 = Paint()..color = Colors.orange;
//     final Paint paint2 = Paint()..color = Colors.white;
//
//     canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
//     canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
//     canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);
//
//     if (text != null) {
//       TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
//       painter.text = TextSpan(
//         text: text,
//         style: TextStyle(
//             fontSize: size / 3,
//             color: Colors.white,
//             fontWeight: FontWeight.normal),
//       );
//       painter.layout();
//       painter.paint(
//         canvas,
//         Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
//       );
//     }
//
//     final img = await pictureRecorder.endRecording().toImage(size, size);
//     final data = await img.toByteData(format: ImageByteFormat.png);
//
//     return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
//   }
//
//   setupMarkersIfPossible() {
//    // googleMapMarkers.clear();
//
//     widget._listArticles.map((mapItem) {
//       Article item = mapItem;
//       final heroId = item.id.toString() + "-marker";
//       final propId = item.id;
//       var address = item.address.coordinates.toString();
//       if ((address != null) && (address.isNotEmpty) && (address != ',')) {
//         var temp = address.split(",");
//
//         double lat = double.parse(temp[0]);
//         double lng = double.parse(temp[1]);
//         latestLatInInt = lat.toInt();
//         latestLngInInt = lng.toInt();
//         if (x0 == null) {
//           x0 = x1 = lat;
//           y0 = y1 = lng;
//         } else {
//           if (lat > x1) x1 = lat;
//           if (lat < x0) x0 = lat;
//           if (lng > y1) y1 = lng;
//           if (lng < y0) y0 = lng;
//         }
//
//         // Marker marker = Marker(
//         //     markerId: MarkerId(heroId),
//         //     position: LatLng(lat, lng),
//         //     infoWindow: InfoWindow(
//         //         title: item.title.toString(),
//         //         onTap: () {
//         //           Navigator.push(
//         //             context,
//         //             MaterialPageRoute(
//         //               builder: (context) => PropertyDetailsPage(
//         //                   propertyID: propId, heroId: heroId),
//         //             ),
//         //           );
//         //         }));
//
//         items.add(Place(
//             name: heroId,
//             latLng: LatLng(lat, lng)));
//         if(mounted) {
//           setState(() {});
//         }
//       }
//     }).toList();
//
//     if (items != null && items.isNotEmpty) {
//       print(items.length);
//       print("calling UPDATE");
//
//       manager.setItems(items);
//       if(items.length != itemsListLength) {
//           itemsListLength = items.length;
//
//       }
//
//     }
//
//     //manager = _initClusterManager();
//
//     // if (x1 != null && x0 != null && y1 != null && x0 != null) {
//     //   LatLngBounds latLngBounds =
//     //   LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
//     //   if (_googleMapController != null) {
//     //     CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(latLngBounds, 190.0);
//     //     _googleMapController.animateCamera(cameraUpdate);
//     //     // setState(() {
//     //     //   // showSearchInThisArea = false;
//     //     //   // widget._enableCameraMovement = false;
//     //     // });
//     //   }
//     // }
//     // if (widget._snapCameraToSelectedIndex) {
//     //   if (x1 != null && x0 != null && y1 != null && x0 != null) {
//     //     LatLngBounds latLngBounds =
//     //         LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
//     //     if (_googleMapController != null) {
//     //       CameraUpdate cameraUpdate =
//     //           CameraUpdate.newLatLngBounds(latLngBounds, 190.0);
//     //       _googleMapController.animateCamera(cameraUpdate);
//     //       setState(() {
//     //         // showSearchInThisArea = false;
//     //         // widget._enableCameraMovement = false;
//     //       });
//     //
//     //     }
//     //   }
//     // }
//
//   }
//
//   @override
//   void dispose() {
//
//     if(_googleMapController != null){
//       _googleMapController.dispose();
//     }
//     super.dispose();
//   }
//
//   GoogleMapController getController() {
//     return _googleMapController;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     showMap = widget._showAllMap;
//     if(widget._listArticles.length!=null && widget._listArticles.length != itemsListLength) {
//       setupMarkersIfPossible();
//
//     }
//
//
//     map = GoogleMap(
//       myLocationButtonEnabled: false,
//       zoomGesturesEnabled: true,
//       tiltGesturesEnabled: false,
//       zoomControlsEnabled: true,
//
//       onMapCreated: (controller) {
//         _controller.complete(controller);
//         manager.setMapId(controller.mapId);
//         _googleMapController = controller;
//         // return _googleMapController;
//       },
//       onCameraMove:(CameraPosition cameraPosition){
//
//         manager.onCameraMove(cameraPosition,forceUpdate: true);
//         mapZoom = cameraPosition.zoom;
//         _lastMapPosition = cameraPosition.target;
//         if (cameraPosition.target.latitude.toInt() != latestLatInInt
//             && cameraPosition.target.longitude.toInt() != latestLngInInt){
//           showSearchInThisArea = true;
//         }
//         // print("camera pos lat: ${cameraPosition.target.latitude.toInt()}");
//         // print("camera pos lng: ${cameraPosition.target.longitude.toInt()}");
//         // print("latestLatInInt: ${latestLatInInt}");
//         // print("latestLngInInt: ${latestLngInInt}");
//
//         widget._snapCameraToSelectedIndex = false;
//
//       },
//       // onCameraIdle: (){
//       //
//       //   if(mounted){
//       //     setState(() {});
//       //   }
//       //   manager.updateMap;
//       // },
//       onCameraIdle: manager.updateMap,
//
//       markers: googleMapMarkers,
//       initialCameraPosition: _initialCameraPosition,
//
//     );
//
//
//
//     if (_googleMapController != null) {
//       if (widget._lastSelectedIndex != -1 && widget._listArticles!=null && widget._listArticles.isNotEmpty
//           && widget._listArticles.length > widget._lastSelectedIndex) {
//
//         var item = widget._listArticles[widget._lastSelectedIndex];
//
//         final heroId = item.id.toString() + "-marker";
//         var address = item.address.coordinates.toString();
//         if ((address != null) && (address.isNotEmpty) && (address != ',')) {
//           _googleMapController.hideMarkerInfoWindow(MarkerId(heroId));
//         }
//       }
//
//       if (widget._snapCameraToSelectedIndex && widget._selectedArticleIndex >= 0 && widget._listArticles!=null && widget._listArticles.isNotEmpty
//           && widget._listArticles.length > widget._lastSelectedIndex) {
//         var item = widget._listArticles[widget._selectedArticleIndex];
//         final heroId = item.id.toString() + "-marker";
//
//         var address = item.address.coordinates.toString();
//         if ((address != null) && (address.isNotEmpty) && (address != ',')) {
//           _googleMapController.showMarkerInfoWindow(MarkerId(heroId));
//           var temp = address.split(",");
//           var location = CameraPosition(
//               target: LatLng(double.parse(temp[0]), double.parse(temp[1])), zoom: mapZoom);
//
//           latestLatInInt = double.parse(temp[0]).toInt();
//           latestLngInInt = double.parse(temp[1]).toInt();
//
//           // print("property: latlng: $latestLatInInt, $latestLngInInt");
//           _googleMapController.animateCamera(CameraUpdate.newCameraPosition(location));
//           // if(widget._snapCameraToSelectedIndex){
//           //   var location = CameraPosition(
//           //       target: LatLng(double.parse(temp[0]), double.parse(temp[1])), zoom: mapZoom);
//           //   _googleMapController.animateCamera(CameraUpdate.newCameraPosition(location));
//           //   // setState(() {
//           //   //   widget._enableCameraMovement = false;
//           //   //  // showSearchInThisArea = true;
//           //   // });
//           //
//           // }
//         }
//
//       }
//     }
//
//     if (showMap == true) {
//       if(x1 != null && x0 != null && y1 != null && x0 != null){
//         LatLngBounds latLngBounds = LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
//         if (_googleMapController != null) {
//           CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(latLngBounds, 190.0);
//           // _googleMapController.moveCamera(cameraUpdate);
//           _googleMapController.animateCamera(cameraUpdate);
//         }
//       }
//     }
//
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           map,
//           showSearchInThisArea
//               ? Container(
//                   margin: const EdgeInsets.only(top: 100),
//                   alignment: Alignment.topCenter,
//                   child: FloatingActionButton.extended(
//                     backgroundColor: AppThemePreferences().appTheme.searchBarBackgroundColor,
//                     onPressed: () {
//                       var visibleRegion = _googleMapController.getVisibleRegion();
//                       visibleRegion.then((value) {
//                         var distance = Geolocator.distanceBetween(
//                             value.northeast.latitude,
//                             value.northeast.longitude,
//                             value.southwest.latitude,
//                             value.southwest.longitude);
//
//                         double distanceInKiloMeters = distance / 1000;
//                         double roundDistanceInKM = double.parse((distanceInKiloMeters).toStringAsFixed(2));
//
//                         Map<String, String> coordinatesMap = {
//                           LATITUDE: _lastMapPosition.latitude.toString(),
//                           LONGITUDE: _lastMapPosition.longitude.toString(),
//                           RADIUS: roundDistanceInKM.toString(),
//                         };
//                         widget.mapViewListener(coordinatesMap, false);
//                         if(mounted) {
//                           setState(() {
//                             widget.showWaitingWidget = true;
//                             showSearchInThisArea = false;
//                             widget._snapCameraToSelectedIndex = false;
//                           });
//                         }
//                       });
//                     },
//                     label: genericTextWidget(
//                         GenericMethods.getLocalizedString("search_in_this_area"),
//                         style: AppThemePreferences().appTheme.filterPageChoiceChipTextStyle,
//                     ),
//                   ),
//                 )
//               : Container(),
//           widget.showWaitingWidget == true
//               ? Container(
//                   margin: const EdgeInsets.only(top: 160),
//                   alignment: Alignment.topCenter,
//                   child: SizedBox(
//                     width: 70,
//                     height: 70,
//                     child: loadingBallBeatWidget(),
//                   ),
//                 )
//               : Container()
//         ],
//       ),
//       // floatingActionButton:
//
//       // builder,
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
//
// }








