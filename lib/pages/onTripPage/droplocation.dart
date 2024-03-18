import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart' as geolocs;
import 'package:permission_handler/permission_handler.dart' as perm;

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/landingpage.dart';
import '../noInternet/nointernet.dart';
import 'map_page.dart';

class DropLocation extends StatefulWidget {
  const DropLocation({Key? key}) : super(key: key);

  @override
  State<DropLocation> createState() => _DropLocationState();
}

List<AddressList> addressList = <AddressList>[];
bool serviceNotAvailable = false;

class _DropLocationState extends State<DropLocation>
    with WidgetsBindingObserver {
  GoogleMapController? _controller;
  late PermissionStatus permission;
  Location location = Location();
  String _state = '';
  bool _isLoading = false;
  String sessionToken = const Uuid().v4();
  final _debouncer = Debouncer(milliseconds: 1000);
  LatLng _center = const LatLng(41.4219057, -102.0840772);
  LatLng centerLocation = const LatLng(41.4219057, -102.0840772);
  TextEditingController search = TextEditingController();
  String favNameText = '';
  bool _locationDenied = false;
  bool favAddressAdd = false;
  bool droplocation = false;
  String dropAddressConfirmation = '';
  bool _error = false;
  TextEditingController username = TextEditingController();
  TextEditingController userphonenumber = TextEditingController();
  dynamic _lastCenter = center;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _controller?.setMapStyle(mapStyle);
    });
  }

  navigate() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Maps()),
        (route) => false);
    setState(() {
      _isLoading = false;
    });
  }

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getLocs();
    addAutoFill.clear();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _controller?.setMapStyle(mapStyle);
      }
    }
  }

//get current location
  getLocs() async {
    permission = await location.hasPermission();

    if (permission == PermissionStatus.denied ||
        permission == PermissionStatus.deniedForever) {
      setState(() {
        _state = '3';
        _isLoading = false;
      });
    } else if (permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited) {
      var locs = await geolocs.Geolocator.getLastKnownPosition();
      if (locs != null) {
        setState(() {
          _center = LatLng(double.parse(locs.latitude.toString()),
              double.parse(locs.longitude.toString()));
          centerLocation = LatLng(double.parse(locs.latitude.toString()),
              double.parse(locs.longitude.toString()));
          _lastCenter = centerLocation;
        });
      } else {
        var loc = await geolocs.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocs.LocationAccuracy.low);
        setState(() {
          _center = LatLng(double.parse(loc.latitude.toString()),
              double.parse(loc.longitude.toString()));
          centerLocation = LatLng(double.parse(loc.latitude.toString()),
              double.parse(loc.longitude.toString()));
          _lastCenter = centerLocation;
        });
      }
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(center, 14.0));
      setState(() {
        _state = '3';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: ValueListenableBuilder(
          valueListenable: valueNotifierHome.value,
          builder: (context, value, child) {
            return Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Container(
                height: media.height * 1,
                width: media.width * 1,
                color: page,
                child: Stack(
                  children: [
                    SizedBox(
                      height: media.height * 1,
                      width: media.width * 1,
                      child: (_state == '3')
                          ? GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: _center,
                                zoom: 14.0,
                              ),
                              onCameraMove: (CameraPosition position) {
                                //pick current location
                                setState(() {
                                  centerLocation = position.target;
                                });
                              },
                              onCameraIdle: () async {
                                setState(() {});
                              },
                              minMaxZoomPreference:
                                  const MinMaxZoomPreference(8.0, 20.0),
                              myLocationButtonEnabled: false,
                              buildingsEnabled: false,
                              zoomControlsEnabled: false,
                              myLocationEnabled: true,
                            )
                          : (_state == '2')
                              ? Container(
                                  height: media.height * 1,
                                  width: media.width * 1,
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 0.6,
                                    height: media.width * 0.3,
                                    decoration: BoxDecoration(
                                        color: page,
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 5,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              spreadRadius: 2)
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          languages[choosenLanguage]
                                              ['text_loc_permission'],
                                          style: GoogleFonts.poppins(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () async {
                                              setState(() {
                                                _state = '';
                                              });
                                              await location
                                                  .requestPermission();
                                              getLocs();
                                            },
                                            child: Text(
                                              languages[choosenLanguage]
                                                  ['text_ok'],
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      media.width * twenty,
                                                  color: buttonColor),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                    ),
                    Positioned(
                        child: Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(
                            height: (media.height / 2) - media.width * 0.08,
                          ),
                          Image.asset(
                            'assets/images/dropmarker.png',
                            width: media.width * 0.07,
                            height: media.width * 0.08,
                          ),
                          SizedBox(
                            height: media.width * 0.025,
                          ),
                          if (_lastCenter != centerLocation)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Button(
                                  onTap: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    var val = await geoCoding(
                                        centerLocation.latitude,
                                        centerLocation.longitude);
                                    setState(() {
                                      _lastCenter = centerLocation;

                                      _center = centerLocation;
                                      dropAddressConfirmation = val;
                                      _isLoading = false;
                                    });
                                  },
                                  text: languages[choosenLanguage]
                                      ['text_confirm'],
                                ),
                              ],
                            ),
                        ],
                      ),
                    )),
                    Positioned(
                        bottom: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              color: page,
                              width: media.width * 1,
                              padding: EdgeInsets.all(media.width * 0.05),
                              child: Column(
                                children: [
                                  Container(
                                      padding: EdgeInsets.fromLTRB(
                                          media.width * 0.03,
                                          media.width * 0.01,
                                          media.width * 0.03,
                                          media.width * 0.01),
                                      height: media.width * 0.1,
                                      width: media.width * 0.9,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              media.width * 0.02),
                                          color: page),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Container(
                                            height: media.width * 0.04,
                                            width: media.width * 0.04,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xffFF0000)
                                                    .withOpacity(0.3)),
                                            child: Container(
                                              height: media.width * 0.02,
                                              width: media.width * 0.02,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xffFF0000)),
                                            ),
                                          ),
                                          SizedBox(width: media.width * 0.02),
                                          Expanded(
                                            child: (dropAddressConfirmation ==
                                                    '')
                                                ? Text(
                                                    languages[choosenLanguage][
                                                        'text_pickdroplocation'],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: media.width *
                                                            twelve,
                                                        color: hintColor),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.7,
                                                        child: Text(
                                                          dropAddressConfirmation,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize:
                                                                media.width *
                                                                    twelve,
                                                            color: textColor,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    height: media.width * 0.1,
                                  ),
                                  Button(
                                      onTap: () async {
                                        if (dropAddressConfirmation != '') {
                                          //remove in envato
                                          if (addressList
                                              .where((element) =>
                                                  element.id == 'drop')
                                              .isEmpty) {
                                            addressList.add(AddressList(
                                                id: 'drop',
                                                address:
                                                    dropAddressConfirmation,
                                                latlng: _center));
                                          } else {
                                            addressList
                                                    .firstWhere((element) =>
                                                        element.id == 'drop')
                                                    .address =
                                                dropAddressConfirmation;
                                            addressList
                                                .firstWhere((element) =>
                                                    element.id == 'drop')
                                                .latlng = _center;
                                          }
                                          if (addressList.length == 2) {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            var val = await etaRequest();
                                            if (val == 'logout') {
                                              navigateLogout();
                                            }
                                            setState(() {
                                              _isLoading = false;
                                              droplocation = true;
                                            });
                                          }
                                        }
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_confirm']),
                                ],
                              ),
                            ),
                          ],
                        )),

                    //autofill address
                    Positioned(
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              media.width * 0.05,
                              MediaQuery.of(context).padding.top + 12.5,
                              media.width * 0.05,
                              0),
                          width: media.width * 1,
                          color: page,
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: media.width * 0.1,
                                      width: media.width * 0.1,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: (isDarkTheme == true)
                                                    ? Colors.white
                                                        .withOpacity(0.2)
                                                    : Colors.black
                                                        .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 2)
                                          ],
                                          color: page),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.arrow_back,
                                          color: textColor),
                                    ),
                                  ),
                                  Container(
                                    height: media.width * 0.1,
                                    width: media.width * 0.75,
                                    padding: EdgeInsets.fromLTRB(
                                        media.width * 0.05,
                                        media.width * 0.02,
                                        media.width * 0.05,
                                        media.width * 0.02),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: (isDarkTheme == true)
                                                  ? Colors.white
                                                      .withOpacity(0.2)
                                                  : Colors.black
                                                      .withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 2)
                                        ],
                                        color: page,
                                        borderRadius: BorderRadius.circular(
                                            media.width * 0.05)),
                                    child: TextField(
                                        controller: search,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                (languageDirection == 'rtl')
                                                    ? EdgeInsets.only(
                                                        bottom:
                                                            media.width * 0.03)
                                                    : EdgeInsets.only(
                                                        bottom: media.width *
                                                            0.042),
                                            border: InputBorder.none,
                                            hintText: languages[choosenLanguage]
                                                ['text_4lettersforautofill'],
                                            hintStyle: GoogleFonts.poppins(
                                                fontSize: media.width * twelve,
                                                color: textColor
                                                    .withOpacity(0.4))),
                                        style: GoogleFonts.poppins(
                                            color: textColor),
                                        maxLines: 1,
                                        onChanged: (val) {
                                          _debouncer.run(() {
                                            if (val.length >= 4) {
                                              if (storedAutoAddress
                                                  .where((element) =>
                                                      element['description']
                                                          .toString()
                                                          .toLowerCase()
                                                          .contains(val
                                                              .toLowerCase()))
                                                  .isNotEmpty) {
                                                addAutoFill.removeWhere(
                                                    (element) =>
                                                        element['description']
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(val
                                                                .toLowerCase()) ==
                                                        false);

                                                storedAutoAddress
                                                    .where((element) =>
                                                        element['description']
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(val
                                                                .toLowerCase()))
                                                    .forEach((element) {
                                                  addAutoFill.add(element);
                                                });
                                                valueNotifierHome
                                                    .incrementNotifier();
                                              } else {
                                                getAutoAddress(
                                                    val,
                                                    sessionToken,
                                                    _center.latitude,
                                                    _center.longitude);
                                              }
                                            } else if (val.isEmpty) {
                                              setState(() {
                                                addAutoFill.clear();
                                              });
                                            }
                                          });
                                        }),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: media.width * 0.05,
                              ),
                              (addAutoFill.isNotEmpty)
                                  ? Container(
                                      height: media.height * 0.45,
                                      padding:
                                          EdgeInsets.all(media.width * 0.02),
                                      width: media.width * 0.9,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              media.width * 0.05),
                                          color: page),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: addAutoFill
                                              .asMap()
                                              .map((i, value) {
                                                return MapEntry(
                                                    i,
                                                    (i < 7)
                                                        ? Container(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0,
                                                                    media.width *
                                                                        0.04,
                                                                    0,
                                                                    media.width *
                                                                        0.04),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  height: media
                                                                          .width *
                                                                      0.1,
                                                                  width: media
                                                                          .width *
                                                                      0.1,
                                                                  child: Icon(
                                                                      Icons
                                                                          .access_time,
                                                                      color:
                                                                          textColor),
                                                                ),
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    var val = await geoCodingForLatLng(
                                                                        addAutoFill[i]
                                                                            [
                                                                            'place_id']);
                                                                    setState(
                                                                        () {
                                                                      _center =
                                                                          val;
                                                                      dropAddressConfirmation =
                                                                          addAutoFill[i]
                                                                              [
                                                                              'description'];

                                                                      _controller?.moveCamera(CameraUpdate.newLatLngZoom(
                                                                          _center,
                                                                          14.0));
                                                                    });
                                                                    addAutoFill
                                                                        .clear();
                                                                    FocusManager
                                                                        .instance
                                                                        .primaryFocus
                                                                        ?.unfocus();
                                                                  },
                                                                  child:
                                                                      SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.75,
                                                                    child: MyText(
                                                                        text: addAutoFill[i]
                                                                            [
                                                                            'description'],
                                                                        size: media.width *
                                                                            twelve,
                                                                        maxLines:
                                                                            2),
                                                                  ),
                                                                ),
                                                              ],
                                                            ))
                                                        : Container());
                                              })
                                              .values
                                              .toList(),
                                        ),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        )),
                    (droplocation == true && etaDetails.isNotEmpty)
                        ? Positioned(
                            bottom:
                                0 + MediaQuery.of(context).viewInsets.bottom,
                            child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    // height: media.width * 0.7,
                                    width: media.width * 1,
                                    color: page,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              width: media.width * 0.05,
                                              child: Image.asset(
                                                'assets/images/cash.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            SizedBox(
                                              width: media.width * 0.02,
                                            ),
                                            Text(
                                              userDetails['currency_symbol'] +
                                                  ' ',
                                              style: GoogleFonts.poppins(
                                                  color: textColor),
                                            ),
                                            Text(
                                              etaDetails['total']
                                                  .toStringAsFixed(2),
                                              style: GoogleFonts.poppins(
                                                  color: textColor),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: media.width * 0.05,
                                              width: media.width * 0.05,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.green),
                                              child: Container(
                                                height: media.width * 0.025,
                                                width: media.width * 0.025,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white
                                                        .withOpacity(0.8)),
                                              ),
                                            ),
                                            SizedBox(
                                              width: media.width * 0.06,
                                            ),
                                            Expanded(
                                              child: MyText(
                                                text: addressList
                                                    .firstWhere((element) =>
                                                        element.id == 'pickup')
                                                    .address,
                                                maxLines: 2,
                                                fontweight: FontWeight.w600,
                                                size: media.width * twelve,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: media.width * 0.02,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: media.width * 0.05,
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: media.width * 0.018,
                                                width: media.width * 0.018,
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFFF0000)),
                                              ),
                                            ),
                                            Container(
                                              height: media.width * 0.03,
                                              width: media.width * 0.05,
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: media.width * 0.009,
                                                width: media.width * 0.009,
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFFF0000)),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: media.width * 0.06,
                                                  width: media.width * 0.06,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red
                                                          .withOpacity(0.1)),
                                                  child: Icon(
                                                    Icons.location_on_outlined,
                                                    color:
                                                        const Color(0xFFFF0000),
                                                    size:
                                                        media.width * eighteen,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: media.width * 0.05,
                                                ),
                                                Expanded(
                                                  child: MyText(
                                                    text: addressList
                                                        .firstWhere((element) =>
                                                            element.id ==
                                                            'drop')
                                                        .address,
                                                    maxLines: 2,
                                                    fontweight: FontWeight.w600,
                                                    size: media.width * twelve,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Container(
                                          height: media.width * 0.1,
                                          width: media.width * 0.75,
                                          padding: EdgeInsets.fromLTRB(
                                              media.width * 0.05,
                                              0,
                                              media.width * 0.05,
                                              0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1.5),
                                              color: page,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      media.width * 0.02)),
                                          child: TextField(
                                            controller: username,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    (languageDirection == 'rtl')
                                                        ? EdgeInsets.only(
                                                            bottom:
                                                                media.width *
                                                                    0.03)
                                                        : EdgeInsets.only(
                                                            bottom:
                                                                media.width *
                                                                    0.042),
                                                border: InputBorder.none,
                                                hintText:
                                                    languages[choosenLanguage]
                                                        ['text_name'],
                                                hintStyle: GoogleFonts.poppins(
                                                    fontSize:
                                                        media.width * twelve,
                                                    color: textColor
                                                        .withOpacity(0.4))),
                                            style: GoogleFonts.poppins(
                                                color: textColor),
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Container(
                                          height: media.width * 0.1,
                                          width: media.width * 0.75,
                                          padding: EdgeInsets.fromLTRB(
                                              media.width * 0.05,
                                              0,
                                              media.width * 0.05,
                                              0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1.5),
                                              color: page,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      media.width * 0.02)),
                                          child: TextField(
                                            controller: userphonenumber,
                                            keyboardType: TextInputType.number,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    (languageDirection == 'rtl')
                                                        ? EdgeInsets.only(
                                                            bottom:
                                                                media.width *
                                                                    0.03)
                                                        : EdgeInsets.only(
                                                            bottom:
                                                                media.width *
                                                                    0.042),
                                                border: InputBorder.none,
                                                hintText:
                                                    languages[choosenLanguage]
                                                        ['text_phone_number'],
                                                hintStyle: GoogleFonts.poppins(
                                                    fontSize:
                                                        media.width * twelve,
                                                    color: textColor
                                                        .withOpacity(0.4))),
                                            style: GoogleFonts.poppins(
                                                color: textColor),
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.04,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Button(
                                                width: media.width * 0.4,
                                                onTap: () {
                                                  setState(() {
                                                    droplocation = false;
                                                  });
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_cancel']),
                                            Button(
                                                width: media.width * 0.4,
                                                onTap: () async {
                                                  if (username
                                                          .text.isNotEmpty &&
                                                      userphonenumber
                                                          .text.isNotEmpty) {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    setState(() {
                                                      _error = false;
                                                      _isLoading = true;
                                                    });
                                                    var val =
                                                        await createRequest(
                                                            username.text,
                                                            userphonenumber
                                                                .text);
                                                    if (val == 'success') {
                                                      navigate();
                                                    } else if (val ==
                                                        'logout') {
                                                      navigateLogout();
                                                    } else {
                                                      _error = true;
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                    }
                                                  }
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_ridenow']),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        // )
                        : Container(),

                    (_locationDenied == true)
                        ? Positioned(
                            child: Container(
                            height: media.height * 1,
                            width: media.width * 1,
                            color: Colors.transparent.withOpacity(0.6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: media.width * 0.9,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _locationDenied = false;
                                          });
                                        },
                                        child: Container(
                                          height: media.height * 0.05,
                                          width: media.height * 0.05,
                                          decoration: BoxDecoration(
                                            color: page,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.cancel,
                                              color: buttonColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: media.width * 0.025),
                                Container(
                                  padding: EdgeInsets.all(media.width * 0.05),
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: page,
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 2.0,
                                            spreadRadius: 2.0,
                                            color:
                                                Colors.black.withOpacity(0.2))
                                      ]),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          width: media.width * 0.8,
                                          child: Text(
                                            languages[choosenLanguage]
                                                ['text_open_loc_settings'],
                                            style: GoogleFonts.poppins(
                                                fontSize: media.width * sixteen,
                                                color: textColor,
                                                fontWeight: FontWeight.w600),
                                          )),
                                      SizedBox(height: media.width * 0.05),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                              onTap: () async {
                                                await perm.openAppSettings();
                                              },
                                              child: Text(
                                                languages[choosenLanguage]
                                                    ['text_open_settings'],
                                                style: GoogleFonts.poppins(
                                                    fontSize:
                                                        media.width * sixteen,
                                                    color: buttonColor,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )),
                                          InkWell(
                                              onTap: () async {
                                                setState(() {
                                                  _locationDenied = false;
                                                  _isLoading = true;
                                                });

                                                getLocs();
                                              },
                                              child: Text(
                                                languages[choosenLanguage]
                                                    ['text_done'],
                                                style: GoogleFonts.poppins(
                                                    fontSize:
                                                        media.width * sixteen,
                                                    color: buttonColor,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ))
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ))
                        : Container(),

                    //error
                    (_error == true)
                        ? Positioned(
                            top: 0,
                            child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: page),
                                    child: Column(
                                      children: [
                                        Text(
                                          languages[choosenLanguage]
                                              ['text_somethingwentwrong'],
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              fontSize: media.width * sixteen,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Button(
                                            onTap: () async {
                                              setState(() {
                                                _error = false;
                                              });
                                            },
                                            text: languages[choosenLanguage]
                                                ['text_ok'])
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        : Container(),

                    //loader
                    (_isLoading == true)
                        ? const Positioned(child: Loading())
                        : Container(),
                    (internet == false)
                        ?

                        //no internet
                        Positioned(
                            top: 0,
                            child: NoInternet(
                              onTap: () {
                                setState(() {
                                  internetTrue();
                                });
                              },
                            ))
                        : Container()
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class Debouncer {
  final int milliseconds;
  dynamic action;
  dynamic _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
