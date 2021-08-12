# load_more

Load new items when scrolling to the bottom of a `ListView` or `GridView`.

## Features

* load new items when scrolling to the bottom of a `ListView` or `GridView`
* paging support by passing the previous items to `ItemsLoader`
* add custom widget builders for items, loaders and empty widgets
* configurable `ListView` and `GridView`
* configure when to load more via `loadScrollFactor`
* pull-to-refresh to reload data
* force refresh using a `Listenable`

## Example

```dart
LoadMore<Item>(
	loadMoreType: LoadMoreType.grid,
	itemBuilder: (context, Item item, int index) {
		return ListTile(title: item.title);
	},
	itemsLoader: (List<Item> currentItems) {
		return await Api.fetch({skip: currentItems.length});
	},
	gridCrossAxisCount: 3,
)
```

See [example](./example) for full list and grid example.

## Author



By [apptakk.com](http://apptakk.com/)