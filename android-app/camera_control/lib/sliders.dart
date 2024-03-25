import 'package:camera_control/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SliderPan extends StatefulWidget {
  const SliderPan({super.key});

  @override
  State<SliderPan> createState() => _SliderPanState();
}

class _SliderPanState extends State<SliderPan> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentSliderValue = appState.panSliderValue;
    String message = appState.message;
    return Slider(
      value: currentSliderValue * -1,
      min: appState.panMin,
      max: appState.panMax,
      divisions: appState.panMax ~/ appState.panStep,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {},
    );
  }
}


class SliderTilt extends StatefulWidget {
  const SliderTilt({super.key});

  @override
  State<SliderTilt> createState() => _SliderTiltState();
}

class _SliderTiltState extends State<SliderTilt> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentSliderValue = appState.tiltSliderValue;
    String message = appState.message;
    return Slider(
      value: currentSliderValue,
      min: appState.tiltMin,
      max: appState.tiltMax,
      divisions: appState.tiltMax ~/ appState.tiltStep,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {},
    );
  }
}

class SliderZoom extends StatefulWidget {
  const SliderZoom({super.key});

  @override
  State<SliderZoom> createState() => _SliderZoomState();
}

class _SliderZoomState extends State<SliderZoom> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentSliderValue = appState.zoomSliderValue;
    String message = appState.message;
    return Slider(
      value: currentSliderValue,
      min: appState.zoomMin,
      max: appState.zoomMax,
      divisions: appState.zoomMax ~/ appState.zoomStep,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {},
    );
  }
}

class SliderBrightness extends StatefulWidget {
  const SliderBrightness({super.key});

  @override
  State<SliderBrightness> createState() => _SliderBrightnessState();
}

class _SliderBrightnessState extends State<SliderBrightness> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentSliderValue = appState.brightnessSliderValue;
    String message = appState.message;
    return Slider(
      value: currentSliderValue,
      min: appState.brightnessMin,
      max: appState.brightnessMax,
      divisions: appState.brightnessMax ~/ appState.brightnessStep,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {},
    );
  }
}

class SliderContrast extends StatefulWidget {
  const SliderContrast({super.key});

  @override
  State<SliderContrast> createState() => _SliderContrastState();
}

class _SliderContrastState extends State<SliderContrast> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentSliderValue = appState.contrastSliderValue;
    String message = appState.message;
    return Slider(
      value: currentSliderValue,
      min: appState.contrastMin,
      max: appState.contrastMax,
      divisions: appState.contrastMax ~/ appState.contrastStep,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {},
    );
  }
}

class SliderSaturation extends StatefulWidget {
  const SliderSaturation({super.key});

  @override
  State<SliderSaturation> createState() => _SliderSaturationState();
}

class _SliderSaturationState extends State<SliderSaturation> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentSliderValue = appState.saturationSliderValue;
    String message = appState.message;
    return Slider(
      value: currentSliderValue,
      min: appState.saturationMin,
      max: appState.saturationMax,
      divisions: appState.saturationMax ~/ appState.saturationStep,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {},
    );
  }
}


class SliderSharpness extends StatefulWidget {
  const SliderSharpness({super.key});

  @override
  State<SliderSharpness> createState() => _SliderSharpnessState();
}

class _SliderSharpnessState extends State<SliderSharpness> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentSliderValue = appState.sharpnessSliderValue;
    String message = appState.message;
    return Slider(
      value: currentSliderValue,
      min: appState.sharpnessMin,
      max: appState.sharpnessMax,
      divisions: appState.sharpnessMax ~/ appState.sharpnessStep,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {},
    );
  }
}