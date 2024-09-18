import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/categories/accesories_categories.dart';
import 'package:multi_store_app_customer/categories/men_categories.dart';
import 'package:multi_store_app_customer/categories/women_categories.dart';

import 'package:multi_store_app_customer/widgets/fake_search.dart';

import '../../categories/bags_categories.dart';
import '../../categories/beauty_categories.dart';
import '../../categories/electronic_categories.dart';
import '../../categories/homegarden_categories.dart';
import '../../categories/kids_category.dart';
import '../../categories/shoes_category.dart';

List<ItemsData> items = [
  ItemsData(label: 'men'),
  ItemsData(label: 'women'),
  ItemsData(label: 'shoes'),
  ItemsData(label: 'bags'),
  ItemsData(label: 'electronics'),
  ItemsData(label: 'accesories'),
  ItemsData(label: 'home & garden'),
  ItemsData(label: 'kids'),
  ItemsData(label: 'beauty'),
];

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  final PageController _pageController = PageController();

  @override
  void initState() {
    for (var element in items) {
      element.isSelected = false;
    }
    setState(() {
      items[0].isSelected = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0, backgroundColor: Theme.of(context).colorScheme.primary, title: FakeSearch(),),
      body: Stack(children: [
        Positioned(bottom: 0, left: 0, child: sideNavigator(size)),
        Positioned(bottom: 0, right: 0, child: categoryView(size)),
      ],),
    );
  }

  Widget sideNavigator(Size size) {
    return SizedBox(height: size.height * 0.8,
      width: MediaQuery
          .of(context)
          .size
          .width * 0.2,

      child: ListView.builder(
        itemCount: items.length, itemBuilder: (context, index) {
        return GestureDetector(onTap: (){

          _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.bounceIn);



        },child: Container(color: items[index].isSelected == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,height: 100, child: Center(child: Text(items[index].label))));
      },),);
  }

  Widget categoryView(Size size) {
    return Container(height: size.height * 0.8, width: MediaQuery
        .of(context)
        .size
        .width * 0.8, color: Theme.of(context).colorScheme.primary,child: PageView(controller: _pageController,onPageChanged: (index) {
            for (var element in items) {
              element.isSelected = false;
            }
            setState(() {
              items[index].isSelected = true;
            });
        },scrollDirection: Axis.vertical,children: const [
          MenCategory(),
      WomenCategory(),
      ShoesCategory(),
      BagsCategories(),
      ElectronicCategories(),
      AccesoriesCategories(),
      HomeGardenCategories(),
      KidsCategories(),
      BeautyCategories(),
    ],),);
  }


}

class ItemsData {
  String label;
  bool isSelected;
  ItemsData({required this.label, this.isSelected = false});
}



