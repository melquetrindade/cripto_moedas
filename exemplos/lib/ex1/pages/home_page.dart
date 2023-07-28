import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/users.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Users pessoas;

  void initState() {
    super.initState();
    pessoas = Users();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Pessoas'),
        ),
      ),
      body: FutureBuilder(
        future: Users.lista(),
        builder: (context, snap) {
          switch (snap.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snap.hasData && !snap.hasError) {
                return ListView.separated(
                    itemCount: 40,
                    itemBuilder: (BuildContext context, int index) {
                      final User user = snap.data![index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.picture),
                        ),
                        title: Text(user.name),
                      );
                    },
                    separatorBuilder: (__, _) => const Divider(),
                );
              } else {
                return Text(snap.error.toString());
              }
          }
          
          //print('len: ${snap.data!.length}');
          //if (snap.connectionState != ConnectionState.done) {
          //  return const Center(child: CircularProgressIndicator());
          //}
          //return ListView.separated(
          //  itemCount: 40,
          //  itemBuilder: (BuildContext context, int index) {
          //    final User user = snap.data![index];
          //    return ListTile(
          //      leading: CircleAvatar(
          //        backgroundImage: NetworkImage(user.picture),
          //      ),
          //      title: Text(user.name),
          //    );
          //  },
          //  separatorBuilder: (__, _) => const Divider(),
          //);
        },
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.edit),
      ),
    );
  }
}
