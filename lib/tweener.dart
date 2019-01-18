library tweener;

import 'package:flutter/animation.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:universal_widget/universal_widget.dart';

// version 0.1.8

/// A callback method when the tween animation updating
typedef void OnTweenerUpdateCallback(double progress);
/// A callback method when the tween animation finished
typedef void OnTweenerCompleteCallback(dynamic target);

class Tweener implements TickerProvider {
  /// Creates a tween that apply on a targeted [UniversalWidgetController].
  ///
  /// The [target] argument must not be null.
  /// 
  Tweener(
    this.target, 
    this.duration,
    {
    // data:
    this.x, this.y, 
    this.width, this.height, 
    this.opacity, this.rotation,
    this.color,
    this.scale, 
    this.transformOrigin,
    this.margin, this.padding,
    this.border,
    this.borderRadius,
    this.left, this.right, this.top, this.bottom,
    this.visible,
    // options
    this.delay = 0,
    this.yoyo = false,
    this.autoplay = true,
    this.repeat = 0,
    this.ease,
    this.onComplete,
    this.onUpdate,
  }){ 
    // initialized the tween:
    _init(); 
  }

  /// A target widget controller of tweener
  final UniversalWidgetController target;
  /// All avalable tweenable properties
  final double x, y, width, height, rotation, opacity, top, bottom, left, right;
  final Color color;
  final Offset scale, transformOrigin;
  final EdgeInsetsGeometry margin, padding;
  final bool visible;
  final Border border;
  final BorderRadius borderRadius;
  /// Tween options
  final double duration; // in seconds
  final double delay;
  final bool autoplay;
  final bool yoyo;
  final int repeat;
  final Curve ease;
  final VoidCallback onComplete;
  final OnTweenerUpdateCallback onUpdate;

  Ticker _ticker;
  UniversalWidgetController _oldData;

  AnimationController _controller;
  Animation<double> _animation;
  Animation<Color> _animationColor;
  Animation<BorderRadius> _animationBorderRadius;
  Animation<EdgeInsets> _animationPadding;
  Animation<EdgeInsets> _animationMargin;
  Animation<Border> _animationBorder;

  int _repeatCount = 0;
  
  @override
  Ticker createTicker(onTick) {
    _ticker = Ticker(onTick);

    // _init();

    return _ticker;
  }
  
  /// Create a new tween animation on a specific `UniversalWidgetController` with many options.
  static Tweener to(
    UniversalWidgetController target,
    double duration,
    {
      // data
      double x, y, width, height, opacity, rotation, top, bottom, left, right,
      Color color,
      Offset scale, transformOrigin,
      EdgeInsetsGeometry margin, padding,
      Border border,
      BorderRadius borderRadius,
      // options
      double delay = 0,
      int repeat = 0,
      bool autoplay = true,
      bool yoyo = false,
      Curve ease,
      VoidCallback onComplete,
      OnTweenerUpdateCallback onUpdate,
    }
  ){
    Tweener tween = Tweener(
      target,
      duration,
      // data
      x: (x != null) ? x + .0 : x,
      y: (y != null) ? y + .0 : y,
      width: (width != null) ? width + .0 : width,
      height: (height != null) ? height + .0 : height,
      scale: scale,
      rotation: (rotation != null) ? rotation + .0 : rotation,
      transformOrigin: transformOrigin,
      border: border,
      borderRadius: borderRadius,
      color: color,
      margin: margin,
      padding: padding,
      opacity: (opacity != null) ? opacity + .0 : opacity,
      top: (top != null) ? top + .0 : top,
      bottom: (bottom != null) ? bottom + .0 : bottom,
      left: (left != null) ? left + .0 : left,
      right: (right != null) ? right + .0 : right,
      // config
      delay: delay,
      repeat: repeat,
      yoyo: yoyo,
      autoplay: autoplay,
      ease: ease,
      onComplete: onComplete,
      onUpdate: onUpdate
    );

    target.add(tween);

    return tween;
  }

  /// Disposed (kill) all the current tweens of a specific `UniversalWidgetController`.
  static killTweensOf(UniversalWidgetController target){
    target.killAllTweens();
  }

  void _init() {
    // print("init tweener");
    _oldData = target.clone();
    _oldData.width = target.state.context.size.width ?? 0;
    _oldData.height = target.state.context.size.height ?? 0;
    
    if(transformOrigin != null) target.transformOrigin = transformOrigin;

    _repeatCount = 0;

    int speed = (duration * 1000).toInt();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: speed), 
      vsync: this
    );

    Curve tweenEase = (ease == null) ? Ease.ease : ease;
    CurvedAnimation curve = CurvedAnimation(parent: _controller, curve: tweenEase);

    // Animations

    bool shouldAnimating = false;

    if(color != null){
      shouldAnimating = true;
      _animationColor = ColorTween(begin: target.color, end: color).animate(curve);
      _animationColor.addListener(_onColorAnimating);
    }

    if(border != null){
      shouldAnimating = true;
      _animationBorder = BorderTween(begin: target.border, end: border).animate(curve);
      _animationBorder.addListener(_onBorderAnimating);
    }

    if(borderRadius != null){
      shouldAnimating = true;
      _animationBorderRadius = BorderRadiusTween(begin: target.borderRadius, end: borderRadius).animate(curve);
      _animationBorderRadius.addListener(_onBorderRadiusAnimating);
    }

    if(padding != null){
      shouldAnimating = true;
      _animationPadding = EdgeInsetsTween(begin: target.padding, end: padding).animate(curve);
      _animationPadding.addListener(_onPaddingAnimating);
    }

    if(margin != null){
      shouldAnimating = true;
      _animationMargin = EdgeInsetsTween(begin: target.margin, end: margin).animate(curve);
      _animationMargin.addListener(_onMarginAnimating);
    }
    
    // Trying to improve performance: [Removed]
    if(top != null || left != null || right != null || bottom != null 
    || width != null || height != null || rotation != null
    || opacity != null || scale != null || x != null || y != null)
    {
      _animation = Tween(begin: 0.0, end: 1.0).animate(curve);
      _animation.addStatusListener(_onAnimationStatus);
      _animation.addListener(_onAnimating);
      shouldAnimating = true;
    }

    // Note: Always run animation because it's possible 
    // to tween "width" and "height" to null now!
    // _animation = Tween(begin: 0.0, end: 1.0).animate(curve);
    // _animation.addStatusListener(_onAnimationStatus);
    // _animation.addListener(_onAnimating);
    // shouldAnimating = true;

    // print("shouldAnimating = $shouldAnimating");
    if(!shouldAnimating){
      dispose();
      return;
    }

    if(autoplay){
      if(delay != null && delay != 0){
        Future.delayed(Duration(milliseconds: (delay * 1000).toInt() ), play);
      } else {
        play();
      }
    }
  }

  void _onAnimating(){
    double progress = _animation.value;

    if(target != null){
      if(top != null) {
        if(_oldData.top == null) _oldData.top = 0;
        target.top = _oldData.top + progress * (top - _oldData.top);
      }
      if(left != null) {
        if(_oldData.left == null) _oldData.left = 0;
        target.left = _oldData.left + progress * (left - _oldData.left);
      }
      if(right != null) {
        if(_oldData.right == null) _oldData.right = 0;
        target.right = _oldData.right + progress * (right - _oldData.right);
      }
      if(bottom != null) {
        if(_oldData.bottom == null) _oldData.bottom = 0;
        target.bottom = _oldData.bottom + progress * (bottom - _oldData.bottom);
      }
      
      if(width != null){
        target.width = _oldData.width + progress * (width - _oldData.width);
      } else {
        target.width = _oldData.width + progress * (target.state.initSize.width - _oldData.width);
      }
      
      if(height != null){
        target.height = _oldData.height + progress * (height - _oldData.height);
      } else {
        target.height = _oldData.height + progress * (target.state.initSize.height - _oldData.height);
      }

      if(opacity != null) target.opacity = _oldData.opacity + progress * (opacity - _oldData.opacity);
      if(rotation != null) target.rotation = _oldData.rotation + progress * (rotation - _oldData.rotation);

      if(scale != null) {
        target.scale = Offset(
          _oldData.scale.dx + progress * (scale.dx - _oldData.scale.dx), 
          _oldData.scale.dy + progress * (scale.dy - _oldData.scale.dy)
        );
      }

      if(x != null && x != _oldData.x) target.x = _oldData.x + progress * (x - _oldData.x);
      if(y != null && y != _oldData.y) target.y = _oldData.y + progress * (y - _oldData.y);
    }
    
    if(onUpdate != null) onUpdate(progress);
  }

  void _onColorAnimating(){
    target?.color = _animationColor.value;
  }

  void _onBorderAnimating(){
    target?.border = _animationBorder.value;
  }

  void _onBorderRadiusAnimating(){
    target?.borderRadius = _animationBorderRadius.value;
  }

  void _onPaddingAnimating(){
    target?.padding = _animationPadding.value;
  }

  void _onMarginAnimating(){
    target?.margin = _animationMargin.value;
  }

  void _onAnimationStatus(status){
    if (status == AnimationStatus.completed) {
      if(yoyo){
        _controller.reverse();
      } else {
        if(repeat == 0){
          target.killTween(this);
        } else {
          if(!_countRepeatEnd()){
            _controller.reset();
          }
        }
      }
      if(onComplete != null) onComplete();
    } else if (status == AnimationStatus.dismissed) {
      if(repeat != 0) {
        _controller.forward();
        if(yoyo) _countRepeatEnd();
      } else {
        target.killTween(this);
      }
    }
  }

  bool _countRepeatEnd(){
    bool isEnded = false;
    _repeatCount++;
    if(_repeatCount == repeat){
      isEnded = true;
      target.killTween(this);
    }
    return isEnded;
  }

  /// Stop (paused) playing the tween animation.
  Tweener stop(){
    if(_controller != null) _controller.stop();
    return this;
  }

  /// Start playing the tween animation.
  Tweener play(){
    if(_controller != null) _controller.forward();
    return this;
  }

  /// Seek the the tween animation to the specific progress position.
  ///
  /// The `timeScalePosition` argument must not be null. It gives the animation progress from 0.0 to 1.0
  Tweener seek(double timeScalePosition){
    if(_controller != null){
      if(timeScalePosition > 1) timeScalePosition = 1;
      if(timeScalePosition < 0) timeScalePosition = 0;
      _controller.value = timeScalePosition;
    }
    return this;
  }

  /// Disposed (kill) the tween animation.
  void dispose() {
    // print(_controller);
    if(_controller != null){
      _controller.dispose();
      _controller = null;
    }
    if(_ticker != null) _ticker.dispose();
  }

}

/// A collection of common animation easing.
class Ease {
  static const Curve linear = Curves.linear;
  static const Curve decelerate = Curves.decelerate;
  static const Curve ease = Curves.ease;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve bounceInOut = Curves.bounceInOut;
  static const Curve elasticIn = Curves.elasticIn;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve elasticInOut = Curves.elasticInOut;
  // new easing:
  static const Curve backOut = BackOutCurve();
  static const Curve backIn = BackInCurve();
  static const Curve backInOut = BackInOutCurve();
  static const Curve slowMo = SlowMoCurve();
  static const Curve sineOut = SineOutCurve();
  static const Curve sineIn = SineInCurve();
  static const Curve sineInOut = SineInOutCurve();
}

/// An oscillating curve that shrinks in magnitude while overshooting its bounds.
///
/// An instance of this class using the default period of 0.4 is available as
/// [Ease.backOut].
///
class BackOutCurve extends Curve {
  /// Creates an back-out curve.
  ///
  /// Rather than creating a new instance, consider using [Ease.backOut].
  const BackOutCurve([this.period = 0.4]);

  /// The duration of the oscillation.
  final double period;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    // final double s = period / 4.0;
    final double _p1 = 1.70158;
    // final double _p2 = _p1 * 1.525;
    final double result = ((t = t - 1) * t * ((_p1 + 1) * t + _p1) + 1);
    return result;
  }

  @override
  String toString() {
    return '$runtimeType($period)';
  }
}

/// An oscillating curve that shrinks in magnitude while overshooting its bounds.
///
/// An instance of this class using the default period of 0.4 is available as
/// [Ease.backIn].
///
class BackInCurve extends Curve {
  /// Creates an back-in curve.
  ///
  /// Rather than creating a new instance, consider using [Ease.backIn].
  const BackInCurve([this.period = 0.4]);

  /// The duration of the oscillation.
  final double period;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    // final double s = period / 4.0;
    final double _p1 = 1.70158;
    // final double _p2 = _p1 * 1.525;
    final double result = t * t * ((_p1 + 1) * t - _p1);
    return result;
  }

  @override
  String toString() {
    return '$runtimeType($period)';
  }
}

/// An oscillating curve that shrinks in magnitude while overshooting its bounds.
///
/// An instance of this class using the default period of 0.4 is available as
/// [Ease.backInOut].
///
class BackInOutCurve extends Curve {
  /// Creates an back-in curve.
  ///
  /// Rather than creating a new instance, consider using [Ease.backInOut].
  const BackInOutCurve([this.period = 0.4]);

  /// The duration of the oscillation.
  final double period;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    // final double s = period / 4.0;
    final double _p1 = 1.70158;
    final double _p2 = _p1 * 1.525;
    final double result = ((t *= 2) < 1) ? 0.5 * t * t * ((_p2 + 1) * t - _p2) : 0.5 * ((t -= 2) * t * ((_p2 + 1) * t + _p2) + 2);
    return result;
  }

  @override
  String toString() {
    return '$runtimeType($period)';
  }
}

/// An oscillating curve that shrinks in magnitude while overshooting its bounds.
///
/// An instance of this class using the default period of 0.4 is available as
/// [Ease.slowMo].
///
class SlowMoCurve extends Curve {
  /// Creates an slow-mo curve.
  ///
  /// Rather than creating a new instance, consider using [Ease.slowMo].
  const SlowMoCurve([this.power = 0.7]);

  /// The duration of the oscillation.
  final double power;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    final double linearRatio = 0.7;
    final double _p = power;
    final double _p1 = (1 - linearRatio) / 2;
    final double _p2 = linearRatio;
    final double _p3 = _p1 + _p2;
    final double r = t + (0.5 - t) * _p;
    double result = r;
    if (t < _p1) {
      result = r - ((t = 1 - (t / _p1)) * t * t * t * r);
    } else if (t > _p3) {
      result = r + ((t - r) * (t = (t - _p3) / _p1) * t * t * t); 
    }
    return result;
  }

  @override
  String toString() {
    return '$runtimeType($power)';
  }
}

/// An oscillating curve that shrinks in magnitude while overshooting its bounds.
///
/// An instance of this class using the default period of 0.4 is available as
/// [Ease.sineOut].
///
class SineOutCurve extends Curve {
  /// Creates an sine-out curve.
  ///
  /// Rather than creating a new instance, consider using [Ease.sineOut].
  const SineOutCurve();

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    final double haftPi = math.pi / 2;
    final double result = math.sin(t * haftPi);
    return result;
  }

  @override
  String toString() {
    return '$runtimeType()';
  }
}

/// An oscillating curve that shrinks in magnitude while overshooting its bounds.
///
/// An instance of this class using the default period of 0.4 is available as
/// [Ease.sineIn].
///
class SineInCurve extends Curve {
  /// Creates an sine-in curve.
  ///
  /// Rather than creating a new instance, consider using [Ease.sineIn].
  const SineInCurve();

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    final double haftPi = math.pi / 2;
    final double result = -math.cos(t * haftPi) + 1;
    return result;
  }

  @override
  String toString() {
    return '$runtimeType()';
  }
}

/// An oscillating curve that shrinks in magnitude while overshooting its bounds.
///
/// An instance of this class using the default period of 0.4 is available as
/// [Ease.sineInOut].
///
class SineInOutCurve extends Curve {
  /// Creates an sine-in-out curve.
  ///
  /// Rather than creating a new instance, consider using [Ease.sineInOut].
  const SineInOutCurve();

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    final double result = -0.5 * (math.cos(math.pi * t) - 1);
    return result;
  }

  @override
  String toString() {
    return '$runtimeType()';
  }
}