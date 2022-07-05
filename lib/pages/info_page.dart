import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: PageView(
          controller: controller,
          children: <Widget>[
            PatricularInfo('InnoStudy App', 'assets/texts/inno_study_app.txt'),
            PatricularInfo('Structure', 'assets/texts/structure.txt'),
            PatricularInfo(
                'Permissions system', 'assets/texts/permission_system.txt'),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Text(
            'Swipe right to see more ',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class PatricularInfo extends StatelessWidget {
  final String title;
  final String path;
  late Future<String> data = rootBundle.loadString(path);

  PatricularInfo(this.title, this.path, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return ListView(
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Builder(
              builder: (BuildContext context) => snapshot.hasData
                  ? Text(
                      snapshot.data!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15,
                      ),
                    )
                  : Text(
                      "Something went wrong...",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
