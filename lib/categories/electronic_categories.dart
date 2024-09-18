




import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/utilities/categ_list.dart';

import '../widgets/category_widget.dart';

class ElectronicCategories extends StatefulWidget {
  const ElectronicCategories({super.key});

  @override
  State<ElectronicCategories> createState() => _ElectronicCategoriesState();
}

class _ElectronicCategoriesState extends State<ElectronicCategories> {
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
                  CategoryHeaderLabel(headerLabel: 'electronics',),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: GridView.count(
                      mainAxisSpacing: 70,
                      crossAxisSpacing: 15,
                      crossAxisCount: 2,
                      children: List.generate(shoes.length - 1, (index) {
                        return SubCategoryModel(mainCategoryName: 'electronics', subCategoryName: electronics[index + 1], assetName: 'images/electronics/electronics${index}.jpg', subCategoryLabel: electronics[index + 1],);
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
              child: SliderBar(mainCategoryName: 'electronics',))
        ],
      ),
    );
  }
}
