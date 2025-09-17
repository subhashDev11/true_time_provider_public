import 'package:example/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:true_time_provider/true_time_provider.dart';

Future<void> main() async {
  runApp(const ExampleWidget());
}

class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool initialized = false;

  final TrueTimeProvider trueTimeProvider = TrueTimeProvider.instance;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    await trueTimeProvider.init(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    initialized = true;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('True Time Provider'),
        elevation: 10,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {

          });
        },
        child: Icon(Icons.refresh),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            spacing: 20,
            children: [
              if(initialized)
              FutureBuilder(
                future: trueTimeProvider.now(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.fromSize(
                      size: Size.fromRadius(20),
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data == null) {
                    return Text("Failed to find the time");
                  } else {
                    return Column(
                      spacing: 15,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${snapshot.data?.source.name} Time - ",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(fontSize: 18),
                              ),
                              TextSpan(
                                text: snapshot.data?.dateTime.toString() ?? "",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Local Device Time - ",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(fontSize: 18),
                              ),
                              TextSpan(
                                text: "${DateTime.now()}",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontSize: 18, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
