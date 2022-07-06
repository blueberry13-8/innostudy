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
            ParticularInfo('InnoStudy App', 'assets/texts/inno_study_app.txt'),
            ParticularInfo('Structure', 'assets/texts/structure.txt'),
            ParticularInfo(
                'Permissions system', 'assets/texts/permission_system.txt'),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 60,
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: () async {
            if (controller.page == 2) {
              await controller.previousPage(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.linear);
              await controller.previousPage(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.linear);
            } else {
              await controller.nextPage(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOutSine);
            }
          },
          child: Text(
            'Next',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ParticularInfo extends StatelessWidget {
  final String title;
  final String path;
  late final Future<String> data = rootBundle.loadString(path);

  ParticularInfo(this.title, this.path, {Key? key}) : super(key: key);

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
            Container(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 10, right: 10),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).hoverColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Builder(
                builder: (BuildContext context) => snapshot.hasData
                    ? Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 17,
                        ),
                      )
                    : Text(
                        "Something went wrong...",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
