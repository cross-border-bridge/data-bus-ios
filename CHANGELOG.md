# Change log

## Version 2.1.0
- マルチスレッドに対応
- `DataBus#handler` を DataBus実装から参照する方式を廃止 (破壊的変更)
  - DataBus実装はデータ到達時に `DataBus#onReceiveData` を呼ぶものとする
  - この変更は, 独自のDataBus実装開発者に影響する

## Version 2.0.0
初版
