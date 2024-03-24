import 'dart:convert';

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

  bool _buttonPressed = false;
  bool _loopActive = false;

  void loadConfig() async {
    getUrl();
    Map<String, dynamic> configuration = await fetchConfig(urlApi);
    panSliderValue = double.parse(configuration['current_pan']);
    tiltSliderValue = double.parse(configuration['current_tilt']);
    zoomSliderValue = double.parse(configuration['current_zoom']);
    notifyListeners();
  }

    Future<String> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String  url = prefs.getString("url") ?? 'http://192.168.10.106:5000';
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
        httpRequest('PAN', value);
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
        httpRequest('TILT', value);
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
        httpRequest('ZOOM', value);
        zoomSliderValue = value;
      }
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
    _loopActive = false;
  }

  void httpRequest(String operation, double value) async {
    String urlOp = '';
    switch (operation) {
      case 'TILT':
        urlOp = '/tilt?value=${value.round()}';
      case 'PAN':
        urlOp = '/pan?value=${value.round()}';
      case 'ZOOM':
        urlOp = '/zoom?value=${value.round()}';
    }
    try {
      print('executing $urlOp');
      final response = await http.get(Uri.parse(urlApi + urlOp));
      if (response.statusCode != 200) {
        message = 'Failed to load set value';
      } else {
        message = 'Success change';
      }
      print(message);
      notifyListeners();
    } on Exception catch (_) {
      print('Error: failed to fetch configuration URL');
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
                    icon: Icon(Icons.settings), label: Text('Settings'))
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
      BigCard(sliderValue: sliderPanValue*-1),
      SliderPan(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Listener(
          onPointerDown: (details) {
            appState.setButtonPressed(true);
            appState.pan(sliderPanValue, 'DECREASE');
          },
          onPointerUp: (details) {
            appState.setButtonPressed(false);
          },
          child: OutlinedButton(
              onPressed: () => {}, child: Icon(Icons.skip_previous)),
        ),
        Listener(
          onPointerDown: (details) {
            appState.setButtonPressed(true);
            appState.pan(sliderPanValue, 'RESET');
          },
          onPointerUp: (details) {
            appState.setButtonPressed(false);
          },
          child: OutlinedButton(onPressed: () => {}, child: Icon(Icons.repeat)),
        ),
        Listener(
          onPointerDown: (details) {
            appState.setButtonPressed(true);
            appState.pan(sliderPanValue, 'INCREASE');
          },
          onPointerUp: (details) {
            appState.setButtonPressed(false);
          },
          child:
              OutlinedButton(onPressed: () => {}, child: Icon(Icons.skip_next)),
        )
      ]),
      Text('tilt'),
      BigCard(sliderValue: sliderTiltValue),
      SliderTilt(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Listener(
            onPointerDown: (details) {
              appState.setButtonPressed(true);
              appState.tilt(sliderTiltValue, 'DECREASE');
            },
            onPointerUp: (details) {
              appState.setButtonPressed(false);
            },
            child: OutlinedButton(
                onPressed: () => {}, child: Icon(Icons.skip_previous)),
          ),
          Listener(
            onPointerDown: (details) {
              appState.setButtonPressed(true);
              appState.tilt(sliderTiltValue, 'RESET');
            },
            onPointerUp: (details) {
              appState.setButtonPressed(false);
            },
            child:
                OutlinedButton(onPressed: () => {}, child: Icon(Icons.repeat)),
          ),
          Listener(
            onPointerDown: (details) {
              appState.setButtonPressed(true);
              appState.tilt(sliderTiltValue, 'INCREASE');
            },
            onPointerUp: (details) {
              appState.setButtonPressed(false);
            },
            child: OutlinedButton(
                onPressed: () => {}, child: Icon(Icons.skip_next)),
          )
        ],
      ),
      Text('Zoom'),
      BigCard(sliderValue: sliderZoomValue),
      SliderZoom(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Listener(
            onPointerDown: (details) {
              appState.setButtonPressed(true);
              appState.zoom(sliderZoomValue, 'DECREASE');
            },
            onPointerUp: (details) {
              appState.setButtonPressed(false);
            },
            child: OutlinedButton(
                onPressed: () => {}, child: Icon(Icons.skip_previous)),
          ),
          Listener(
            onPointerDown: (details) {
              appState.setButtonPressed(true);
              appState.zoom(sliderZoomValue, 'RESET');
            },
            onPointerUp: (details) {
              appState.setButtonPressed(false);
            },
            child:
                OutlinedButton(onPressed: () => {}, child: Icon(Icons.repeat)),
          ),
          Listener(
            onPointerDown: (details) {
              appState.setButtonPressed(true);
              appState.zoom(sliderZoomValue, 'INCREASE');
            },
            onPointerUp: (details) {
              appState.setButtonPressed(false);
            },
            child: OutlinedButton(
                onPressed: () => {}, child: Icon(Icons.skip_next)),
          )
        ],
      ),
    ]));
  }
}

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
      value: currentSliderValue*-1,
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

class ConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return FutureBuilder(future: appState.getUrl(),
     initialData: "loading url",
     builder: (BuildContext context, AsyncSnapshot<String> text){
     return Center(
      child: Column(
        children: [
          Text("Url Api"),
          TextFormField(
          decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
             onChanged: (value) {
              appState.setUrl(value);
            },
            initialValue: appState.urlApi
          )
        ],
      ),
     );
      });
  }
   
    // var appState = context.watch<MyAppState>();
    // String urlApi = appState.getUrl();
    // return Center(
    //   child: Column(
    //     children: [
    //       Text('Url API'),
    //       TextFormField(
    //         decoration: InputDecoration(
    //           border: OutlineInputBorder(),
    //         ),
    //         onChanged: (value) {
    //           appState.setUrl(value);
    //         },
    //         initialValue: urlApi;
    //       ),
    //     ],
    //   ),
    // );
  //}
}
