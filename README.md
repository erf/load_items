# load_items

Load new items into either a list or a grid as you scroll down.

![screencast](https://user-images.githubusercontent.com/1562523/129325662-7aa946ab-32a4-4237-8442-cc980fe480e2.mp4)

## Features

* load new items when scrolling to the bottom of a `ListView` or `GridView`
* pagination support by passing the previous items to `ItemsLoader`
* add custom widget builders for items, loaders and empty widgets
* configurable `ListView` and `GridView`
* configure when to load more via `loadScrollFactor`
* pull-to-refresh to reload data
* force refresh using a `Listenable`

## Example

```dart
LoadItems<Item>(
	type: LoadItemsType.grid,
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

