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

class ScrollToTopNotifier extends ChangeNotifier {
  void scrollToTop() {
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scrollToTop = ScrollToTopNotifier();

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
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.arrow_upward),
          onPressed: () {
            scrollToTop.scrollToTop();
          },
        ),
        body: TabBarView(
          children: [
            LoadItems<Item>(
              type: LoadItemsType.list,
              itemBuilder: itemBuilder,
              itemsLoader: itemsLoader,
              scrollToTopListenable: scrollToTop,
              fadeOutIfMore: true,
            ),
            LoadItems<Item>(
              type: LoadItemsType.grid,
              itemBuilder: itemBuilder,
              itemsLoader: itemsLoader,
              gridCrossAxisCount: 3,
              scrollToTopListenable: scrollToTop,
              fadeOutIfMore: true,
              fadeOutRatio: 0.7,
              fadeOutCurve: Curves.easeIn,
              fadeOutDuration: const Duration(milliseconds: 1000),
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

  Future<List<Item>> itemsLoader(List<Item> currentItems) async {
    await Future.delayed(const Duration(milliseconds: 750));
    if (currentItems.length < 96) {
      return List.generate(16, (i) => Item(currentItems.length + i));
    }
    return List.empty();
  }
}
