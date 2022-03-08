library load_items;

import 'package:flutter/material.dart';

/// A typedef function definition used to load new items
typedef ItemsLoader<T> = Future<List<T>> Function(List<T> currentItems);

/// A typedef function definition used to built a `Widget` per item `T`
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int i);

/// A typedef function definition for building widgets
typedef WidgetBuilder = Widget Function();

/// An enum to specify to use a `ListView` or `GridView`
enum LoadItemsType { list, grid }

/// Builds either a `ListView` or `GridView` based on the given `LoadItemsType`,
/// wrapped in a `RefreshIndicator`, a `Scrollbar` and a `Stack`.
///
/// `LoadItems` will call a given `ItemsLoader` when you scroll to the bottom of
/// the screen, and use a given `ItemBuilder` to build a `Widget` per item.
///
/// Various builders and configurations can be passed to the constructor as well.
class LoadItems<T> extends StatefulWidget {
  final LoadItemsType type;
  final ItemsLoader<T> itemsLoader;
  final ItemBuilder<T> itemBuilder;
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
  final Listenable? scrollToTopListenable;
  final int? scrollToTopDuration;
  final Curve? scrollToTopCurve;

  /// Set to true if you want to fade out the content if more.
  final bool fadeOutIfMore;
  final double fadeOutRatio;
  final Curve fadeOutCurve;
  final Duration fadeOutDuration;

  /// LoadItems constructor. Pass a `type`, `itemsLoader` and a `itemsBuilder` in the constructor.
  const LoadItems({
    Key? key,
    required this.type,
    required this.itemsLoader,
    required this.itemBuilder,
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
    this.scrollToTopListenable,
    this.scrollToTopDuration,
    this.scrollToTopCurve,
    this.fadeOutIfMore = false,
    this.fadeOutRatio = 0.85,
    this.fadeOutCurve = Curves.easeOut,
    this.fadeOutDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _LoadItemsState<T> createState() => _LoadItemsState<T>();
}

/// LoadItems State object
class _LoadItemsState<T> extends State<LoadItems<T>> {
  late final ItemsLoader<T> itemsLoader;
  late final ItemBuilder<T> itemBuilder;
  late final WidgetBuilder emptyBuilder;
  late final WidgetBuilder emptyLoadingBuilder;
  late final WidgetBuilder bottomLoadingBuilder;
  late final int itemWidth;
  late final int? gridCrossAxisCount;
  late final double gridChildAspectRatio;
  late final ScrollPhysics physics;
  late final EdgeInsets padding;
  late final double loadScrollFactor;
  late final Listenable? refreshListenable;
  late final Listenable? scrollToTopListenable;
  late final int scrollToTopDuration;
  late final Curve scrollToTopCurve;
  late final bool fadeOutIfMore;
  late final double fadeOutRatio;
  late final Curve fadeOutCurve;
  late final Duration fadeOutDuration;

  final List<T> _items = <T>[];
  final _scrollController = ScrollController();
  bool _loading = false;
  bool _overlayIsVisible = false;

  @override
  void initState() {
    super.initState();

    itemsLoader = widget.itemsLoader;
    itemBuilder = widget.itemBuilder;

    emptyBuilder = widget.emptyBuilder ?? () => const SizedBox.shrink();

    emptyLoadingBuilder = widget.emptyLoadingBuilder ??
        () => const Center(child: CircularProgressIndicator.adaptive());

    bottomLoadingBuilder = widget.bottomLoadingBuilder ??
        () => const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CircularProgressIndicator.adaptive(),
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
    scrollToTopListenable = widget.scrollToTopListenable;
    scrollToTopDuration = widget.scrollToTopDuration ?? 350;
    scrollToTopCurve = widget.scrollToTopCurve ?? Curves.bounceInOut;
    fadeOutIfMore = widget.fadeOutIfMore;
    fadeOutRatio = widget.fadeOutRatio;
    fadeOutCurve = widget.fadeOutCurve;
    fadeOutDuration = widget.fadeOutDuration;

    refreshListenable?.addListener(() {
      _refresh();
    });

    _scrollController.addListener(() {
      setState(() {
        _overlayIsVisible = _scrollController.position.extentAfter > 0;
      });
      if (_scrollController.offset >
          _scrollController.position.maxScrollExtent * loadScrollFactor) {
        _loadItems();
      }
    });

    scrollToTopListenable?.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0,
            curve: scrollToTopCurve,
            duration: Duration(milliseconds: scrollToTopDuration));
      }
    });

    _loadItems();
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
            child:
                widget.type == LoadItemsType.list ? _buildList() : _buildGrid(),
          ),
        ),
        if (fadeOutIfMore)
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _overlayIsVisible ? 1 : 0,
              duration: fadeOutDuration,
              curve: fadeOutCurve,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Color(0x00FFFFFF),
                      Color(0xAAFFFFFF),
                    ],
                    stops: [
                      fadeOutRatio,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_loading) bottomLoadingBuilder(),
      ],
    );
  }

  /// builds a `ListView`
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

  /// builds a `GridView`
  GridView _buildGrid() {
    final crossAxisCount = gridCrossAxisCount != null
        ? gridCrossAxisCount!
        : MediaQuery.of(context).size.width ~/ itemWidth;
    return GridView.builder(
      physics: physics,
      controller: _scrollController,
      padding: padding,
      itemCount: _items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: gridChildAspectRatio,
      ),
      itemBuilder: (context, index) =>
          itemBuilder(context, _items[index], index),
    );
  }

  /// Clears all items and calls the `itemsLoader`.
  Future _refresh() async {
    if (_loading || !mounted) {
      return;
    }
    _items.clear();

    _loadItems();
  }

  /// Calls the `itemsLoader`, and adds the new items. Also sets the `loading` state.
  Future _loadItems() async {
    if (_loading || !mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _overlayIsVisible = false;
    });

    final List<T> newItems = await itemsLoader(_items);

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
      if (newItems.isNotEmpty) {
        _items.addAll(newItems);
        _overlayIsVisible = true;
      }
    });
  }
}
