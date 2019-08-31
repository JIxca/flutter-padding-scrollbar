import 'package:flutter/material.dart';
import 'package:padding_scrollbar/padding_scrollbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaddingScrollbar(
        padding: EdgeInsets.only(top: 56.0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              snap: true,
              forceElevated: true,
              title: Text('Example'),
            ),
            SliverSafeArea(
              top: false,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ListTile(
                      title: Text('Item ${index + 1}'),
                      onTap: () {},
                    );
                  },
                  childCount: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
