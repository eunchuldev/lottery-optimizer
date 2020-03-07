import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'state.dart';
import 'tickets_generator.dart';
import 'favorites.dart';
import 'about.dart';

void main() => runApp(MyApp());


class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyApp();
  }
class _MyApp extends State<MyApp> with AutomaticKeepAliveClientMixin<MyApp> {
  final model = AppState();
  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppState>(
      model: model,
      child: MaterialApp(
        home: DefaultTabController(
          length: 3,
          initialIndex: 1,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.star)),
                  Tab(icon: Icon(Icons.grain)),
                  Tab(icon: Icon(Icons.help)),
                ],
              ),
              title: Text("로또번호 최적화"),
              elevation: 0.0,
            ),
            body: TabBarView(
              children: [
                Favorites(),
                TicketsGenerator(),
                About(),
              ],
            ),
          ),
        ),
        theme: ThemeData(
          primarySwatch: Colors.teal,
          splashFactory: InkRipple.splashFactory,
          textTheme: TextTheme(
            body1: TextStyle(fontSize: 15.0)
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.grey[400],     //  <-- dark color
            //textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
            shape: RoundedRectangleBorder( borderRadius: new BorderRadius.circular(8.0),),
            padding: EdgeInsets.all(9.0),
          ),
        ),
        builder: (context, widget) => Padding( child: widget, padding: EdgeInsets.only(bottom: paddingBottom)),
      ),
    );
  }

  double paddingBottom = 50.0;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    //testDevices: ['MobileId'],
    nonPersonalizedAds: true,
    keywords: <String>['Game', 'Mario'],
  );
  static const appId = "ca-app-pub-1530298900964476~9756147235";
  BannerAd _bannerAd;
  BannerAd bannerAd() => BannerAd(
    adUnitId: "ca-app-pub-1530298900964476/1758786454",
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      if(event == MobileAdEvent.failedToLoad) {
        setState(() {
          paddingBottom = 0.0;
        });
      }
      print("+++++++++++++++++++BannerAd $event");
    });

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(appId: appId);
    _bannerAd = bannerAd()
      ..load()
      ..show();
    super.initState();
  }
  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }
  @override
  bool get wantKeepAlive => true;
}
