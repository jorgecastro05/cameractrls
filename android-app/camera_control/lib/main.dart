import 'dart:convert';
import 'dart:ffi';

import 'package:camera_control/sliders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> fetchConfig(String urlApi) async {
  try {
    final response = await http.get(Uri.parse('$urlApi/props'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get API Config');
    }
  } on Exception catch (_) {
    return {'Error': 'failed to fetch configuration URL'};
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'camera control',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
          home: MyHomePage(),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  double panSliderValue = 0;
  double tiltSliderValue = 0;
  double zoomSliderValue = 100;
  String urlApi = '';
  String message = '';
  double panMax = 522000;
  double panMin = -522000;
  double panDefault = 0;
  double tiltDefault = 0;
  double tiltMax = 360000;
  double tiltMin = -324000;
  double panStep = 3600;
  double tiltStep = 3600;
  double zoomStep = 10;
  double zoomMin = 100;
  double zoomMax = 400;
  int milliseconds = 150;

  // new properties
  double brightnessMax = 100;
  double brightnessMin = 0;
  double brightnessDefault = 50;
  double brightnessStep = 1;
  double brightnessSliderValue = 0;

  double contrastMax = 100;
  double contrastMin = 0;
  double contrastDefault = 50;
  double contrastStep = 1;
  double contrastSliderValue = 0;

  double saturationMax = 100;
  double saturationMin = 0;
  double saturationDefault = 50;
  double saturationStep = 1;
  double saturationSliderValue = 0;

  double sharpnessMax = 100;
  double sharpnessMin = 0;
  double sharpnessDefault = 50;
  double sharpnessStep = 1;
  double sharpnessSliderValue = 0;

  bool _buttonPressed = false;
  bool _loopActive = false;

  void loadConfig() async {
    await getUrl();
    Map<String, dynamic> configuration = await fetchConfig(urlApi);
    panSliderValue = double.parse(configuration['current_pan']);
    tiltSliderValue = double.parse(configuration['current_tilt']);
    zoomSliderValue = double.parse(configuration['current_zoom']);

    brightnessSliderValue = double.parse(configuration['current_brightness']);
    contrastSliderValue = double.parse(configuration['current_contrast']);
    saturationSliderValue = double.parse(configuration['current_saturation']);
    sharpnessSliderValue = double.parse(configuration['current_sharpness']);

    notifyListeners();
  }

  Future<String> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String url = prefs.getString("url") ?? 'http://192.168.10.106:5000';
    debugPrint("url get: $url");
    urlApi = url;
    return urlApi;
  }

  void setUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    urlApi = url;
    prefs.setString("url", urlApi);
    notifyListeners();
  }

  void setButtonPressed(bool value) {
    _buttonPressed = value;
  }

  void pan(double value, String operation) async {
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      switch (operation) {
        case 'INCREASE':
          value -= panStep;
        case 'DECREASE':
          value += panStep;
        case 'RESET':
          value = panDefault;
      }
      if (value <= panMax && value >= panMin) {
        httpRequest('pan', value);
        panSliderValue = value;
      }
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
    _loopActive = false;
  }

  void tilt(double value, String operation) async {
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      switch (operation) {
        case 'INCREASE':
          value += tiltStep;
        case 'DECREASE':
          value -= tiltStep;
        case 'RESET':
          value = tiltDefault;
      }
      if (value <= tiltMax && value >= tiltMin) {
        httpRequest('tilt', value);
        tiltSliderValue = value;
      }
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
    _loopActive = false;
  }

  void zoom(double value, String operation) async {
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      switch (operation) {
        case 'INCREASE':
          value += zoomStep;
        case 'DECREASE':
          value -= zoomStep;
        case 'RESET':
          value = zoomMin;
      }
      if (value <= zoomMax && value >= zoomMin) {
        httpRequest('zoom', value);
        zoomSliderValue = value;
      }
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
    _loopActive = false;
  }

  void brightness(double value, String operation) async {
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      switch (operation) {
        case 'INCREASE':
          value += brightnessStep;
        case 'DECREASE':
          value -= brightnessStep;
        case 'RESET':
          value = brightnessDefault;
      }
      if (value <= brightnessMax && value >= brightnessMin) {
        httpRequest('brightness', value);
        brightnessSliderValue = value;
      }
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
    _loopActive = false;
  }

  void contrast(double value, String operation) async {
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      switch (operation) {
        case 'INCREASE':
          value += contrastStep;
        case 'DECREASE':
          value -= contrastStep;
        case 'RESET':
          value = contrastDefault;
      }
      if (value <= contrastMax && value >= contrastMin) {
        httpRequest('contrast', value);
        contrastSliderValue = value;
      }
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
    _loopActive = false;
  }

  void saturation(double value, String operation) async {
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      switch (operation) {
        case 'INCREASE':
          value += saturationStep;
        case 'DECREASE':
          value -= saturationStep;
        case 'RESET':
          value = sharpnessDefault;
      }
      if (value <= saturationMax && value >= saturationMin) {
        httpRequest('saturation', value);
        saturationSliderValue = value;
      }
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
    _loopActive = false;
  }

  void sharpness(double value, String operation) async {
    if (_loopActive) return;
    _loopActive = true;
    while (_buttonPressed) {
      switch (operation) {
        case 'INCREASE':
          value += sharpnessStep;
        case 'DECREASE':
          value -= sharpnessStep;
        case 'RESET':
          value = sharpnessDefault;
      }
      if (value <= sharpnessMax && value >= sharpnessMin) {
        httpRequest('sharpness', value);
        sharpnessSliderValue = value;
      }
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
    _loopActive = false;
  }

  void httpRequest(String operation, double value) async {
    String urlOp = '/$operation?value=${value.round()}';
    try {
      debugPrint('executing $urlOp');
      final response = await http.get(Uri.parse(urlApi + urlOp));
      if (response.statusCode != 200) {
        message = 'Failed to load set value';
      } else {
        message = 'Success change';
      }
      debugPrint(message);
      notifyListeners();
    } on Exception catch (_) {
      debugPrint('Error: failed to fetch configuration URL');
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ControlPage();
      case 1:
        page = ConfigPage();
      case 2:
        page = ControlPropsPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constrains) {
      return Scaffold(
          body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: constrains.maxWidth >= 600,
              destinations: [
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(
                    icon: Icon(Icons.settings), label: Text('Settings')),
                NavigationRailDestination(
                    icon: Icon(Icons.circle), label: Text('Settings 2'))
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ));
    });
  }
}

class ControlPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    double sliderPanValue = appState.panSliderValue;
    double sliderTiltValue = appState.tiltSliderValue;
    double sliderZoomValue = appState.zoomSliderValue;

    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      OutlinedButton(
          onPressed: () => {appState.loadConfig()},
          child: const Text("Load current values from cam")),
      Text('pan'),
      BigCard(sliderValue: sliderPanValue * -1),
      SliderPan(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ListenerCamera(
            appState: appState,
            sliderValue: sliderPanValue,
            operation: 'DECREASE',
            icon: Icons.skip_previous,
            option: 'pan'),
        ListenerCamera(
            appState: appState,
            sliderValue: sliderPanValue,
            operation: 'RESET',
            icon: Icons.repeat,
            option: 'pan'),
        ListenerCamera(
            appState: appState,
            sliderValue: sliderPanValue,
            operation: 'INCREASE',
            icon: Icons.skip_next,
            option: 'pan')
      ]),
      Text('tilt'),
      BigCard(sliderValue: sliderTiltValue),
      SliderTilt(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListenerCamera(
              appState: appState,
              sliderValue: sliderTiltValue,
              operation: 'DECREASE',
              icon: Icons.skip_previous,
              option: 'tilt'),
          ListenerCamera(
              appState: appState,
              sliderValue: sliderTiltValue,
              operation: 'RESET',
              icon: Icons.repeat,
              option: 'tilt'),
          ListenerCamera(
              appState: appState,
              sliderValue: sliderTiltValue,
              operation: 'INCREASE',
              icon: Icons.skip_next,
              option: 'tilt')
        ],
      ),
      Text('Zoom'),
      BigCard(sliderValue: sliderZoomValue),
      SliderZoom(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListenerCamera(
              appState: appState,
              sliderValue: sliderZoomValue,
              operation: 'DECREASE',
              icon: Icons.skip_previous,
              option: 'zoom'),
          ListenerCamera(
              appState: appState,
              sliderValue: sliderZoomValue,
              operation: 'RESET',
              icon: Icons.repeat,
              option: 'zoom'),
          ListenerCamera(
              appState: appState,
              sliderValue: sliderZoomValue,
              operation: 'INCREASE',
              icon: Icons.skip_next,
              option: 'zoom')
        ],
      ),
    ]));
  }
}

class ControlPropsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    double brightnessSliderValue = appState.brightnessSliderValue;
    double contrastSliderValue = appState.contrastSliderValue;
    double saturationSliderValue = appState.saturationSliderValue;
    double sharpnessSliderValue = appState.sharpnessSliderValue;

    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      OutlinedButton(
          onPressed: () => {appState.loadConfig()},
          child: const Text("Load current values from cam")),
      Text('brightness'),
      BigCard(sliderValue: brightnessSliderValue),
      SliderBrightness(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ListenerCamera(
            appState: appState,
            sliderValue: brightnessSliderValue,
            operation: 'DECREASE',
            icon: Icons.skip_previous,
            option: 'brightness'),
        ListenerCamera(
            appState: appState,
            sliderValue: brightnessSliderValue,
            operation: 'RESET',
            icon: Icons.repeat,
            option: 'brightness'),
        ListenerCamera(
            appState: appState,
            sliderValue: brightnessSliderValue,
            operation: 'INCREASE',
            icon: Icons.skip_next,
            option: 'brightness')
      ]),
      Text('contrast'),
      BigCard(sliderValue: contrastSliderValue),
      SliderContrast(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListenerCamera(
              appState: appState,
              sliderValue: contrastSliderValue,
              operation: 'DECREASE',
              icon: Icons.skip_previous,
              option: 'contrast'),
          ListenerCamera(
              appState: appState,
              sliderValue: contrastSliderValue,
              operation: 'RESET',
              icon: Icons.repeat,
              option: 'contrast'),
          ListenerCamera(
              appState: appState,
              sliderValue: contrastSliderValue,
              operation: 'INCREASE',
              icon: Icons.skip_next,
              option: 'contrast')
        ],
      ),
      Text('saturation'),
      BigCard(sliderValue: saturationSliderValue),
      SliderSaturation(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListenerCamera(
              appState: appState,
              sliderValue: saturationSliderValue,
              operation: 'DECREASE',
              icon: Icons.skip_previous,
              option: 'saturation'),
          ListenerCamera(
              appState: appState,
              sliderValue: saturationSliderValue,
              operation: 'RESET',
              icon: Icons.repeat,
              option: 'saturation'),
          ListenerCamera(
              appState: appState,
              sliderValue: saturationSliderValue,
              operation: 'INCREASE',
              icon: Icons.skip_next,
              option: 'saturation')
        ],
      ),
      Text('sharpness'),
      BigCard(sliderValue: sharpnessSliderValue),
      SliderSharpness(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListenerCamera(
              appState: appState,
              sliderValue: sharpnessSliderValue,
              operation: 'DECREASE',
              icon: Icons.skip_previous,
              option: 'sharpness'),
          ListenerCamera(
              appState: appState,
              sliderValue: sharpnessSliderValue,
              operation: 'RESET',
              icon: Icons.repeat,
              option: 'sharpness'),
          ListenerCamera(
              appState: appState,
              sliderValue: sharpnessSliderValue,
              operation: 'INCREASE',
              icon: Icons.skip_next,
              option: 'sharpness')
        ],
      ),
    ]));
  }
}


class ListenerCamera extends StatelessWidget {
  const ListenerCamera(
      {super.key,
      required this.appState,
      required this.sliderValue,
      required this.operation,
      required this.icon,
      required this.option});

  final MyAppState appState;
  final double sliderValue;
  final String operation;
  final IconData icon;
  final String option;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        appState.setButtonPressed(true);
        switch (option) {
          case 'pan':
            appState.pan(sliderValue, operation);
          case 'tilt':
            appState.tilt(sliderValue, operation);
          case 'zoom':
            appState.zoom(sliderValue, operation);
          case 'brightness':
            appState.brightness(sliderValue, operation);
          case 'contrast':
            appState.contrast(sliderValue, operation);
          case 'saturation':
            appState.saturation(sliderValue, operation);
          case 'sharpness':
            appState.sharpness(sliderValue, operation);
        }
      },
      onPointerUp: (details) {
        appState.setButtonPressed(false);
      },
      child: OutlinedButton(onPressed: () => {}, child: Icon(icon)),
    );
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.sliderValue,
  });

  final double sliderValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          sliderValue.round().toString(),
          style: style,
          semanticsLabel: sliderValue.toString(),
        ),
      ),
    );
  }
}

class ConfigPage extends StatefulWidget {
  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return FutureBuilder(
        future: appState.getUrl(),
        initialData: "loading url",
        builder: (BuildContext context, AsyncSnapshot<String> text) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('current url saved: ${text.data}'),
                TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      appState.setUrl(value);
                    },
                    initialValue: appState.urlApi)
              ],
            ),
          );
        });
  }
}
