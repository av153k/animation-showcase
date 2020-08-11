import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainCard extends StatefulWidget {
  final String name;

  MainCard({
    Key key,
    @required this.name,
  }) : super(key: key);

  @override
  _MainCardState createState() => _MainCardState();
}

class _MainCardState extends State<MainCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        color: Colors.white,
        elevation: 12,
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.3,
            child: Text(
              widget.name,
              style: TextStyle(fontSize: 30, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}
