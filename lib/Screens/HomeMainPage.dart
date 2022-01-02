import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'HomePage/Home.dart';
import 'MyBooksPage/MyBooks.dart';
import 'SearchPage/Search.dart';
import 'SearchPage/Search1.dart';
import 'ProfilePage/Profile.dart';
import 'package:myapp/Screens/constants.dart';

class MyHomeMain extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Sharing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'My App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedPage = 0;
  final _pageOptions = [Home(), MyBooks(), Search(), Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(

      //   title: Text(widget.title),
      // ),
      body: _pageOptions[selectedPage],
      bottomNavigationBar: ConvexAppBar(
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.book, title: 'My Books'),
          TabItem(icon: Icons.search, title: 'Search'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        backgroundColor: Colors.lightBlue,
        initialActiveIndex: 0, //optional, default as 0
        onTap: (int i) {
          setState(() {
            selectedPage = i;
          });
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
