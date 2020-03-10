import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class About extends StatelessWidget {
  final List<String> contacts = [
    "eunchul.dev@gmail.com",
  ];
  Widget topPannel(BuildContext context) =>
    Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),
        ),
      child: Card(
        margin: EdgeInsets.zero,
        //elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        child: Container(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 48.0, bottom: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.school,
                size: 120.0,
                color: Colors.white,
                semanticLabel: '원리',
              ),
              Text("너무 신기해요.\n원리가 무엇인가요?", style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        )),
    );
  Widget middlePannel(BuildContext context) =>
    Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),
        ),
      child: Card(
        margin: EdgeInsets.zero,
        //elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        child: Container(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 32.0, bottom: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.contact_mail,
                size: 120.0,
                color: Colors.white,
                semanticLabel: '연락처',
              ),
              Expanded(child:Center(child:Text("개발팀 연락처", style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold)))),
            ],
          ),
        )),
    );

  final String aboutMarkdown = """
----
# 번호분포와 당첨확률

로또번호를 더 잘 분포시키면 1등을 제외한 2~5등의 당첨확률을 높힐 수 있습니다.  

다음은 로또번호를 무작위로 여러개 골랐을때 벌어지는 현상을 나타내는 그림입니다.
  
![무작위 예시](resource:assets/images/bad_example.png "무작위 예시")

조그만 점으로 표현되는 로또번호들이 커다란 원 위에 균등하게 분포되어있습니다.

보시다시피, 전체 16개의 번호중 13개의 번호가 적어도 5등안에 당첨되므로, 약 81%의 확률로 상금을 타가게됩니다.

그러나 과연 이게 최선의 결과일까요? 화살표 범위를 유심히 관찰하면 범위가 서로 겹치고 있음을 알수있습니다. 예를들어, 첫번째 로또번호가

    1, 2, 3, 4, 5, 6

두번째 로또번호가

    1, 2, 3, 7, 8, 9 

당첨번호가

    1, 2, 3, 10, 11, 12

이라면, 두 로또번호는 해당 당첨번호에 대해 5등안에 중복해서 당첨되게 됩니다.

이러한 현상이 벌어지지 않도록 유의한다면 다음과 같이 번호를 고를수있습니다.

![최적화 예시](resource:assets/images/good_example.png "최적화 예시") 

이제 100%의 확률로 5등 안에 당첨되게 되었습니다!  

이렇듯 더 잘 분포된 로또번호는 무작위로 선정된 로또번호보다 당첨확률을 높혀줄수 있습니다.

----
----
----
# 당첨확률과 기댓값

그러나 당첨확률이 높아진만큼 당첨금액 기댓값이 높아지는건 결코 아닙니다!

극단적인 예로, 똑같은 번호를 100장을 산다고 상상해보세요.

당첨확률은 극도로 낮아지겠지만, 당첨금액 기댓값은 그에 반비례해 높아질 것입니다.

음, 사실 기댓값이 살짝 높아지기는 합니다. 고정된 상금을 받는 4등, 5등을 제외한 등수는 당첨자가 많을수록 상금이 줄어드니깐요.

그러나 위 예시처럼 극단적인 전략(똑같은 번호, 혹은 거의 비슷한 번호 여러장 사기)과 비교하는게 아니라면 대비효과는 미비합니다.

즉, 로또번호 분산기는 당첨확률을 높혀주고 안정적인 수익을 얻을 수 있게 도와주지만, 당첨금액 기댓값을 드라마틱하게 높혀주지는 않습니다.


""";

  Widget build(BuildContext context) {
    return SingleChildScrollView( 
      child: Column(
        children: [
          topPannel(context),
          Container(
            constraints: BoxConstraints(
              minWidth: double.infinity,
            ),
            padding: EdgeInsets.all(16.0),
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  imageBuilder: (Uri uri) => Padding( 
                    padding: EdgeInsets.all(20.0),
                    child: Image.asset(uri.toString().replaceAll("resource:", "")),
                  ),
                  data: aboutMarkdown,
                ),
              ]
            ),
          ),
          SizedBox(height: 50,),
          middlePannel(context),
          Container(
            constraints: BoxConstraints(
              minWidth: double.infinity,
            ),
            padding: EdgeInsets.all(16.0),
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contacts.map((line) => Text(line, style:Theme.of(context).textTheme.headline5)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
