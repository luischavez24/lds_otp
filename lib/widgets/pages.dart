import 'package:flutter/material.dart';

class Page extends StatelessWidget {
  final PageViewModel viewModel;
  final double percentVisible;

  Page({
    this.viewModel,
    this.percentVisible = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
        width: double.infinity,
        color: viewModel.color,
        child: Opacity(
          opacity: percentVisible,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Transform(
              transform: new Matrix4.translationValues(
                  0.0, 50.0 * (1.0 - percentVisible), 0.0),
              child: new Padding(
                padding: new EdgeInsets.only(bottom: 25.0),
                child: Image.asset(viewModel.heroAssetPath,
                    width: 200.0, height: 200.0),
              ),
            ),
            Transform(
              transform: new Matrix4.translationValues(
                  0.0, 30.0 * (1.0 - percentVisible), 0.0),
              child: new Padding(
                padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: new Text(
                  viewModel.title,
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 34.0,
                  ),
                ),
              ),
            ),
            new Transform(
              transform: new Matrix4.translationValues(
                  0.0, 30.0 * (1.0 - percentVisible), 0.0),
              child: new Padding(
                padding: new EdgeInsets.only(bottom: 75.0),
                child: viewModel.body,
              ),
            ),
          ]),
        ));
  }
}

class PageViewModel {
  final Color color;
  final String heroAssetPath;
  final String title;
  final Widget body;
  final IconData iconData;

  PageViewModel({
    @required
    this.color,
    @required
    this.heroAssetPath,
    @required
    this.title,
    @required
    this.body,
    @required
    this.iconData
  });
}
