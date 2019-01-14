library universal_widget;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:universal_widget/tweener.dart';
import 'package:universal_widget/universal_channel.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// export
export 'package:universal_widget/tweener.dart';
export 'package:universal_widget/universal_channel.dart';

/// version 1.2.2
/// Fixed error: `A UniversalWidgetController was used after being disposed.`.

/// Custom method callback with return any value
typedef void ReturnVoidCallback({dynamic result});

class UniversalWidget extends StatefulWidget {
  /// Create a new UniversalWidget
  UniversalWidget({
    Key key, 
    this.name,
    this.child,
    // display properties
    this.x = 0.0,
    this.y = 0.0,
    this.width,
    this.height,
    this.color,
    this.border,
    this.borderRadius,
    this.opacity = 1,
    this.rotation = 0,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.boxShadow,
    this.alignment,
    EdgeInsetsGeometry margin, padding,
    Offset scale, transformOrigin, // transform matrix
    // display mode
    this.interaction = true,
    this.visible = true,
    this.mask = false,
    // animation options
    this.animateWhenUpdate = false,
    this.durationWhenUpdate = 0.5,
    this.easeWhenUpdate,
    // widget callbacks
    this.onWidgetInit,
    this.onWidgetBuilt,
    this.onWidgetUpdated,
    this.onWidgetDisposed,
    // button mode
    this.onPressed,
    // channel data
    // this.extra,
    Map<String, dynamic> extra,
    UniversalChannel channel,
    List<UniversalChannel> listenedChannels,
  }) : 
    _controller = UniversalWidgetController(),
    transformOrigin = transformOrigin ?? Offset(0.5, 0.5),
    scale = scale ?? Offset(1,1),
    margin = margin ?? EdgeInsets.zero,
    padding = padding ?? EdgeInsets.zero,
    extra = extra ?? {},
    _channel = channel,
    super(key: key);

  @override
  StatefulElement createElement() {
    return super.createElement();
  }

  final String name;
  final Widget child;
  final UniversalWidgetController _controller;

  final double x, y, width, height, rotation, opacity, top, bottom, left, right;
  final Color color;
  final Offset scale, transformOrigin;
  final EdgeInsetsGeometry margin, padding;
  final bool interaction, visible, mask;
  final Border border;
  final BorderRadius borderRadius;
  final List<BoxShadow> boxShadow;
  final Alignment alignment;

  // UniversalChannel
  final UniversalChannel _channel;
  UniversalChannel get channel {
    if(state != null && state._channel != null){
      return state._channel;
    } else if(_channel != null){
      return _channel;
    } else {
      return UniversalChannel(widget: this);
    }
  }
  // dirty `extra` to store variables
  final Map<String, dynamic> extra;

  final bool animateWhenUpdate;
  final double durationWhenUpdate;
  final Curve easeWhenUpdate;

  /// Callback method to listen for the widget's initializing event
  final VoidCallback onWidgetInit;
  /// Callback method to listen for the event after the widget was built
  final ValueChanged<UniversalWidget> onWidgetBuilt;
  /// Callback method to listen for the widget's disposing event
  final ValueChanged<UniversalWidget> onWidgetDisposed;
  /// Callback method to listen for the widget's updating event
  final ValueChanged<UniversalWidget> onWidgetUpdated;

  /// Callback method to listen for pressing (tapping) event
  final ValueChanged<UniversalWidget> onPressed;

  /// Reset the widget to the original state.
  void reset(){
    update(
      x: x, y: y, top: top, left: left, right: right, bottom: bottom,
      opacity: opacity, rotation: rotation, scale: scale,
      visible: visible, interaction: interaction, mask: mask,
      width: width, height: height, margin: margin, padding: padding,
      color: color, border: border, borderRadius: borderRadius, boxShadow: boxShadow
    );
  }

  /// Create a repeated method with given FPS (default: 60 fps).
  void onEnterFrame(ValueChanged<UniversalWidget> callback, {int fps = 60}){
    if(_controller._timer != null) _controller._timer.cancel();
    int miliseconds = (1000 ~/ fps);
    _controller._timer = Timer.periodic(Duration(milliseconds: miliseconds), (timer){
      callback(this);
    });
  }

  /// Delete/kill a current repeated method.
  void deleteEnterFrame(){
    if(_controller._timer != null) _controller._timer.cancel();
    _controller._timer = null;
  }

  /// Stop all current animations of the widget. (Same function with `killAllTweens()`)
  void stopAnimation(){
    killAllTweens();
  }

  /// Stop the current animation of the widget. (Same function with `stopAnimation()`)
  void killAllTweens(){
    if(_controller!= null) _controller.killAllTweens();
  }
  
  /// Updates the properties of the widget, with animation options.
  void update({
    double x, y, width, height, rotation, opacity, top, bottom, left, right,
    Color color,
    Offset transition, scale, transformOrigin,
    EdgeInsetsGeometry margin, padding,
    Border border,
    BorderRadius borderRadius,
    List<BoxShadow> boxShadow,
    bool visible,
    bool interaction,
    bool mask,
    Widget child,
    // animation options
    double duration,
    Curve ease = Ease.ease,
    bool yoyo = false,
    bool override = true,
    int repeat = 0,
    double delay,
    OnTweenerUpdateCallback onUpdate,
    VoidCallback onComplete,
  }){
    
    processUpdating(){
      if(!override || duration == null) _controller.killAllTweens();

      if(child != null){
        _controller.child = child;
      }

      if(mask != null && mask != _controller.mask) _controller.mask = mask;
      
      if(animateWhenUpdate || duration != null){
        // print("${controller.width} x ${controller.height}");
        if(width != null && _controller.width == null) _controller._width = _controller._state._initSize.width;
        if(height != null && _controller.height == null) _controller._height = _controller._state._initSize.height;

        if(visible != null) _controller.visible = visible;
        if(interaction != null) _controller.interaction = interaction;
        
        Tweener.to(_controller, duration ?? durationWhenUpdate, 
          x: x,
          y: y,
          width: width,
          height: height,
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          opacity: opacity,
          scale: scale,
          rotation: rotation,
          color: color,
          border: border,
          borderRadius: borderRadius,
          transformOrigin: transformOrigin,
          margin: margin,
          padding: padding,
          // animation options
          ease: ease ?? easeWhenUpdate ?? Ease.ease,
          delay: delay,
          yoyo: yoyo,
          repeat: repeat,
          onUpdate: onUpdate,
          onComplete: onComplete,
        );
      } else {
        if(x != null) _controller.x = x + .0;
        if(y != null) _controller.y = y + .0;
        if(width != null) _controller.width = width + .0;
        if(height != null) _controller.height = height + .0;
        if(rotation != null) _controller.rotation = rotation + .0;
        if(opacity != null) _controller.opacity = opacity + .0;
        if(color != null) _controller.color = color;
        if(border != null) _controller.border = border;
        if(borderRadius != null) _controller.borderRadius = borderRadius;
        if(transformOrigin != null) _controller.transformOrigin = transformOrigin;
        if(scale != null) _controller.scale = scale;
        if(margin != null) _controller.margin = margin;
        if(padding != null) _controller.padding = padding;
        if(boxShadow != null) _controller.boxShadow = boxShadow;

        if(visible != null) _controller.visible = visible;
        if(interaction != null) _controller.interaction = interaction;

        if(top != null) _controller.top = top + .0;
        if(bottom != null) _controller.bottom = bottom + .0;
        if(left != null) _controller.left = left + .0;
        if(right != null) _controller.right = right + .0;
      }
    }

    void buildListener(){
      if(_controller.state != null){
        _controller.removeListener(buildListener);
        processUpdating();
      }
    }

    if(_controller.state == null){
      _controller.addListener(buildListener);
    } else {
      processUpdating();
    }
  }

  /// Get access to widget properties
  UniversalWidgetController get(){
    return _controller;
  }

  /// Check whether this widget has different properties with another widget
  bool diff(UniversalWidget widget){
    if(x != widget.x) return true;
    if(y != widget.y) return true;
    if(width != widget.width) return true;
    if(height != widget.height) return true;
    if(scale != widget.scale) return true;
    if(rotation != widget.rotation) return true;
    if(color != widget.color) return true;
    if(border != widget.border) return true;
    if(transformOrigin != widget.transformOrigin) return true;
    if(borderRadius != widget.borderRadius) return true;
    if(opacity != widget.opacity) return true;
    if(top != widget.top) return true;
    if(left != widget.left) return true;
    if(right != widget.right) return true;
    if(bottom != widget.bottom) return true;
    if(boxShadow != widget.boxShadow) return true;
    if(visible != widget.visible) return true;
    if(interaction != widget.interaction) return true;
    return false;
  }

  /// Get size of the widget (return `Size.zero` if the widget has been built yet).
  Size get size {
    Size _size = (state != null && state.context != null) ? state.context.size : Size(0,0);
    double horizontal = (_controller.margin != null) ? _controller.margin.horizontal : 0;
    double vertical = (_controller.margin != null) ? _controller.margin.vertical : 0;
    return Size(_size.width - horizontal, _size.height - vertical);
  }

  /// Get original size of the widget, after the widget was build the first time.
  Size get originalSize {
    return _controller.state.initSize;
  }

  /// Get widget position on the screen.
  Offset get globalPosition {
    return (state != null && state.context != null) ? (state.context.findRenderObject() as RenderBox).localToGlobal(Offset.zero) : Offset(0, 0);
  }

  /// Convert widget to [ByteData].
  Future<ByteData> _toByte({double pixelRatio: 3.0}) async {
    RenderRepaintBoundary boundary = state.context.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // if(_controller != null) _controller.shouldCaptureWidget = false;
    return byteData;
  }

  /// Convert widget to [Image].
  void toImage({double pixelRatio: 3.0, ValueChanged<Image> onComplete}) async {
    // ByteData byteData = await toByte(pixelRatio: pixelRatio);
    if(_controller == null) return;
    _controller.captureWidget(onComplete: (byteData){
      Uint8List pngBytes = byteData.buffer.asUint8List();
      Image finalImage = Image.memory(pngBytes);
      if(onComplete != null) onComplete(finalImage);
    });
    // return finalImage;
  }

  /// Convert widget to Base64 [String].
  void toBase64({double pixelRatio: 3.0, ValueChanged<String> onComplete}) async {
    if(_controller == null) return;
    // ByteData byteData = await toByte(pixelRatio: pixelRatio);
    _controller.captureWidget(onComplete: (byteData){
      Uint8List pngBytes = byteData.buffer.asUint8List();
      String base64 = base64Encode(pngBytes);
      if(onComplete != null) onComplete(base64);
    });
    // return base64;
  }

  /// Get state of the widget.
  _UniversalWidgetState get state => _controller.state;

  // ==========================================
  //                  STATICS
  // ==========================================

  static List<UniversalWidget> _list = [];
  
  /// {Debug purspose only} To see how many `UniversalWidget` are existed on the screens.
  static debug(){
    print("============ UniversalWidgetDebug [START] ============");
    _list.forEach((i) => print("UniversalWidget<${i.name}>"));
    print("============ UniversalWidgetDebug [END] ============");
  }
  
  /// Get the `UniversalWidget` from device memory by its unique given name
  static UniversalWidget find(String name){
    List<UniversalWidget> results = _list.where((item) => (item.name == name)).toList();
    if(results.length > 0){
      return results[0];
    } else {
      print("[WARNING] There is no <UniversalWidget> with the name \"$name\".");
      return null;
    }
  }
  
  /// Check if the widget is existed in device memory
  static bool exists(String name){
    List<UniversalWidget> results = _list.where((item) => (item.name == name)).toList();
    return (results.length > 0);
  }
  
  /// Add `UniversalWidget` into device memory for accessing later (if needed)
  static add(UniversalWidget widget){
    if(exists(widget.name)){
      remove(widget.name);
    }
    _list.add(widget);
  }

  /// Remove `UniversalWidget` from device memory by its unique given name
  static remove(String name){
    if(exists(name)){
      UniversalWidget widget = _list.where((item) => (item.name == name)).toList()[0];
      _list.remove(widget);
      // widget.state.dispose();
    }
  }

  /// Remove all `UniversalWidget` instances from device memory
  static wipeOut(){
    if(_list.length > 0) _list.removeRange(0, _list.length);
  }
  
  /// The state from the closest instance of this class that encloses the given context.
  static _UniversalWidgetState of(BuildContext context){
    return context.ancestorStateOfType(TypeMatcher<_UniversalWidgetState>());
  }

  @override
  State<StatefulWidget> createState() => _UniversalWidgetState();
}

class _UniversalWidgetState extends State<UniversalWidget> {

  UniversalWidgetController _oldController = UniversalWidgetController();
  UniversalWidgetController _controller;
  UniversalChannel _channel;
  
  String _parentRenderType;
  bool _isBuiltFirstTime = true;

  Size _initSize = Size.zero;
  Size get initSize => _initSize;

  @override
  void didUpdateWidget(UniversalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.channel != oldWidget.channel){
      // print("update widget channel: ${widget._channel.hashCode} -> ${oldWidget._channel.hashCode}");
      oldWidget.channel.removeChannelListener(widget, _onChannelNotified);
      oldWidget.channel.dispose();
      _channel = widget.channel;
      _channel.addChannelListener(widget, _onChannelNotified);
    }
    
    if(widget._controller != oldWidget._controller){
      _controller = widget._controller ?? UniversalWidgetController();

      _controller._widget = widget;
      _controller._timer = oldWidget._controller._timer;

      _controller._mask = (widget.mask != oldWidget.mask) ? widget.mask : oldWidget._controller.mask;
      _controller._child = (widget.child != oldWidget.child) ? widget.child : oldWidget._controller.child;
      
      _controller._x = (widget.x != oldWidget.x) ? widget.x : oldWidget._controller.x;
      _controller._y = (widget.y != oldWidget.y) ? widget.y : oldWidget._controller.y;
      _controller._width = (widget.width != oldWidget.width) ? widget.width : oldWidget._controller.width;
      _controller._height = (widget.height != oldWidget.height) ? widget.height : oldWidget._controller.height;
      _controller._scale = (widget.scale != oldWidget.scale) ? widget.scale : oldWidget._controller.scale;
      _controller._rotation = (widget.rotation != oldWidget.rotation) ? widget.rotation : oldWidget._controller.rotation;
      _controller._border = (widget.border != oldWidget.border) ? widget.border : oldWidget._controller.border;
      _controller._borderRadius = (widget.borderRadius != oldWidget.borderRadius) ? widget.borderRadius : oldWidget._controller.borderRadius;
      _controller._transformOrigin = (widget.transformOrigin != oldWidget.transformOrigin) ? widget.transformOrigin : oldWidget._controller.transformOrigin;
      _controller._opacity = (widget.opacity != oldWidget.opacity) ? widget.opacity : oldWidget._controller.opacity;
      _controller._color = (widget.color != oldWidget.color) ? widget.color : oldWidget._controller.color;
      _controller._margin = (widget.margin != oldWidget.margin) ? widget.margin : oldWidget._controller.margin;
      _controller._padding = (widget.padding != oldWidget.padding) ? widget.padding : oldWidget._controller.padding;
      _controller._boxShadow = (widget.boxShadow != oldWidget.boxShadow) ? widget.boxShadow : oldWidget._controller.boxShadow;
      
      _controller._visible = (widget.visible != oldWidget.visible) ? widget.visible : oldWidget._controller.visible;
      _controller._interaction = (widget.interaction != oldWidget.interaction) ? widget.interaction : oldWidget._controller.interaction;
      
      _controller._top = (widget.top != oldWidget.top) ? widget.top : oldWidget._controller.top;
      _controller._bottom = (widget.bottom != oldWidget.bottom) ? widget.bottom : oldWidget._controller.bottom;
      _controller._left = (widget.left != oldWidget.left) ? widget.left : oldWidget._controller.left;
      _controller._right = (widget.right != oldWidget.right) ? widget.right : oldWidget._controller.right;

      if(oldWidget._controller != null) oldWidget._controller.removeListener(_widgetListener);
      oldWidget._controller.dispose();
      _controller.addListener(_widgetListener);
    }

    _controller._state = this;
    
    if(widget.name != null){
      // print("$widget<${widget.name}> was updated!");
      UniversalWidget.add(widget);
    }

    _parentRenderType = context.ancestorRenderObjectOfType(TypeMatcher<RenderObject>()).runtimeType.toString();
    _isBuiltFirstTime = true;

    if(widget.onWidgetUpdated != null){
      widget.onWidgetUpdated(widget);
    }
  }

  @override
  void initState() {
    super.initState();

    _isBuiltFirstTime = true;

    _parentRenderType = context.ancestorRenderObjectOfType(TypeMatcher<RenderObject>()).runtimeType.toString();

    _controller = widget._controller ?? UniversalWidgetController();

    _controller._widget = widget;
    _controller._state = this;
    _controller._child = widget.child;
    _controller._mask = widget.mask;
    
    _controller.x = widget.x;
    _controller.y = widget.y;
    _controller.width = widget.width;
    _controller.height = widget.height;
    _controller.color = widget.color;
    _controller.scale = widget.scale;
    _controller.rotation = widget.rotation;
    _controller.border = widget.border;
    _controller.borderRadius = widget.borderRadius;
    _controller.transformOrigin = widget.transformOrigin;
    _controller.opacity = widget.opacity;
    _controller.visible = widget.visible;
    _controller.interaction = widget.interaction;
    _controller.margin = widget.margin;
    _controller.padding = widget.padding;
    _controller.boxShadow = widget.boxShadow;

    _controller.top = widget.top;
    _controller.bottom = widget.bottom;
    _controller.left = widget.left;
    _controller.right = widget.right;

    _controller.addListener(_widgetListener);

    // channel
    // _channel = (widget._channel != null) ? widget._channel : UniversalChannel(widget: widget);
    _channel = widget.channel;
    _channel.addChannelListener(widget, _onChannelNotified);

    // print(_channel);

    if(widget.onWidgetUpdated != null) widget.onWidgetUpdated(widget);
    if(widget.onWidgetInit != null) widget.onWidgetInit();

    // _trace("Initialized!");
  }

  _onChannelNotified(){
    // print("Channel updated!");
    if(mounted) setState((){});
  }

  _widgetListener(){
    // rebuild the widget:
    if(mounted) setState((){});

    _oldController.copyFrom(_controller);
  }

  @override
  void dispose() {
    super.dispose();

    // unsubscribe channel
    _channel.removeChannelListener(widget, _onChannelNotified);
    if(_channel.name == "UniversalChannel<${widget.hashCode}>"){
      _channel.dispose();
    }

    if(_controller != null){
      // try to dispose controller if it's still existed
      try {
        _controller.removeListener(_widgetListener);
        _controller.dispose();
        _controller = null;
      } catch(err){}
    }
    
    if(_oldController != null){
      _oldController.dispose();
      _oldController = null;
    }
    
    if(widget.name != null){
      // _trace("Disposed!");
      UniversalWidget.remove(widget.name);
    }
    
    if(widget.onWidgetDisposed != null) widget.onWidgetDisposed(widget);
  }

  _trace(String msg){
    if(widget.name != null) print("UniversalWidget<${widget.name}>: $msg");
  }

  Future<void> _executeAfterFirstBuild() async {
    // _trace("${_controller.mask}");
    if(context != null){
      _initSize = context.size;
      if(_controller.mask){
        _controller._width = _initSize.width;
        _controller._height = _initSize.height;
      } else {
        _controller._width = widget.width;
        _controller._height = widget.height;
      }
    }

    if(widget.name != null){
      UniversalWidget.add(widget);
      // _trace("Built!");
    }

    if(_controller != null){
      try {
        _controller._markWitgetWasBuilt();
        if(_controller._forceRebuildCallback != null){
          _controller._forceRebuildCallback();
          _controller._forceRebuildCallback = null;
        }
      } catch(err){}
    }

    if(widget.onWidgetBuilt != null) widget.onWidgetBuilt(widget);
  }

  @override
  Widget build(BuildContext context) {
    // _trace("Built!");

    if(_controller == null) return SizedBox();

    _controller._state = this; // update state

    if(_isBuiltFirstTime || (_controller.mask != _oldController.mask) || (_controller.child != _oldController.child) || _controller._forceRebuildWidget){
      _isBuiltFirstTime = false;
      _controller._forceRebuildWidget = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _executeAfterFirstBuild());
    }

    Widget container;
    Widget child;
    AlignmentGeometry align = widget.alignment;

    if(_controller.child is Builder){
      child = (_controller.child as Builder).build(context);
    } else {
      child = _controller.child;
    }
    // if(_controller.child is UniversalBuilder){
    //   child = (_controller.child as UniversalBuilder).build(context);
    // }

    bool shouldApplyTransformMatrix = false;

    if(_controller.rotation != 0 || (_controller.rotation == 0 && _oldController.rotation != 0))
    {
      shouldApplyTransformMatrix = true;
    }

    if(_controller.x != 0 || (_controller.x == 0 && _oldController.x != 0)){
      shouldApplyTransformMatrix = true;
    }

    if(_controller.y != 0 || (_controller.y == 0 && _oldController.y != 0)){
      shouldApplyTransformMatrix = true;
    }

    if(_controller.scale.dx != 1 || (_controller.scale.dx == 1 && _oldController.scale.dx != 1)){
      shouldApplyTransformMatrix = true;
    }

    if(_controller.scale.dy != 1 || (_controller.scale.dy == 1 && _oldController.scale.dy != 1)){
      shouldApplyTransformMatrix = true;
    }
    
    if(_controller.mask){
      child = ClipRRect(
        borderRadius: _controller.borderRadius ?? BorderRadius.all(Radius.circular(0)),
        child: child,
      );
    }

    container = Container(
      width: _controller.width,
      height: _controller.height,
      // spacing
      padding: _controller.padding,
      margin: _controller.margin,
      // box decoration
      decoration: BoxDecoration(
        color: _controller.color,
        border: _controller.border,
        borderRadius: _controller.borderRadius,
        boxShadow: _controller.boxShadow,
        // image: data.backgroundImage
      ),
      child: child
    );

    if(shouldApplyTransformMatrix){
      align = FractionalOffset(_controller.transformOrigin.dx, _controller.transformOrigin.dy);
      container = Transform(
        alignment: align,
        transform: Matrix4.identity()
          ..translate(_controller.x, _controller.y)
          ..rotateZ((_controller.rotation) * math.pi / 180)
          ..scale(_controller.scale.dx, _controller.scale.dy),
        child: container,
      );
    }

    if(widget.onPressed != null){
      container = GestureDetector(
        onTap: () => widget.onPressed(_controller.widget),
        child: container,
      );
    }

    double newOpacity = _controller.opacity;

    if(!_controller.visible){
      newOpacity = 0.0;
    }

    if(newOpacity != 1 || (newOpacity == 1 && _oldController.opacity != 1)){
      // make sure opacity is larger than 0.0 & smaller than 1.0
      newOpacity = (newOpacity < 0.0) ? 0.0 : ((newOpacity > 1) ? 1 : newOpacity);
      
      container = Opacity(
        alwaysIncludeSemantics: true,
        opacity: newOpacity,
        child: container
      );
    }

    if(!_controller.visible || !widget.interaction){
      container = IgnorePointer(child: container);
    }
    
    // container = RepaintBoundary(child: container);
    // _trace(_controller.shouldCaptureWidget.toString());
    if(_controller.shouldCaptureWidget){
      container = RepaintBoundary(child: container);
    }

    if(_parentRenderType == "RenderStack"){
      if(_controller.top != null || _controller.left != null || _controller.right != null || _controller.bottom != null){
        container = Positioned(
          top: _controller.top,
          left: _controller.left,
          right: _controller.right,
          bottom: _controller.bottom,
          child: container
        );
      }
    }

    return container;
  }
}

class UniversalWidgetController extends ChangeNotifier {
  _UniversalWidgetState _state;
  _UniversalWidgetState get state {
    return _state;
  }

  Timer _timer;

  bool _isBuilt = false;
  bool get isBuilt {
    return _isBuilt;
  }
  _markWitgetWasBuilt() {
    _isBuilt = true;
    notifyListeners();
  }
  // _markWitgetWasDisposed() {
  //   _isBuilt = false;
  //   notifyListeners();
  // }

  UniversalWidget _widget;
  UniversalWidget get widget => _widget;

  Widget _child;
  Widget get child => _child;
  set child(Widget value){
    _child = value;
    _state?._isBuiltFirstTime = true;
    notifyListeners();
  }

  bool _shouldCaptureWidget = false;
  bool get shouldCaptureWidget => _shouldCaptureWidget;
  set shouldCaptureWidget(bool value){
    _shouldCaptureWidget = value;
    notifyListeners();
  }

  void captureWidget({ValueChanged<ByteData> onComplete}) async {
    shouldCaptureWidget = true;
    forceRebuildWidget(onComplete: () async {
      ByteData byte = await widget._toByte();
      shouldCaptureWidget = false;
      if(onComplete != null) onComplete(byte);
    });
  }

  bool _forceRebuildWidget = false;
  VoidCallback _forceRebuildCallback;
  void forceRebuildWidget({VoidCallback onComplete}){
    if(onComplete != null) _forceRebuildCallback = onComplete;
    _forceRebuildWidget = true;
    notifyListeners();
  }

  bool _mask = false;
  bool get mask => _mask;
  set mask(bool value){
    _mask = value;
    // _state?._isBuiltFirstTime = true;
    forceRebuildWidget();
    notifyListeners();
  }

  bool _interaction = false;
  bool get interaction => _interaction;
  set interaction(bool value){
    _interaction = value;
    _state?._isBuiltFirstTime = true;
    notifyListeners();
  }

  double _x = 0.0;
  double get x => _x;
  set x(double value) {
    _x = value;
    notifyListeners();
  }

  double _y = 0.0;
  double get y => _y;
  set y(double value) {
    _y = value;
    notifyListeners();
  }

  double _rotation = 0;
  double get rotation => _rotation;
  set rotation(double value) {
    _rotation = value;
    notifyListeners();
  }

  double _opacity = 1;
  double get opacity => _opacity;
  set opacity(double value) {
    _opacity = value;
    notifyListeners();
  }

  double _width = 0;
  double get width => _width;
  set width(double value) {
    _width = value;
    notifyListeners();
  }

  double _height = 0;
  double get height => _height;
  set height(double value) {
    _height = value;
    notifyListeners();
  }

  bool _visible = true;
  bool get visible => _visible;
  set visible(bool value) {
    _visible = value;
    if(_visible == false) interaction = false;
    notifyListeners();
  }

  Offset _transformOrigin = Offset(0.5, 0.5);
  Offset get transformOrigin => _transformOrigin;
  set transformOrigin(Offset value) {
    _transformOrigin = value;
    notifyListeners();
  }

  Offset _scale = Offset(1, 1);
  Offset get scale => _scale;
  set scale(Offset value) {
    _scale = value;
    notifyListeners();
  }

  Color _color;
  Color get color => _color;
  set color(Color value) {
    _color = value;
    notifyListeners();
  }

  EdgeInsetsGeometry _margin;
  EdgeInsetsGeometry get margin => _margin;
  set margin(EdgeInsetsGeometry value) {
    _margin = value;
    notifyListeners();
  }

  EdgeInsetsGeometry _padding;
  EdgeInsetsGeometry get padding => _padding;
  set padding(EdgeInsetsGeometry value) {
    _padding = value;
    notifyListeners();
  }

  Border _border;
  Border get border => _border;
  set border(Border value) {
    _border = value;
    notifyListeners();
  }

  BorderRadius _borderRadius;
  BorderRadius get borderRadius => _borderRadius;
  set borderRadius(BorderRadius value) {
    _borderRadius = value;
    notifyListeners();
  }

  double _top;
  double get top => _top;
  set top(double value) {
    _top = value;
    notifyListeners();
  }

  double _bottom;
  double get bottom => _bottom;
  set bottom(double value) {
    _bottom = value;
    notifyListeners();
  }

  double _left;
  double get left => _left;
  set left(double value) {
    _left = value;
    notifyListeners();
  }

  double _right;
  double get right => _right;
  set right(double value) {
    _right = value;
    notifyListeners();
  }

  List<BoxShadow> _boxShadow;
  List<BoxShadow> get boxShadow => _boxShadow;
  set boxShadow(List<BoxShadow> value) {
    _boxShadow = value;
    notifyListeners();
  }

  List<Tweener> _tweens = [];
  /// Add a new tween to this container's list.
  void add(Tweener tween){
    _tweens.add(tween);
  }

  /// Dispose a specific tween on this container.
  void killTween(Tweener tween){
    if(_tweens.contains(tween)) _tweens.remove(tween);
    if(tween != null) tween.dispose();
  }

  /// Dispose all tweens on this container.
  void killAllTweens(){
    if(_tweens.length > 0){
      for(int i=0; i<_tweens.length; i++){
        _tweens[i].dispose();
      }
      _tweens = [];
    }
  }

  @override dispose(){
    // String widgetName = (_widget != null && _widget.name != null) ? _widget.name : "UniversalWidget<${_widget.hashCode}> (NO_NAME)";
    // print("[UniversalWidgetController] Controller of \"$widgetName\" has been disposed.");
    killAllTweens();
    super.dispose();
  }

  bool diff(dynamic controller){
    if(x != controller.x) return true;
    if(y != controller.y) return true;
    if(state != controller.state) return true;
    if(child != controller.child) return true;
    if(mask != controller.mask) return true;
    if(interaction != controller.interaction) return true;
    if(width != controller.width) return true;
    if(height != controller.height) return true;
    if(scale != controller.scale) return true;
    if(rotation != controller.rotation) return true;
    if(color != controller.color) return true;
    if(transformOrigin != controller.transformOrigin) return true;
    if(border != controller.border) return true;
    if(borderRadius != controller.borderRadius) return true;
    if(opacity != controller.opacity) return true;
    if(top != controller.top) return true;
    if(left != controller.left) return true;
    if(right != controller.right) return true;
    if(bottom != controller.bottom) return true;
    if(boxShadow != controller.boxShadow) return true;
    if(visible != controller.visible) return true;
    return false;
  }

  void copyFrom(dynamic controller, {bool shouldNotify: false}){
    _child = controller.child;
    _state = controller.state;
    _mask = controller.mask;
    _interaction = controller.interaction;
    _x = controller.x;
    _y = controller.y;
    _width = controller.width;
    _height = controller.height;
    _scale = controller.scale;
    _rotation = controller.rotation;
    _transformOrigin = controller.transformOrigin;
    _border = controller.border;
    _borderRadius = controller.borderRadius;
    _color = controller.color;
    _opacity = controller.opacity;
    _visible = controller.visible;
    _top = controller.top;
    _bottom = controller.bottom;
    _left = controller.left;
    _right = controller.right;
    _boxShadow = controller.boxShadow;

    if(shouldNotify){
      notifyListeners();
    } 
  }

  UniversalWidgetController clone(){
    UniversalWidgetController controller = UniversalWidgetController();
    
    controller._x = x;
    controller._y = y;
    controller._width = width;
    controller._height = height;
    controller._scale = scale;
    controller._rotation = rotation;
    controller._transformOrigin = transformOrigin;
    controller._border = border;
    controller._borderRadius = borderRadius;
    controller._color = color;
    controller._opacity = opacity;
    controller._visible = visible;
    controller._mask = mask;
    controller._interaction = interaction;

    controller._top = top;
    controller._bottom = bottom;
    controller._left = left;
    controller._right = right;
    
    controller._boxShadow = boxShadow;

    return controller;
  }
}

typedef UniversalWidgetBuilder = Widget Function(UniversalChannel channel, BuildContext context);
class UniversalBuilder extends StatelessWidget {
  /// Creates a widget that delegates its build to a callback.
  ///
  /// The [builder] argument must not be null.
  const UniversalBuilder({
    Key key,
    // @required this.channel,
    @required this.builder
  }) : assert(builder != null),
       super(key: key);

  /// Called to obtain the child widget.
  ///
  /// This function is called whenever this widget is included in its parent's
  /// build and the old widget (if any) that it synchronizes with has a distinct
  /// object identity. Typically the parent's build method will construct
  /// a new tree of widgets and so a new Builder child will not be [identical]
  /// to the corresponding old one.
  final UniversalWidgetBuilder builder;

  // final UniversalChannel channel;

  @override
  Widget build(BuildContext context){
    _UniversalWidgetState parentState = context.ancestorStateOfType(TypeMatcher<_UniversalWidgetState>());
    UniversalChannel channel = parentState.widget.channel;
    return builder(channel, context);
  }
}