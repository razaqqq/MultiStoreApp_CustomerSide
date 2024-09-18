




import 'package:flutter/material.dart';

import '../main_screen/minor_screen/sub_categories_product.dart';

class SliderBar extends StatelessWidget {
  final String mainCategoryName;
  const SliderBar({
    super.key, required this.mainCategoryName
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.05,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.brown.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50)),
          child: RotatedBox(quarterTurns: 3, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              mainCategoryName == 'beauty' ? const Text('') : const Text(' << ', style: style,),
              Text(mainCategoryName.toUpperCase(), style: style,),
              mainCategoryName == 'men' ? const Text('') : Text('>>'.toUpperCase(), style: style,),
            ],
          ),),
        ),
      ),
    );
  }
}

const style = TextStyle(color: Colors.brown, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 10);

class SubCategoryModel extends StatelessWidget {

  final String mainCategoryName;
  final String subCategoryName;
  final String assetName;
  final String subCategoryLabel;

  const SubCategoryModel({
    super.key, required this.mainCategoryName, required this.subCategoryName, required this.assetName, required this.subCategoryLabel
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubCategoryProduct(
                  mainCategoryName: mainCategoryName,
                  subCategoryName: subCategoryName),
            ));
      },
      child: Column(children: [
        SizedBox(
          height: 70,
          width: 70,
          child: Image(
            image: AssetImage(assetName),
          ),
        ),
        Text(subCategoryLabel)
      ]),
    );
  }
}

class CategoryHeaderLabel extends StatelessWidget {

  final String headerLabel;

  CategoryHeaderLabel({
    super.key, required this.headerLabel
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.all(30.0),
        child: Text(
          headerLabel,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ));
  }
}