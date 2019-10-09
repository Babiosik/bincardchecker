import 'dart:convert';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


const appId = "ca-app-pub-6277008188307342~2143436121";
const bannerUnitId = "ca-app-pub-6277008188307342/3811741012";


BannerAd myBanner = BannerAd(
  adUnitId: bannerUnitId,
  size: AdSize.smartBanner,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

void main() {
  FirebaseAdMob.instance.initialize(appId: appId);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bin Card Checker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,

      ),
      home: MyHomePage(title: 'Bin Card Checker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  String _bin;
  CardInfo _card;

  void initState() {
    super.initState();
    myBanner
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  void getBin () {
    setState(() {
      FocusScope.of(context).unfocus();
      _card = null; 
    });
    if (_bin.length == 6) {
      http.get("https://lookup.binlist.net/$_bin")
        .then((http.Response response) {
          if (response.statusCode == 200) {
            dynamic data = jsonDecode(response.body);
            String _scheme = data["scheme"];
            String _type = data["type"];
            dynamic _country = data["country"];
            String _emoji = _country["emoji"];
            String _name = _country["name"];
            String _currency = _country["currency"];
            dynamic _bank = data["bank"];
            String _bankName = _bank["name"];
            setState(() {
              _card = new CardInfo(_scheme, _type, _name, _emoji, _currency, _bankName);              
            });
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Widget card = new Container();
    if (_card != null) {
      card = Center(
        child: Column(
          children: <Widget>[
            _InfoText("Payment system", _card._scheme, upperCase: true),
            _InfoText("Card Type", _card._type, upperCase: true),
            _InfoText("Сountry", _card._countryNname, upperCase: true),
            _InfoText("Flag", _card._countryEmoji),
            _InfoText("Currency", _card._countryCurrency),
            _InfoText("Bank Name", _card._bankName),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Input first 6 number of card',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: size.width - 100,
                    child: TextField(
                      decoration: new InputDecoration(
                        labelText: "Enter your number"
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: (String newBin) {_bin = newBin;},
                      onEditingComplete: getBin,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: getBin,
                  ),
                ],
              ),
            ),
          ),
          card,
        ],
      ),
    );
  }
}

class _InfoText extends StatelessWidget {

  final String _title, _text;
  final bool upperCase;

  const _InfoText(this._title, this._text, {Key key, this.upperCase = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_text == null)
      return Container();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: BorderDirectional(top: BorderSide(color: Colors.grey[600], width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(_title, textAlign: TextAlign.left),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Text((upperCase ? _text.toUpperCase() : _text), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class CardInfo {
  final String _scheme;
  final String _type;
  final String _countryNname;
  final String _countryEmoji;
  final String _countryCurrency;
  final String _bankName;

  CardInfo(this._scheme, this._type, this._countryNname, this._countryEmoji, this._countryCurrency, this._bankName);
}