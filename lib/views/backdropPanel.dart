import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sam_status_saver/assets/customColor.dart';
import 'package:sam_status_saver/constants/paths.dart';
import 'package:sam_status_saver/constants/strings.dart';
import 'package:sam_status_saver/providers/providers.dart';

class BackdropPanel extends StatefulWidget {
  BackdropPanel({Key key}) : super(key: key);

  @override
  _BackdropPanelState createState() => _BackdropPanelState();
}

class _BackdropPanelState extends State<BackdropPanel> {
  bool initialise = true;

  bool favGB = false;
  bool favStandard = false;
  bool favBusiness = false;

  double isMessageOpacity = 0.0;
  String infoMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleStandard(favPathProvider) {
    if (Directory(statusPathStandard).existsSync()) {
      setState(() {
        favGB = false;
        favStandard = true;
        favBusiness = false;
      });
      favPathProvider.setFavouritePath(statusPathStandard);
    } else {
      showErrorMessage(1);
    }
  }

  handleBusiness(favPathProvider) {
    if (Directory(statusPathBusiness).existsSync()) {
      setState(() {
        favGB = false;
        favStandard = false;
        favBusiness = true;
      });
      favPathProvider.setFavouritePath(statusPathBusiness);
    } else {
      showErrorMessage(3);
    }
  }

  void showErrorMessage(code) {
    //1 => Standard
    //2 => GB
    //3 => BUsimess

    if (code == 1) {
      setState(() {
        infoMessage =
            "Sorry but you dont have the standard WhatsApp version installed";
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    } else {
      setState(() {
        infoMessage =
            "Sorry but you dont have the WhatsApp Business version installed";
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    }

    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final favPathProvider = Provider.of<StatusDirectoryFavourite>(context);
    if (initialise) {
      if (Provider.of<StatusDirectoryState>(context).directoryExists) {
        initialise = false;
        if (favPathProvider.statusPathsFavourite == statusPathStandard) {
          favStandard = true;
        } else {
          favBusiness = true;
        }
      }
    }

    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('lib/assets/images/BackdropPanel.jpg'),
        )),
        child: Scrollbar(
            child: ListView(children: <Widget>[
          Container(
            color: Colors.white24,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 32.0),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        'lib/assets/images/logo.png',
                        height: 70.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Sam's Status Saver",
                                  textScaleFactor: 1.8,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor)),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Version: 1.0.8",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "Please select your Whatsapp version below to view status",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RaisedButton(
                          color:
                              favStandard ? colorCustom : Colors.grey.shade700,
                          textColor: Colors.white,
                          child: const Text('Standard'),
                          onPressed: () => handleStandard(favPathProvider)),
                      const SizedBox(width: 20),
                      RaisedButton(
                        color: favBusiness ? colorCustom : Colors.grey.shade700,
                        textColor: Colors.white,
                        onPressed: () => handleBusiness(favPathProvider),
                        child: const Text('Business'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: isMessageOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(infoMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 20.0, right: 10.0),
            child: Text(hintMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, top: 20.0, right: 10.0, bottom: 10),
            child: GestureDetector(
              onTap: () => launch(
                  'https://samndirangu.github.io/apps/SamsStatusSaver/privacy-policy.html'),
              child: const Text('Privacy Policy & Terms and Condition',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SaleWidget(),
          const SizedBox(height: 200)
        ])));
  }
}

typedef CallerContentCallBack = dynamic Function(dynamic);

class SaleWidget extends StatelessWidget {
  const SaleWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Made with ',
                style: TextStyle(color: Colors.black87),
              ),
              const Icon(Icons.favorite, color: Colors.red),
              const Text(' by', style: TextStyle(color: Colors.black87))
            ],
          ),
        ),
        Image.asset(
          'lib/assets/images/sakalogo.png',
          height: 200,
        ),
        Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "$sale",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.8,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const Text("$sale2",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87)),
                  const SizedBox(height: 5),
                  RaisedButton.icon(
                    elevation: 5,
                    autofocus: true,
                    textColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                    icon: const Icon(
                      Icons.call,
                      size: 22,
                    ),
                    label: const Text("+254 712 77 8056"),
                    onPressed: () async {
                      await launch('tel:+254712778056');
                    },
                  ),
                  const SizedBox(height: 5),
                  RaisedButton.icon(
                    elevation: 5,
                    autofocus: true,
                    textColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                    icon: const Icon(Icons.mail, size: 22),
                    label: const Text("sakadevsinc@gmail.com"),
                    onPressed: () async {
                      await launch(
                          'mailto:sakadevsinc@gmail.com?subject=Hey there I need an App');
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('SakaDevs Inc © 2020  App made with Flutter',
                      style: TextStyle(color: Colors.black87))
                ])),
      ],
    );
  }
}
