import 'package:flutter/material.dart';
import 'AddedBooks.dart';
import 'RequestedBooks.dart';
import 'PurchasedBooks.dart';

class MyBooks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  indicatorColor: Colors.orangeAccent,
                  tabs: [
                    Text(
                      "Posted",
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      "Requested",
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      "Purchased",
                      style: TextStyle(fontSize: 17),
                    )
                  ],
                ),
                title: Text("My Books"),
                backgroundColor: Colors.lightBlue,
              ),
              body: TabBarView(
                children: [
                  Center(child: AddedBooks()),
                  Center(child: RequestedBooks()),
                  Center(child: PurchasedBooks()),
                ],
              ),
            )));
  }
}
