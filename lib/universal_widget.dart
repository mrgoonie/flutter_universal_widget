library universal_widget;

import 'package:flutter/material.dart';
import 'package:universal_widget/tweener.dart';
import 'dart:math' as math;

// export
export 'package:universal_widget/tweener.dart';

class UniversalWidget extends StatefulWidget {
  /// Create a new UniversalWidget
  UniversalWidget({
    Key key, 
    UniversalWidgetController controller,
    this.name,
    this.child,
    this.x = 0.0,
    this.y = 0.0,
    this.width,
    this.height,
    this.color,
    this.border,
    this.borderRadius,
    this.visible = true,
    this.opacity = 1,
    this.rotation = 0,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.boxShadow,
    Offset scale, transformOrigin, // transition, 
    EdgeInsetsGeometry margin, padding,
    this.animateWhenUpdate = false,
    this.durationWhenUpdate = 0.5,
    this.easeWhenUpdate,
    // widget callbacks
    this.onWidgetInit,
    this.onWidgetBuilt,
    this.onWidgetDisposed,
  }) : controller = controller ?? UniversalWidgetController(),
    transformOrigin = transformOrigin ?? Offset(0.5, 0.5),
    scale = scale ?? Offset(1,1),
    margin = margin ?? EdgeInsets.zero,
    padding = padding ?? EdgeInsets.zero,
    super(key: key);

  final String name;
  final Widget child;
  final UniversalWidgetController controller;

  final double x, y, width, height, rotation, opacity, top, bottom, left, right;
  final Color color;
  final Offset scale, transformOrigin;
  final EdgeInsetsGeometry margin, padding;
  final bool visible;
  final Border border;
  final BorderRadius borderRadius;
  final List<BoxShadow> boxShadow;

  final bool animateWhenUpdate;
  final double durationWhenUpdate;
  final Curve easeWhenUpdate;

  /// Callback method to listen for the widget's initializing event
  final VoidCallback onWidgetInit;
  /// Callback method to listen for the event after the widget was built
  final ValueChanged<BuildContext> onWidgetBuilt;
  /// Callback method to listen for the widget's disposing event
  final ValueChanged<UniversalWidget> onWidgetDisposed;
  
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
    double duration,
    Curve ease = Ease.ease,
    bool yoyo = false,
    int repeat = 0,
    double delay,
    OnTweenerUpdateCallback onUpdate,
    VoidCallback onComplete,
  }){
    controller.killAllTweens();
    if(animateWhenUpdate || duration != null){
      Tweener.to(controller, duration ?? durationWhenUpdate, 
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
        onComplete: onComplete
      );
    } else {
      if(x != null) controller.x = x + .0;
      if(y != null) controller.y = y + .0;
      if(width != null) controller.width = width + .0;
      if(height != null) controller.height = height + .0;
      if(rotation != null) controller.rotation = rotation + .0;
      if(opacity != null) controller.opacity = opacity + .0;
      if(color != null) controller.color = color;
      if(border != null) controller.border = border;
      if(borderRadius != null) controller.borderRadius = borderRadius;
      if(transformOrigin != null) controller.transformOrigin = transformOrigin;
      if(scale != null) controller.scale = scale;
      if(margin != null) controller.margin = margin;
      if(padding != null) controller.padding = padding;
      if(visible != null) controller.visible = visible;
      if(boxShadow != null) controller.boxShadow = boxShadow;

      if(top != null) controller.top = top + .0;
      if(bottom != null) controller.bottom = bottom + .0;
      if(left != null) controller.left = left + .0;
      if(right != null) controller.right = right + .0;
    }
  }

  /// Get access to widget properties
  UniversalWidgetController get(){
    return controller;
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
    return false;
  }

  /// Stop the animation of the widget
  killAllTweens(){
    if(controller!= null) controller.killAllTweens();
  }

  /// Get size of the widget (return `Size.zero` if the widget has been built yet).
  Size get size {
    Size _size = (state != null && state.context != null) ? state.context.size : Size(0,0);
    double horizontal = (controller.margin != null) ? controller.margin.horizontal : 0;
    double vertical = (controller.margin != null) ? controller.margin.vertical : 0;
    return Size(_size.width - horizontal, _size.height - vertical);
  }

  /// Get widget position on the screen.
  Offset get globalPosition {
    return (state != null && state.context != null) ? (state.context.findRenderObject() as RenderBox).localToGlobal(Offset.zero) : Offset(0, 0);
  }

  /// Get state of the widget.
  _UniversalWidgetState get state => controller.state;

  static List<UniversalWidget> _list = [];
  
  /// {Debug purspose only} To see how many `UniversalWidget` are existed on the screens.
  static debug() => _list.forEach((i) => print("UniversalWidget<${i.name}>"));
  static exists(String name){
    return (_list.where((item) => item.name == name).toList().length > 0);
  }
  /// Add `UniversalWidget` into memory
  static add(UniversalWidget widget){
    if(!exists(widget.name)) _list.add(widget);
  }
  /// Remove `UniversalWidget` from memory by name
  static remove(String name){
    if(exists(name)) _list.removeWhere((item) => (item.name == name));
  }
  /// Get the `UniversalWidget` by its given name
  static UniversalWidget find(String name){
    List<UniversalWidget> results = _list.where((item) => item.name == name).toList();
    if(results.length > 0){
      return results[0];
    } else {
      return null;
    }
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
  
  String _parentRenderType;
  bool _canChangePosition = false;
  bool _isBuiltFirstTime = true;

  @override
  void didUpdateWidget(UniversalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if(widget.controller != oldWidget.controller){
      widget.controller._state = oldWidget.controller._state;

      widget.controller._state = oldWidget.controller._state;
      widget.controller.x = (widget.x != oldWidget.x) ? widget.x : oldWidget.controller.x;
      widget.controller.y = (widget.y != oldWidget.y) ? widget.y : oldWidget.controller.y;
      widget.controller.width = (widget.width != oldWidget.width) ? widget.width : oldWidget.controller.width;
      widget.controller.height = (widget.height != oldWidget.height) ? widget.height : oldWidget.controller.height;
      widget.controller.scale = (widget.scale != oldWidget.scale) ? widget.scale : oldWidget.controller.scale;
      widget.controller.rotation = (widget.rotation != oldWidget.rotation) ? widget.rotation : oldWidget.controller.rotation;
      widget.controller.border = (widget.border != oldWidget.border) ? widget.border : oldWidget.controller.border;
      widget.controller.borderRadius = (widget.borderRadius != oldWidget.borderRadius) ? widget.borderRadius : oldWidget.controller.borderRadius;
      widget.controller.transformOrigin = (widget.transformOrigin != oldWidget.transformOrigin) ? widget.transformOrigin : oldWidget.controller.transformOrigin;
      widget.controller.opacity = (widget.opacity != oldWidget.opacity) ? widget.opacity : oldWidget.controller.opacity;
      widget.controller.visible = (widget.visible != oldWidget.visible) ? widget.visible : oldWidget.controller.visible;
      widget.controller.color = (widget.color != oldWidget.color) ? widget.color : oldWidget.controller.color;
      widget.controller.margin = (widget.margin != oldWidget.margin) ? widget.margin : oldWidget.controller.margin;
      widget.controller.padding = (widget.padding != oldWidget.padding) ? widget.padding : oldWidget.controller.padding;
      widget.controller.boxShadow = (widget.boxShadow != oldWidget.boxShadow) ? widget.boxShadow : oldWidget.controller.boxShadow;
      
      widget.controller.top = (widget.top != oldWidget.top) ? widget.top : oldWidget.controller.top;
      widget.controller.bottom = (widget.bottom != oldWidget.bottom) ? widget.bottom : oldWidget.controller.bottom;
      widget.controller.left = (widget.left != oldWidget.left) ? widget.left : oldWidget.controller.left;
      widget.controller.right = (widget.right != oldWidget.right) ? widget.right : oldWidget.controller.right;

      oldWidget.controller.removeListener(_widgetListener);
      widget.controller.addListener(_widgetListener);
    }
    
    if(widget.name != null){
      // print("$widget<${widget.name}> is updated!");
      UniversalWidget.remove(widget.name);
      UniversalWidget.add(widget);
    }

    _parentRenderType = context.ancestorRenderObjectOfType(TypeMatcher<RenderObject>()).runtimeType.toString();
    _canChangePosition = (_parentRenderType == "RenderStack");
  }

  @override
  void initState() {
    super.initState();

    if(widget.name != null){
      Future.delayed(Duration.zero, (){
        if(UniversalWidget.exists(widget.name)){
          print("[WARNING] There are multiple <UniversalWidget> that have the same name \"${widget.name}\".");
        }
        UniversalWidget.remove(widget.name);
        UniversalWidget.add(widget);
        // print("$widget<${widget.name}> is initialized!");
      });
    }

    _parentRenderType = context.ancestorRenderObjectOfType(TypeMatcher<RenderObject>()).runtimeType.toString();
    // print("_parentRenderType = $_parentRenderType");
    _canChangePosition = (_parentRenderType == "RenderStack");

    widget.controller.x = widget.x;
    widget.controller.y = widget.y;
    widget.controller.width = widget.width;
    widget.controller.height = widget.height;
    widget.controller.color = widget.color;
    widget.controller.scale = widget.scale;
    widget.controller.rotation = widget.rotation;
    widget.controller.border = widget.border;
    widget.controller.borderRadius = widget.borderRadius;
    widget.controller.transformOrigin = widget.transformOrigin;
    widget.controller.opacity = widget.opacity;
    widget.controller.visible = widget.visible;
    widget.controller.margin = widget.margin;
    widget.controller.padding = widget.padding;
    widget.controller.boxShadow = widget.boxShadow;

    widget.controller.top = widget.top;
    widget.controller.bottom = widget.bottom;
    widget.controller.left = widget.left;
    widget.controller.right = widget.right;

    // widget.controller.copyFrom(widget);
    widget.controller.addListener(_widgetListener);

    if(widget.onWidgetInit != null) widget.onWidgetInit();
  }

  _widgetListener(){
    // print("[UniversalWidget] Updated!");
    setState((){});
    
    _oldController._state = widget.controller.state;
    _oldController.copyFrom(widget.controller);
  }

  @override
  void dispose() {
    super.dispose();

    // print("$widget<${widget.name}> is disposed!");

    widget.controller.removeListener(_widgetListener);
    widget.controller.dispose();
    _oldController.dispose();
    
    if(widget.name != null){
      // print("$widget<${widget.name}> is disposed!");
      UniversalWidget.remove(widget.name);
    }

    if(widget.onWidgetDisposed != null) widget.onWidgetDisposed(widget);
  }

  Future<void> _executeAfterBuild() async {
    // print("after built");
    if(widget.onWidgetBuilt != null) widget.onWidgetBuilt(context);
  }

  @override
  Widget build(BuildContext context) {
    if(_isBuiltFirstTime){
      WidgetsBinding.instance.addPostFrameCallback((_) => _executeAfterBuild());
      _isBuiltFirstTime = false;
    }

    widget.controller._state = this;

    // print(widget.controller.margin);

    Widget container;

    container = Container(
      width: widget.controller.width,
      height: widget.controller.height,
      padding: widget.controller.padding,
      margin: widget.controller.margin,
      // transform matrix
      transform: Matrix4.identity()
        ..translate(widget.controller.x, widget.controller.y)
        ..rotateZ((widget.controller.rotation) * math.pi / 180)
        ..scale(widget.controller.scale.dx, widget.controller.scale.dy),
      alignment: FractionalOffset(widget.controller.transformOrigin.dx, widget.controller.transformOrigin.dy),
      // box decoration
      decoration: BoxDecoration(
        color: widget.controller.color,
        border: widget.controller.border,
        borderRadius: widget.controller.borderRadius,
        boxShadow: widget.controller.boxShadow,
        // image: data.backgroundImage
      ),
      child: widget.child
    );

    if(widget.controller.opacity != 1 || (widget.controller.opacity == 1 && _oldController.opacity != 1)){
      container = Opacity(
        opacity: widget.controller.opacity,
        child: container
      );
    }

    if(_canChangePosition){
      if(widget.controller.top != null || widget.controller.left != null || widget.controller.right != null || widget.controller.bottom != null){
        // print(widget.controller.left);
        container = Positioned(
          top: widget.controller.top,
          left: widget.controller.left,
          right: widget.controller.right,
          bottom: widget.controller.bottom,
          child: container
        );
      }
    }
    
    return (widget.controller.visible) ? container : Container();
  }
}

class UniversalWidgetController extends ChangeNotifier {

  _UniversalWidgetState _state;
  _UniversalWidgetState get state {
    return _state;
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
    killAllTweens();
    super.dispose();
  }

  bool diff(dynamic controller){
    if(x != controller.x) return true;
    if(y != controller.y) return true;
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

    controller._top = top;
    controller._bottom = bottom;
    controller._left = left;
    controller._right = right;
    
    controller._boxShadow = boxShadow;

    return controller;
  }

}