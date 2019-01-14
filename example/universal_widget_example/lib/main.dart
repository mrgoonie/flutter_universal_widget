import 'package:flutter/material.dart';
import 'package:universal_widget/universal_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.normal,
          buttonColor: Colors.grey[300],
          splashColor: Colors.white.withOpacity(0.2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.all(8)
        )
      ),
      home: HomeScreen()
    );
  }
}

class HomeScreen extends StatelessWidget {
  // This channel is the main channel of your application
  final MainAppChannel myChannel = UniversalChannel.get("MainAppChannel");
  
  @override
  Widget build(BuildContext context) {
    UniversalWidgetController con = UniversalWidgetController();
    
    Widget universalWidgetExample = Container(
      padding: EdgeInsets.only(top: 50),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                RaisedButton(
                  color: Colors.redAccent,
                  child: Text("Reset", style: TextStyle(color: Colors.white)),
                  onPressed: (){
                    UniversalWidget.find("testWidget").reset();
                  },
                ),

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
                      height: UniversalWidget.find("testWidget").originalSize.height,
                      onComplete: (){
                        print("Reverse -> Done");
                      }
                    );
                  },
                ),

                RaisedButton(
                  child: Text("Yoyo (1 time)"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(height: UniversalWidget.find("testWidget").originalSize.height);
                    UniversalWidget.find("testWidget").update(
                      duration: 0.5,
                      height: 600,
                      yoyo: true,
                    );
                  },
                ),

                RaisedButton(
                  child: Text("Yoyo + Repeat"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").update(height: UniversalWidget.find("testWidget").originalSize.height);
                    UniversalWidget.find("testWidget").update(
                      duration: 0.5,
                      ease: Ease.easeInOut,
                      height: 600,
                      // color: Colors.blueAccent,
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

                RaisedButton(
                  child: Text("ENTER FRAME"),
                  onPressed: (){
                    double rotation = UniversalWidget.find("testWidget").get().y;
                    UniversalWidget.find("testWidget").onEnterFrame((widget){
                      rotation += 10;
                      UniversalWidget.find("testWidget").get().rotation = rotation;
                    });
                  },
                ),

                RaisedButton(
                  child: Text("STOP ENTER FRAME"),
                  onPressed: (){
                    UniversalWidget.find("testWidget").deleteEnterFrame();
                  },
                ),

                RaisedButton(
                  child: Text("CAPTURE"),
                  onPressed: () async {
                    UniversalWidget widget = UniversalWidget.find("testWidget");
                    widget.toImage(onComplete: (image){
                      UniversalWidget.find("imageHolder").update(child: image);
                    });
                  },
                ),

                RaisedButton(
                  child: Text("DEBUG"),
                  onPressed: () async {
                    con.x = 10;
                    con.dispose();
                  },
                ),
                
              ],
            )
          ),

          UniversalWidget(
            name: "testWidget",
            height: 200,
            color: Colors.redAccent,
            onWidgetBuilt: (context){
              print(context.size);
            },
            onWidgetDisposed: (widget){
              print("=> Good bye ${widget.name}!");
            },
            child: Center(
              child: Text("Hello World")
              // child: Preloader(size: 20, strokeWidth: 2, color: Colors.white,),
            ),
          ),

          UniversalWidget(
            name: "imageHolder",
            color: Colors.blue,
            height: 100,
          )
        ],
      ),
    );

    Widget loginAnimationExample = Container(
      // alignment: Alignment.center,
      padding: EdgeInsets.only(top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("BACK"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),
                RaisedButton(
                  child: Text("DEBUG"),
                  onPressed: (){
                    UniversalWidget.debug();
                  },
                ),
                RaisedButton(
                  child: Text("SCALE"),
                  onPressed: (){
                    UniversalWidget.find("congrate").update(
                      duration: 0.7,
                      ease: Ease.backOut,
                      visible: true,
                      opacity: 1,
                      scale: Offset(1,1),
                    );
                  },
                ),
              ],
            )
          ),

          Expanded(
            child: ClipRect(
              // color: Colors.grey[200],
              child: Stack(
                children: <Widget>[
                  // UniversalWidget(
                  //   name: "hello",
                  //   child: Text("HELLO"),
                  // ),
                  
                  Center(
                    child: UniversalWidget(
                      name: "loginButton",
                      color: Colors.redAccent,
                      padding: EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(10),
                      mask: true,
                      // child: Text("LOG IN"),
                      child: UniversalWidget(
                        name: "loginButtonText",
                        child: Text("CLICK TO LOG IN"),
                      ),
                      onPressed: (widget) {
                        UniversalWidget loginBtn = UniversalWidget.find("loginButton");
                        loginBtn?.update(
                          borderRadius: BorderRadius.circular(50),
                          width: 80, height: 80, 
                          ease: Ease.elasticInOut,
                          duration: 0.5,
                          onComplete: (){
                            loginBtn.update(
                              mask: false,
                              child: CircularProgressIndicator()
                            );
                            Future.delayed(Duration(seconds: 2), (){
                              loginBtn.update(
                                child: Container(),
                                scale: Offset(20, 20),
                                ease: Ease.fastOutSlowIn,
                                duration: 0.5,
                                onComplete: (){
                                  // print("Congrats!");
                                  UniversalWidget.find("congrate").update(
                                    duration: 0.7,
                                    ease: Ease.backOut,
                                    scale: Offset(1,1),
                                    rotation: 0,
                                  );
                                }
                              );
                            });
                          }
                        );

                        UniversalWidget.find("loginButtonText")?.update(
                          opacity: 0, duration: 0.5
                        );

                        
                      }
                    )
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: UniversalWidget(
                      name: "congrate",
                      rotation: -45,
                      scale: Offset(0, 0),
                      child: Text(
                        "Congratulations!",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                ],
              )
            ),
          ),

          
        ],
      ),
    );

    Widget channelExample = Container(
      padding: EdgeInsets.only(top: 50),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text("[UniversalChannel] Example", style: Theme.of(context).textTheme.title),
            )
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                // RaisedButton(
                //   color: Colors.redAccent,
                //   child: Text("Reset", style: TextStyle(color: Colors.white)),
                //   onPressed: (){
                //     UniversalWidget.find("testWidget").reset();
                //   },
                // ),
                RaisedButton(
                  child: Text("RELOAD"),
                  onPressed: (){
                    // Navigator.of(context).pop();
                    // Navigator.of(context).pushReplacementNamed(Screens.playGround);
                  },
                ),

                RaisedButton(
                  child: Text("DEBUG"),
                  onPressed: (){
                    UniversalChannel.debug();
                    // print(UniversalChannel.ofWidget('widgetA'));
                  },
                ),

                RaisedButton(
                  child: Text("BROADCAST"),
                  onPressed: (){
                    MainAppChannel channel = UniversalChannel.get("MainAppChannel");
                    channel.count++;
                    // print(myChannel.count);
                  },
                ),

                RaisedButton(
                  child: Text("Update Channel that attached into WIDGET A"),
                  onPressed: (){
                    MainAppChannel channel = UniversalChannel.ofWidget('widgetA');
                    channel.count++;
                  },
                ),

                RaisedButton(
                  child: Text("Update Channel that attached into WIDGET B"),
                  onPressed: (){
                    MainAppChannel channel = UniversalChannel.ofWidget('widgetB');
                    channel.count++;
                  },
                ),

              ],
            )
          ),

          UniversalWidget(
            name: "widgetA",
            height: 100,
            color: Colors.redAccent,
            channel: myChannel,
            child: Builder(builder: (context){
              return Center(
                child: Text("Widget A: ${myChannel.count}")
              );
            })
          ),

          UniversalWidget(
            name: "widgetB",
            height: 100,
            color: Colors.amberAccent,
            channel: myChannel,
            child: Builder(builder: (context){
              return Center(
                child: Text("Widget B: ${myChannel.count}")
              );
            })
          ),

          UniversalWidget(
            name: "widgetC",
            height: 100,
            color: Colors.blueAccent,
            extra: {"count": 0},
            child: Builder(builder: (context){
              UniversalChannel channel = UniversalChannel.ofWidget("widgetC");
              return Center(
                child: Text("Widget C: ${channel.extra["count"]}")
              );
            }),
            onPressed: (widget){
              UniversalChannel channel = UniversalChannel.ofWidget("widgetC");
              channel.extra["count"]++;
              channel.broadcast();
              
              print(channel.extra["count"]);
            },
          ),

          UniversalWidget(
            name: "widgetD",
            height: 100,
            color: Colors.greenAccent,
            extra: {
              "isShow": true
            },
            child: Builder(builder: (context){
              UniversalChannel channel = UniversalChannel.ofWidget("widgetD");
              return Center(
                child: Text("Widget D: ${channel.extra["isShow"]}")
              );
            }),
            onPressed: (widget){
              UniversalChannel channel = UniversalChannel.ofWidget("widgetD");
              channel.extra["isShow"] = !channel.extra["isShow"];
              channel.broadcast();
            },
          ),

          UniversalWidget(
            name: "widgetE",
            height: 100,
            color: Colors.purpleAccent,
            extra: {
              "count": 0
            },
            child: Builder(builder: (context){
              UniversalChannel channel = UniversalChannel.ofWidget("widgetE");
              int count = channel.extra["count"];
              return Center(
                child: Text("Widget E: $count")
              );
            }),
            onPressed: (widget){
              UniversalWidget widget = UniversalWidget.find("widgetE");
              widget.extra["count"]++;
              // print(widget.extra["count"]);
              widget.get().forceRebuildWidget();
            },
          ),
        ],
      ),
    );

    return Scaffold(
      body: universalWidgetExample,
      // body: loginAnimationExample,
      // body: channelExample,
    );
  }
}

class MainAppChannel extends UniversalChannel {
  MainAppChannel({
    String name,
    UniversalWidget widget
  }) : super(name: name, widget: widget);

  int _count = 0;
  int get count => _count;
  set count(int value){
    _count = value;
    notifyListeners();
  }
}