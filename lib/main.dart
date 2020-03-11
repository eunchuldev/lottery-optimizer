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
  final List<String> titleList = ["북마크", "로또번호 분산기", "안내"];
  String title = "로또번호 분산기";
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScopedModel<AppState>(
      model: model,
      child: MaterialApp(
        home: DefaultTabController(
          length: 3,
          initialIndex: 1,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.star)),
                  Tab(icon: Icon(Icons.grain)),
                  Tab(icon: Icon(Icons.help)),
                ],
                onTap: (index) => setState(()=>title = titleList[index]),
              ),
              title: Text(title),
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
          primarySwatch: MyColor,
          splashFactory: InkRipple.splashFactory,
          textTheme: TextTheme(
            bodyText2: TextStyle(fontSize: 15.0)
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
    //nonPersonalizedAds: true,
    childDirected: false,
    designedForFamilies: false,
    keywords: <String>['Lottery', 'Powerball', 'Gambling', 'Jackpot'],
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
    });

  @override
  void initState() {
    super.initState();
    /*FirebaseAdMob.instance.initialize(appId: appId);
    _bannerAd = bannerAd()
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
      );*/
  }
  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }
  @override
  bool get wantKeepAlive => true;
}

MaterialColor MyColor = MaterialColor(0xff00a180, 
<int, Color> {
  50:Color(0xff00a180),
  100:Color(0xff00a180),
  200:Color(0xff00a180),
  300:Color(0xff00a180),
  400:Color(0xff00a180),
  500:Color(0xff00a180),
  600:Color(0xff00a180),
  700:Color(0xff00a180),
  800:Color(0xff00a180),
  900:Color(0xff00a180),
});
