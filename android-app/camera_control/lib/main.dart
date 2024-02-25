import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  String urlApi = 'http://192.168.10.106:5000';
  late Future<Map<String, dynamic>> configuration;
  String message = '';
  double panMax = 0;
  double panMin = 0;
  double tiltMax = 0;
  double tiltMin = 0;

  void setConfig(Future<Map<String, dynamic>> config) {
    configuration = config;
    config.then((value) => {});
  }

  void setUrl(String url) {
    urlApi = url;
    notifyListeners();
  }

  void pan(double value) async {
    panSliderValue = value;
    String operation = '/pan?value=${panSliderValue.round()}';
    print(Uri.parse(urlApi + operation));
    try {
    final response = await http.get(Uri.parse(urlApi + operation));
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

  void tilt(double value) async {
    tiltSliderValue = value;
    String operation = '/tilt?value=${tiltSliderValue.round()}';
    print(Uri.parse(urlApi + operation));
    final response = await http.get(Uri.parse(urlApi + operation));
    if (response.statusCode != 200) {
      message = 'Failed to load set value';
    } else {
      message = 'Success change';
    }
    print(message);
    notifyListeners();
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
    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          Text('pan'),
          BigCard(sliderValue: sliderPanValue),
          SliderPan(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                  onPressed: () => appState.pan(sliderPanValue + 3600),
                  child: Icon(Icons.skip_previous)),
              OutlinedButton(
                  onPressed: () => appState.pan(0), child: Icon(Icons.repeat)),
              OutlinedButton(
                  onPressed: () => appState.pan(sliderPanValue - 3600),
                  child: Icon(Icons.skip_next)),
            ],
          ),
          Text('tilt'),
          BigCard(sliderValue: sliderTiltValue),
          SliderTilt(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                  onPressed: () => appState.tilt(sliderTiltValue - 3600),
                  child: Icon(Icons.skip_previous)),
              OutlinedButton(
                  onPressed: () => appState.tilt(0), child: Icon(Icons.repeat)),
              OutlinedButton(
                  onPressed: () => appState.tilt(sliderTiltValue + 3600),
                  child: Icon(Icons.skip_next)),
            ],
          ),
        ],
      ),
    );
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
      value: currentSliderValue,
      min: -522000,
      max: 522000,
      divisions: 522000 ~/ 3600,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {
        appState.pan(value);
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text(message)));
      },
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
      min: -324000,
      max: 360000,
      divisions: 360000 ~/ 3600,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {
        appState.tilt(value);
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text(message)));
      },
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
    String urlApi = appState.urlApi;
    return Center(
      child: Column(
        children: [
          Text('Url API'),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              appState.setUrl(value);
            },
            initialValue: urlApi,
          ),
        ],
      ),
    );
  }
}
