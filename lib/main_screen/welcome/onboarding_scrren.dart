import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/customer_screen/hot_deals.dart';
import 'package:multi_store_app_customer/galleries/shoes_gallery.dart';
import 'package:multi_store_app_customer/main_screen/minor_screen/sub_categories_product.dart';
import 'package:multi_store_app_customer/profiders/id_provider.dart';
import 'package:provider/provider.dart';

enum Offer { menShirt, shoes, sale }

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {
  Timer? countDownTimer;
  int seconds = 3;
  List<int> discountList = [];
  int? maxDiscount;
  late int selectedIndex;
  late String offerName;
  late String assetName;
  late Offer offer;
  late AnimationController _animationController;
  late Animation<Color?> _colorTweenAnimation;

  @override
  void initState() {
    selectRandomOffer();
    startTimer();
    getDiscount();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(microseconds: 600));

    _colorTweenAnimation =
        ColorTween(begin: null, end: Colors.red).animate(_animationController)
          ..addListener(() {
            setState(() {});
          });

    _animationController.repeat();

    context.read<IdProvider>().getDocId();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void selectRandomOffer() {
    // [1= men_shirt, 2= Shoes, 3= sale]
    for (var i = 0; i < Offer.values.length; i++) {
      var random = Random();
      setState(() {
        selectedIndex = random.nextInt(3);
        offerName = Offer.values[selectedIndex].toString();
        assetName = offerName.replaceAll("Offer.", "");
        offer = Offer.values[selectedIndex];
      });
    }

    print(selectedIndex);
  }

  void startTimer() {
    countDownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds--;
      });
      if (seconds == 0) {
        stopTimer();
        Navigator.pushReplacementNamed(context, '/customer_home');
      }
    });
  }

  void stopTimer() {
    countDownTimer!.cancel();
  }

  Widget buildAsset() {
    return SizedBox(width: double.infinity, height: double.infinity,child: Image.asset('images/onboarding/nature_$selectedIndex.jpg', fit: BoxFit.cover,));
  }

  void navigateToOffer() {
    switch (offer) {
      case Offer.menShirt:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SubCategoryProduct(
              mainCategoryName: 'men',
              subCategoryName: 'shirt',
              fromOnBoarding: true,
            ),
          ),
          (route) {
            return false;
          },
        );
        break;
      case Offer.shoes:
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  const ShoesGalleryScreen(fromOnBoarding: true),
            ),
            (route) => false);
        break;
      case Offer.sale:
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HotDeals(
                  maxDiscount: maxDiscount.toString(), fromOnBoarding: true),
            ),
            (route) => false);
        break;
    }
  }

  void getDiscount() {
    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        discountList.add(doc['discount']);
      }
    }).whenComplete(() => setState(() {
              maxDiscount = discountList.reduce(max);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
              onTap: () {
                stopTimer();
                navigateToOffer();
              },
              child: buildAsset()),
          Positioned(
            top: 60,
            right: 30,
            child: Container(
              width: 100,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: MaterialButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/customer_home');
                },
                child: seconds < 0 ? Text('Skip') : Text('Skip | $seconds'),
              ),
            ),
          ),
          offer == Offer.sale
              ? Positioned(
                  top: 180,
                  right: 74,
                  child: AnimatedOpacity(
                    duration: const Duration(microseconds: 100),
                    opacity: _animationController.value,
                    child: Text(
                      maxDiscount.toString() + ('%'),
                      style: const TextStyle(
                          fontSize: 100,
                          color: Colors.amber,
                          fontFamily: 'Akaya'),
                    ),
                  ),
                )
              : const SizedBox(),
          Positioned(
              bottom: 70,
              child: AnimatedBuilder(
                  animation: _animationController.view,
                  child: const Center(
                      child: Text(
                    'SHOP NOW',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  )),
                  builder: (context, child) {
                    return Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      color: _colorTweenAnimation.value,
                      child: child,
                    );
                  }))
        ],
      ),
    );
  }
}
