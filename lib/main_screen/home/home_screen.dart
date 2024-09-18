
import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/galleries/accesories_gallery.dart';
import 'package:multi_store_app_customer/galleries/bag_gallery.dart';
import 'package:multi_store_app_customer/galleries/beauty_gallery.dart';
import 'package:multi_store_app_customer/galleries/electroic_gallery.dart';
import 'package:multi_store_app_customer/galleries/homeandgarden_gallery.dart';
import 'package:multi_store_app_customer/galleries/kids_gallery.dart';
import 'package:multi_store_app_customer/galleries/men_gallery.dart';
import 'package:multi_store_app_customer/galleries/shoes_gallery.dart';
import 'package:multi_store_app_customer/galleries/woman_gallery.dart';

import '../../widgets/fake_search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 9,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            title: const FakeSearch(),
            bottom: TabBar(
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Theme.of(context).colorScheme.secondary,
              indicatorWeight: 8,
              tabs: const [
                RepeatedTab(tabName: "Mens"),
                RepeatedTab(tabName: "Women"),
                RepeatedTab(tabName: "Shoes"),
                RepeatedTab(tabName: "Bags"),
                RepeatedTab(tabName: "Electronics"),
                RepeatedTab(tabName: "Accesories"),
                RepeatedTab(tabName: "Home and Garden"),
                RepeatedTab(tabName: "Kids"),
                RepeatedTab(tabName: "Beuty"),
              ],
            ),
          ),
          body: const TabBarView(children: [
            MenGalleryScreen(),
            WomanGalleryScreen(),
            ShoesGalleryScreen(),
            BagGalleryScreen(),
            ElectronicGalleryScreen(),
            AccesoriesGalleryScreen(),
            HomeGardenGalleryScreen(),
            KidsGardenGalleryScreen(),
            BeautyGalleryScreen(),
          ],),
        ));
  }
  
  
  
}



class RepeatedTab extends StatelessWidget {
  final String tabName;
  const RepeatedTab({super.key, required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Tab(child: Text(tabName, style: TextStyle(color: Colors.grey.shade600, ),),);
  }
}

