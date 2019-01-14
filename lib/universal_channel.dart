import 'package:flutter/material.dart';
import 'package:universal_widget/universal_widget.dart';

/// version 1.0.0

class UniversalChannel extends ChangeNotifier {
  // static
  static List<UniversalChannel> _channels = [];
  static Map<String, UniversalChannel> _mappedNameAndChannels = {};
  static Map<String, UniversalChannel> _mappedWidgetAndChannels = {};
  
  static UniversalChannel get(String name){
    List<UniversalChannel> results = _channels.where((channel) => (channel.name == name)).toList();
    if(results.length > 0){
      return results[0];
    } else {
      return null;
    }
  }

  static UniversalChannel ofWidget(String widgetName){
    // print(_mappedWidgetAndChannels);
    return _mappedWidgetAndChannels[widgetName];
  }

  static debug(){
    print("======== ALL CHANNELS (${_channels.length}) ========");
    _channels.forEach((channel){
      String widgetListStr = "";
      if(channel._widgets.length > 0){
        channel._widgets.forEach((_widget){
          String widgetName = (_widget.name != null) ? _widget.name : _widget.hashCode.toString();
          widgetListStr += widgetName + ", ";
        });
        widgetListStr = widgetListStr.substring(0, widgetListStr.length - 2);
      }
      String attachedStr = (widgetListStr == "") ? " (Not attached)" : " (attached into UniversalWidget<$widgetListStr>)";
      print("${channel.name}$attachedStr");
    });
  }
  
  // constructor
  UniversalChannel({String name, UniversalWidget widget})
  {
    if(widget != null){
      this.extra = widget.extra;
      this.name = "UniversalChannel<${widget.hashCode}>";

      if(widget.name != null){
        // print("init channel => $widgetName");
        _mappedWidgetAndChannels[widget.name] = this;
      }
    } else {
      if(name != null){
        this.name = name;
      } else {
        int uid = DateTime.now().millisecondsSinceEpoch;
        this.name = "UniversalChannel<$uid>";
      }
    }

    _mappedNameAndChannels[this.name] = this;
    
    if(_channels.length > 0){
      _channels.removeWhere((channel) => (channel.name == this.name));
    }

    _channels.add(this);
  }
  
  String _name;
  get name => _name;
  set name(value){
    _mappedNameAndChannels.removeWhere((_name, _channel) => (_name == name));
    _name = value;
    _mappedNameAndChannels[name] = this;
  }

  List<UniversalWidget> _widgets = [];
  List<VoidCallback> _listeners = [];

  Map<String, dynamic> _extra = {};
  Map<String, dynamic> get extra {
    return _extra;
  }
  set extra(Map<String, dynamic> value){
    _extra = value;
    notifyListeners();
  }

  void broadcast(){
    notifyListeners();
  }

  void addChannelListener(UniversalWidget widget, VoidCallback listener){
    _widgets.add(widget);
    if(widget.name != null){
      _mappedWidgetAndChannels[widget.name] = this;
    }
    addListener(listener);
  }

  void removeChannelListener(UniversalWidget widget, VoidCallback listener){
    _mappedWidgetAndChannels.removeWhere((name, value) => (value == this));
    _widgets.removeWhere((_widget) => (_widget == widget));
    removeListener(listener);
  }

  @override
  void dispose() {
    // print("[UniversalChannel] Channel \"${this.name}\" is disposed");
    _mappedWidgetAndChannels.removeWhere((name, channel) => (channel == this));
    _mappedNameAndChannels.removeWhere((name, channel) => (channel == this));
    _channels.removeWhere((channel) => (channel == this));
    super.dispose();
  }

  @override
  void addListener(listener) {
    _listeners.add(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(listener) {
    _listeners.remove(listener);
    super.removeListener(listener);
  }
}