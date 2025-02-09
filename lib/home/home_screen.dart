import 'package:cosmi/screen/wish.dart';
import 'package:flutter/material.dart';
import 'package:cosmi/constants.dart';
import 'package:cosmi/home/widget/cosmetics_full.dart';
import 'package:cosmi/home/widget/popular_cosmetics.dart';

import '../screen/scanner.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cosmi/screen/NotUse/login.dart';
import 'package:cosmi/screen/scanner.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:cosmi/screen/nutrition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _cancelController = TextEditingController(text: 'Cancel');

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;
  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);
  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  void initState() {
    super.initState();
    // _scan();

    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PopularCosmetics(),
              CosmeticsFull(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: mDarkBackgroundColor,
          onPressed: () {
            // scanAndCheckDocument();
            _scan();
          },
          child: Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
          ),
        ));
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: mDarkBackgroundColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Mycosmi',
        style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: Image.asset(
          'assets/images/menu.png',
          width: 24,
        ),
        onPressed: () {},
      ),
      actions: <Widget>[
        IconButton(
          icon: Image.asset(
            'assets/images/cart.png',
            width: 24,
          ),
          onPressed: () {
            Get.to(() => Wish());
          },
        )
      ],
    );
  }

  Future<void> _scan() async {
    try {
      final result = await BarcodeScanner.scan(
        options: ScanOptions(
          strings: {
            'cancel': _cancelController.text,
            'flash_on': _flashOnController.text,
            'flash_off': _flashOffController.text,
          },
          restrictFormat: selectedFormats,
          useCamera: _selectedCamera,
          autoEnableFlash: _autoEnableFlash,
          android: AndroidOptions(
            aspectTolerance: _aspectTolerance,
            useAutoFocus: _useAutoFocus,
          ),
        ),
      );
      setState(() {
        // scanResult = result;
        // doesCollectionExist(scanResult as String);
      });
      bool documentExists =
          await doesDocumentExistInCollection('Products', result.rawContent);

      if (documentExists) {
        // The document exists in the "Products" collection
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('Products')
            .doc(result.rawContent)
            .get();

        print('Document ID: ${documentSnapshot.id}');
        print('Data: ${documentSnapshot.data()}');

        // Navigate to the Nutrition screen with the scanned result
        Get.to(() => Nutrition(result.rawContent));
      } else {
        // The document does not exist in the "Products" collection
        print('Document does not exist.');
        Get.to(() => Nutrition(result.rawContent));
      }
    } on PlatformException catch (e) {
      // setState(() {
      ScanResult(
        rawContent: e.code == BarcodeScanner.cameraAccessDenied
            ? 'The user did not grant the camera permission!'
            : 'Unknown error: $e',
      );
      // });
    }
  }
}
