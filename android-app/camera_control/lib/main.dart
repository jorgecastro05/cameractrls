import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


Future<Map<String, dynamic>> fetchConfig(String urlApi) async{
  final response = await http
      .get(Uri.parse('$urlApi/props'));
      return jsonDecode(response.body) as Map<String, dynamic>;
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
  String urlApi = 'http://localhost:5000';
  late Future<Map<String, dynamic>> configuration;

  void setConfig(Future<Map<String, dynamic>> config){
      configuration = config;
   
  }

  void pan(double value) async {
    panSliderValue = value;
    String operation = '/pan?value=$panSliderValue';
    print(Uri.parse(urlApi + operation));
    final response = await http.get(Uri.parse(urlApi + operation));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.\
      notifyListeners();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load set value');
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  String urlApi = 'http://localhost:5000';
  late Future<Map<String, dynamic>> config;

  @override
  void initState() {
    super.initState();
    config = fetchConfig(urlApi);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.setConfig(config);

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
    double sliderValue = appState.panSliderValue;


    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          BigCard(sliderValue: sliderValue),
          SliderPan(),
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
    return Slider(
      value: currentSliderValue,
      min: -20,
      max: 20,
      divisions: 20,
      label: currentSliderValue.round().toString(),
      onChanged: (double value) {
        appState.pan(value);
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
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          sliderValue.toString(),
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

    return ListView(
      children: [
        FutureBuilder(
          future: appState.configuration, 
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Text(snapshot.data!.entries.toString());
            }else if (snapshot.hasError){
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          }
          ),
      ]
    );
  }
}
