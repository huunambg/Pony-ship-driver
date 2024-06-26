import 'package:flutter/material.dart';
import 'package:flutter_driver/pages/login/landingpage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';

class AddDriver extends StatefulWidget {
  const AddDriver({Key? key}) : super(key: key);

  @override
  State<AddDriver> createState() => _AddDriverState();
}

class _AddDriverState extends State<AddDriver> {
  var verifyEmailError = '';
  var error = '';
  bool _loading = true;
  bool _showToast = false;

  TextEditingController name =
      TextEditingController(); //name textediting controller
  TextEditingController email =
      TextEditingController(); //name textediting controller
  TextEditingController mobile =
      TextEditingController(); //name textediting controller
  TextEditingController address =
      TextEditingController(); //name textediting controller

  //navigate
  pop() {
    Navigator.pop(context);
  }

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  countryCode() async {
    var result = await getCountryCode(context);
    if (result == 'success') {
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = true;
      });
    }
  }

  showToast() async {
    setState(() {
      _showToast = true;
    });
    var val = await fleetDriverDetails();
    if (val == 'logout') {
      navigateLogout();
    }

    Future.delayed(const Duration(seconds: 1), () async {
      setState(() {
        _showToast = false;
        Navigator.pop(context, true);
      });
      // await fleetDriverDetails();
    });
  }

  @override
  void initState() {
    countryCode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: Directionality(
            textDirection: (languageDirection == 'rtl')
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Stack(
              children: [
                (countries.isNotEmpty)
                    ? Container(
                        padding: EdgeInsets.fromLTRB(
                            media.width * 0.05,
                            MediaQuery.of(context).padding.top +
                                media.width * 0.05,
                            media.width * 0.05,
                            0),
                        height: media.height * 1,
                        width: media.width * 1,
                        color: page,
                        //history details
                        child: Column(children: [
                          Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(bottom: media.width * 0.05),
                                width: media.width * 0.9,
                                alignment: Alignment.center,
                                child: MyText(
                                  text: languages[choosenLanguage]
                                      ['text_add_driver'],
                                  size: media.width * sixteen,
                                  fontweight: FontWeight.bold,
                                ),
                              ),
                              Positioned(
                                  child: InkWell(
                                      onTap: () async {
                                        var val = await fleetDriverDetails();
                                        if (val == 'logout') {
                                          navigateLogout();
                                        } else {
                                          pop();
                                        }
                                      },
                                      child: const Icon(Icons.arrow_back_ios)))
                            ],
                          ),
                          Expanded(
                              child: Column(
                            children: [
                              Container(
                                  height: media.width * 0.13,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: underline),
                                      color: const Color(0xffF8F8F8)),
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: MyTextField(
                                    textController: name,
                                    hinttext: languages[choosenLanguage]
                                        ['text_name'],
                                    onTap: (val) {},
                                  )),
                              SizedBox(
                                height: media.height * 0.02,
                              ),
                              // name input field
                              Container(
                                  height: media.width * 0.13,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: underline),
                                      color: const Color(0xffF8F8F8)),
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: MyTextField(
                                    textController: email,
                                    hinttext: languages[choosenLanguage]
                                        ['text_email'],
                                    onTap: (val) {},
                                  )),
                              SizedBox(
                                height: media.height * 0.02,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                height: 55,
                                width: media.width * 0.9,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: underline),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (countries.isNotEmpty) {
                                          //dialod box for select country for dial code
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                var searchVal = '';
                                                return AlertDialog(
                                                  backgroundColor: page,
                                                  insetPadding:
                                                      const EdgeInsets.all(10),
                                                  content: StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return Container(
                                                      width: media.width * 0.9,
                                                      color: page,
                                                      child: Directionality(
                                                        textDirection:
                                                            (languageDirection ==
                                                                    'rtl')
                                                                ? TextDirection
                                                                    .rtl
                                                                : TextDirection
                                                                    .ltr,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 20,
                                                                      right:
                                                                          20),
                                                              height: 40,
                                                              width:
                                                                  media.width *
                                                                      0.9,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          1.5)),
                                                              child: TextField(
                                                                decoration: InputDecoration(
                                                                    contentPadding: (languageDirection ==
                                                                            'rtl')
                                                                        ? EdgeInsets.only(
                                                                            bottom: media.width *
                                                                                0.035)
                                                                        : EdgeInsets.only(
                                                                            bottom: media.width *
                                                                                0.04),
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        languages[choosenLanguage]
                                                                            [
                                                                            'text_search'],
                                                                    hintStyle: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            media.width * sixteen)),
                                                                onChanged:
                                                                    (val) {
                                                                  setState(() {
                                                                    searchVal =
                                                                        val;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Expanded(
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  children: countries
                                                                      .asMap()
                                                                      .map((i, value) {
                                                                        return MapEntry(
                                                                            i,
                                                                            SizedBox(
                                                                              width: media.width * 0.9,
                                                                              child: (searchVal == '' && countries[i]['flag'] != null)
                                                                                  ? InkWell(
                                                                                      onTap: () {
                                                                                        setState(() {
                                                                                          phcode = i;
                                                                                        });
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                        color: Colors.white,
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            Row(
                                                                                              children: [
                                                                                                Image.network(countries[i]['flag']),
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.02,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.4,
                                                                                                  child: MyText(
                                                                                                    text: countries[i]['name'],
                                                                                                    size: media.width * sixteen,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                          ],
                                                                                        ),
                                                                                      ))
                                                                                  : (countries[i]['flag'] != null && countries[i]['name'].toLowerCase().contains(searchVal.toLowerCase()))
                                                                                      ? InkWell(
                                                                                          onTap: () {
                                                                                            setState(() {
                                                                                              phcode = i;
                                                                                            });
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Container(
                                                                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                            color: Colors.white,
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Row(
                                                                                                  children: [
                                                                                                    Image.network(countries[i]['flag']),
                                                                                                    SizedBox(
                                                                                                      width: media.width * 0.02,
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: media.width * 0.4,
                                                                                                      child: MyText(text: countries[i]['name'], size: media.width * sixteen),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                              ],
                                                                                            ),
                                                                                          ))
                                                                                      : Container(),
                                                                            ));
                                                                      })
                                                                      .values
                                                                      .toList(),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                );
                                              });
                                        } else {
                                          getCountryCode(context);
                                        }
                                        setState(() {});
                                      },
                                      //input field
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.network(
                                                countries[phcode]['flag']),
                                            SizedBox(
                                              width: media.width * 0.02,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              size: 28,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 1,
                                      height: 55,
                                      color: underline,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.bottomCenter,
                                        height: 50,
                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          controller: mobile,
                                          onChanged: (val) {},
                                          maxLength: countries[phcode]
                                              ['dial_max_length'],
                                          style: choosenLanguage == 'ar'
                                              ? GoogleFonts.cairo(
                                                  color: textColor,
                                                  fontSize:
                                                      media.width * sixteen,
                                                  letterSpacing: 1)
                                              : GoogleFonts.poppins(
                                                  color: textColor,
                                                  fontSize:
                                                      media.width * sixteen,
                                                  letterSpacing: 1),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 12),
                                              child: MyText(
                                                text: countries[phcode]
                                                        ['dial_code']
                                                    .toString(),
                                                size: media.width * sixteen,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            hintStyle: choosenLanguage == 'ar'
                                                ? GoogleFonts.cairo(
                                                    color: hintColor,
                                                    fontSize:
                                                        media.width * sixteen,
                                                  )
                                                : GoogleFonts.poppins(
                                                    color: hintColor,
                                                    fontSize:
                                                        media.width * sixteen,
                                                  ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: media.height * 0.02,
                              ),
                              Container(
                                  height: media.width * 0.13,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: underline),
                                      color: const Color(0xffF8F8F8)),
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: MyTextField(
                                    textController: address,
                                    hinttext: languages[choosenLanguage]
                                        ['text_address'],
                                    onTap: (val) {},
                                  )),
                            ],
                          )),
                          (error != '')
                              ? Container(
                                  margin: EdgeInsets.only(
                                      top: media.height * 0.03,
                                      bottom: media.height * 0.03),
                                  alignment: Alignment.center,
                                  width: media.width * 0.8,
                                  child: MyText(
                                    text: error,
                                    size: media.width * sixteen,
                                    color: Colors.red,
                                  ),
                                )
                              : Container(),
                          (name.text.isNotEmpty &&
                                  email.text.isNotEmpty &&
                                  address.text.isNotEmpty &&
                                  mobile.text.isNotEmpty &&
                                  _showToast == false)
                              ? Container(
                                  padding: EdgeInsets.all(media.width * 0.05),
                                  width: media.width * 1,
                                  alignment: Alignment.center,
                                  child: Button(
                                      onTap: () async {
                                        String pattern =
                                            r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])*$";
                                        RegExp regex = RegExp(pattern);
                                        if (regex.hasMatch(email.text)) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          setState(() {
                                            verifyEmailError = '';
                                            error = '';
                                            _loading = true;
                                          });
                                          var result = await validateEmail(
                                              email.text.toString());

                                          if (result == 'success') {
                                            setState(() {
                                              verifyEmailError = '';
                                            });
                                            Map<String, dynamic> map = {
                                              'name': name.text.toString(),
                                              'email': email.text.toString(),
                                              'mobile': mobile.text.toString(),
                                              'address':
                                                  address.text.toString(),
                                              'transport_type':
                                                  userDetails['transport_type']
                                            };
                                            var val = await fleetDriver(map);
                                            if (val == 'true') {
                                              showToast();
                                              serviceLocations.clear();
                                            } else if (val == 'logout') {
                                              navigateLogout();
                                            } else {
                                              error = val.toString();
                                            }
                                          } else {
                                            setState(() {
                                              verifyEmailError =
                                                  result.toString();
                                              error = result.toString();
                                            });
                                            debugPrint('failed');
                                          }
                                          setState(() {
                                            _loading = false;
                                          });
                                        } else {
                                          setState(() {
                                            verifyEmailError =
                                                languages[choosenLanguage]
                                                    ['text_email_validation'];
                                            error = languages[choosenLanguage]
                                                ['text_email_validation'];
                                          });
                                        }
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_next']))
                              : Container(),
                        ]),
                      )
                    : Container(
                        height: media.height * 1,
                        width: media.width * 1,
                        color: page,
                      ),
                (_loading == true)
                    ? const Positioned(top: 0, child: Loading())
                    : Container(),
                (_showToast == true)
                    ? Positioned(
                        bottom: media.height * 0.2,
                        left: media.width * 0.2,
                        right: media.width * 0.2,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(media.width * 0.025),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.transparent.withOpacity(0.6)),
                          child: MyText(
                            text: languages[choosenLanguage]
                                ['text_driver_added'],
                            size: media.width * twelve,
                            color: topBar,
                          ),
                        ))
                    : Container()
              ],
            )));
  }
}
