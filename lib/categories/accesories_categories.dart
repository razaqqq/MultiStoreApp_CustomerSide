




import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/utilities/categ_list.dart';

import '../widgets/category_widget.dart';

class AccesoriesCategories extends StatefulWidget {
  const AccesoriesCategories({super.key});

  @override
  State<AccesoriesCategories> createState() => _AccesoriesCategoriesState();
}

class _AccesoriesCategoriesState extends State<AccesoriesCategories> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryHeaderLabel(headerLabel: 'accessories',),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: GridView.count(
                      mainAxisSpacing: 70,
                      crossAxisSpacing: 15,
                      crossAxisCount: 2,
                      children: List.generate(accessories.length - 1, (index) {



                        return SubCategoryModel(mainCategoryName: 'accessories', subCategoryName: accessories[index + 1], assetName: 'images/accessories/accessories${index}.jpg', subCategoryLabel: accessories[index + 1],);


                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
              right: 0,
              bottom: 0,
              child: SliderBar(mainCategoryName: 'accessories',))
        ],
      ),
    );
  }
}
