import 'dart:js_interop';

@JS('initAudioContext')
external void _initAudioContext();

@JS('playTone')
external void _playTone(double freq, double duration);

@JS('triggerVibrate')
external void _triggerVibrate(JSArray<JSNumber> pattern);

void initAudio() => _initAudioContext();

void playTone(double freq, double duration) => _playTone(freq, duration);

void triggerVibrate(List<int> pattern) {
  // Convert List<int> to JSArray<JSNumber>
  final jsArray = pattern.map((e) => e.toJS).toList().toJS;
  _triggerVibrate(jsArray);
}
