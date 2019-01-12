import 'package:flutter/material.dart';
import 'package:universal_widget/universal_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Widget example = Container(
      padding: EdgeInsets.only(top: 50),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                RaisedButton(
                  child: Text("Start"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(
                      duration: 0.5,
                      height: 600,
                      onComplete: (){
                        print("Start -> Done");
                      }
                    );
                  },
                ),
                RaisedButton(
                  child: Text("Reverse"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(
                      duration: 0.5,
                      height: 300,
                      onComplete: (){
                        print("Reverse -> Done");
                      }
                    );
                  },
                ),
                RaisedButton(
                  child: Text("Reset"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(height: 300, color: Colors.redAccent);
                  },
                ),
                RaisedButton(
                  child: Text("Yoyo"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(height: 300);
                    UniversalWidget.find("testWidget").update(
                      duration: 0.5,
                      height: 600,
                      yoyo: true,
                    );
                  },
                ),
                RaisedButton(
                  child: Text("Loop"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(height: 300);
                    UniversalWidget.find("testWidget").update(
                      duration: 0.5,
                      height: 600,
                      yoyo: true,
                      repeat: -1
                    );
                  },
                ),
                RaisedButton(
                  child: Text("Stop"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").killAllTweens();
                  },
                ),
                RaisedButton(
                  child: Text("Change Color"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(
                      duration: 0.5,
                      color: Colors.blueAccent,
                    );
                  },
                ),
                RaisedButton(
                  child: Text("Scale"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(
                      duration: 0.8,
                      transformOrigin: Offset(0.5, 0.5),
                      scale: Offset(0.5, 0.5),
                      color: Colors.blueAccent,
                    );
                  },
                ),
                
              ],
            )
          ),

          UniversalWidget(
            name: "testWidget",
            height: 300,
            color: Colors.redAccent,
            onWidgetBuilt: (context){
              print(context.size);
            },
            onWidgetDisposed: (widget){
              print("=> Good bye ${widget.name}!");
            },
            child: Center(child: Text("Hello World")),
          ),
        ],
      ),
    );

    return Scaffold(
      body: example
    );
  }
}