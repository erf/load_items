library load_more;

import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int i);

typedef ItemsLoader<T> = Future<List<T>> Function(List<T> currentItems);

typedef WidgetBuilder = Widget Function();

enum LoadMoreType { list, grid }

class LoadMore<T> extends StatefulWidget {
  final LoadMoreType loadMoreType;
  final ItemBuilder<T> itemBuilder;
  final ItemsLoader<T> itemsLoader;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? emptyLoadingBuilder;
  final WidgetBuilder? bottomLoadingBuilder;
  final int? itemWidth;
  final int? gridCrossAxisCount;
  final double? gridChildAspectRatio;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final double? loadScrollFactor;
  final Listenable? refreshListenable;

  const LoadMore({
    Key? key,
    required this.loadMoreType,
    required this.itemBuilder,
    required this.itemsLoader,
    this.emptyBuilder,
    this.emptyLoadingBuilder,
    this.bottomLoadingBuilder,
    this.itemWidth,
    this.gridCrossAxisCount,
    this.gridChildAspectRatio,
    this.physics,
    this.padding,
    this.loadScrollFactor,
    this.refreshListenable,
  }) : super(key: key);

  @override
  _LoadMoreState<T> createState() => _LoadMoreState<T>();
}

class _LoadMoreState<T> extends State<LoadMore<T>> {
  late final ItemBuilder<T> itemBuilder;
  late final ItemsLoader<T> itemsLoader;
  late final WidgetBuilder emptyBuilder;
  late final WidgetBuilder emptyLoadingBuilder;
  late final WidgetBuilder bottomLoadingBuilder;
  late final int? itemWidth;
  late final int? gridCrossAxisCount;
  late final double gridChildAspectRatio;
  late final ScrollPhysics physics;
  late final EdgeInsets padding;
  late final double loadScrollFactor;
  late final Listenable? refreshListenable;

  final List<T> _items = <T>[];
  final _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    itemBuilder = widget.itemBuilder;
    itemsLoader = widget.itemsLoader;

    emptyBuilder = widget.emptyBuilder ?? () => const SizedBox.shrink();

    emptyLoadingBuilder = widget.emptyLoadingBuilder ??
        () => const Center(child: CircularProgressIndicator());

    bottomLoadingBuilder = widget.bottomLoadingBuilder ??
        () => const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CircularProgressIndicator(),
                ),
              ),
            );

    itemWidth = widget.itemWidth ?? 120;
    gridCrossAxisCount = widget.gridCrossAxisCount;
    gridChildAspectRatio = widget.gridChildAspectRatio ?? 0.85;
    physics = widget.physics ?? const ClampingScrollPhysics();
    padding = widget.padding ?? EdgeInsets.zero;
    loadScrollFactor = widget.loadScrollFactor ?? 0.85;
    refreshListenable = widget.refreshListenable;

    refreshListenable?.addListener(() {
      _refresh();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset >
          _scrollController.position.maxScrollExtent * loadScrollFactor) {
        _fetch();
      }
    });

    _fetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      if (_loading) {
        return emptyLoadingBuilder();
      }
      return emptyBuilder();
    }
    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: _refresh,
          child: Scrollbar(
            controller: _scrollController,
            child: widget.loadMoreType == LoadMoreType.list
                ? _buildList()
                : _buildGrid(),
          ),
        ),
        if (_loading) bottomLoadingBuilder()
      ],
    );
  }

  ListView _buildList() {
    return ListView.builder(
      physics: physics,
      controller: _scrollController,
      itemCount: _items.length,
      padding: padding,
      itemBuilder: (context, index) =>
          itemBuilder(context, _items[index], index),
    );
  }

  GridView _buildGrid() {
    return GridView.builder(
      physics: physics,
      controller: _scrollController,
      padding: padding,
      itemCount: _items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCrossAxisCount != null
            ? gridCrossAxisCount!
            : MediaQuery.of(context).size.width ~/ itemWidth!,
        childAspectRatio: gridChildAspectRatio,
      ),
      itemBuilder: (context, index) =>
          itemBuilder(context, _items[index], index),
    );
  }

  Future _refresh() async {
    if (_loading || !mounted) {
      return;
    }
    _items.clear();

    _fetch();
  }

  Future _fetch() async {
    if (_loading || !mounted) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final List<T> newItems = await itemsLoader(_items);

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
      _items.addAll(newItems);
    });
  }
}
