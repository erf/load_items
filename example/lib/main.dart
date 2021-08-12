import 'package:flutter/material.dart';
import 'package:load_items/load_items.dart';

void main() {
  runApp(const MyApp());
}

class Item {
  int index;
  Item(this.index);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'load_items',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('load_items'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list)),
              Tab(icon: Icon(Icons.grid_3x3)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoadItems<Item>(
              type: LoadItemsType.list,
              itemBuilder: itemBuilder,
              itemsLoader: itemsLoader,
            ),
            LoadItems<Item>(
              type: LoadItemsType.grid,
              itemBuilder: itemBuilder,
              itemsLoader: itemsLoader,
              gridCrossAxisCount: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext ctx, item, int index) {
    return ListTile(
      title: SizedBox(
        width: 100,
        height: 100,
        child: ColoredBox(
          color: Colors.redAccent,
          child: Center(
            child: Text('Item ${item.index}'),
          ),
        ),
      ),
    );
  }

  Future<List<Item>> itemsLoader(List currentItems) async {
    await Future.delayed(const Duration(milliseconds: 750));
    return List.generate(16, (i) => Item(currentItems.length + i));
  }
}
