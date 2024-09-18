import 'package:flutter/material.dart';
import 'package:multi_store_app_customer/widgets/appbar_widgets.dart';

class FullScreenView extends StatefulWidget {
  final List<dynamic> imageList;

  const FullScreenView({super.key, required this.imageList});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {

  final PageController _pageViewController = PageController();

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    int index = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const AppBarBackButton(color: Colors.black,),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Text(
                ('${index + 1}') + ('/') + (widget.imageList.length.toString()),
                style: TextStyle(fontSize: 24, letterSpacing: 8),
              ),
            ),
            SizedBox(
              height: size.height * 0.5,
              child: PageView(
                onPageChanged: (value) {
                  setState(() {
                    index = value;
                  });
                },
                controller: _pageViewController,
                children: generateImages()
              ),
            ),
            SizedBox(
              height: size.height * 0.2,
              child: imageView()
            )
          ],
        ),
      ),
    );
  }

  Widget imageView() {
    return ListView.builder(
      itemCount: widget.imageList.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){
            _pageViewController.jumpToPage(index);
          },
          child: Container(
              margin: EdgeInsets.all(8),
              width: 120,
              decoration: BoxDecoration(
                  border: Border.all(width: 4, color: Colors.teal),
                  borderRadius: BorderRadius.circular(15)),
              child: ClipRRect(borderRadius: BorderRadius.circular(10),child: Image.network(widget.imageList[index].toString(),fit: BoxFit.cover,))),
        );
      },
    );
  }

  List<Widget> generateImages() {
    return List.generate(widget.imageList.length, (index) {
      return InteractiveViewer(
        transformationController: TransformationController(),
        child: Image(
          image: NetworkImage(widget.imageList[index]),
          height: double.infinity,
          width: double.infinity,
        ),
      );
    });
  }

}