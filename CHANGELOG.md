## [1.2.4] - Fixed bug

* Fixed bug of not tweening the `rotation` attribute.

## [1.2.4] - Fixed bug

* Fixed error: `A UniversalWidgetController was used after being disposed.`.
 
## [1.2.0] - Big performance improvement, added `UniversalChannel` & a lot new features

* Performance improved much better.
* Added `widget.reset()` to reset the `UniversalWidget` to the very first time it's created.
* Added `widget.onEnterFrame(callback, {int fps})` and `widget.stopEnterFrame()` (OMG, this one is so much fun!).
* Added `widget.toByte({pixelRatio})`, `widget.toImage({pixelRatio})`, `widget.toBase64({pixelRatio})` to capture the widget and convert it to image/base64/byte.
* Added `UniversalChannel` to communicate between `UniversalWidget`s **(Full documentation & Examples will come later)**.
* Fixed some minor bugs.

## [1.1.2] - More features & fixed bugs.

* Changed `onWidgetBuilt(BuildContext)` to `onWidgetBuild(UniversalWitget)`.
* Added `onWidgetUpdated(UniversalWidget)`.
* Added `override (bool)` to `update()` method, default value is `true`, so you can do multiple `update()` animation at the sametime. 
* Added `stopAnimation()` method in case you want to stop all animations of the widget.
* Added `interaction` properties to enable/disable interactivity of the widget.
* Fixed losing state issue (when update widget while state hasn't been created).
* Fixed some minor bugs.

## [1.1.1] - Fixed some minor bugs.

* Update documentation.
* Added example.

## [1.1.0] - Added more features & Fixed some minor bugs.

* Updated the documentation.
* Added button mode with `onPressed`.
* Added `mask` (clip) feature.
* Added `update(child)` feature.
* Fixed some minor bugs.
* TODO: Performance improvement.

## [1.0.0] - Publish the widget.

* TODO: Wait for the bugs?
* TODO: Performance improvement.
