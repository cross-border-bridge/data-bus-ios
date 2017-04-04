# Heat-run app

`CBBWKWebViewDataBus` のか負荷テストを実施するアプリです。

## How to build
```
pod install
open Heatrun.xcworkspace
```

## How to use
- `start sending 10000 request from Native` button (Native)
  - 100スレッドから合計10,000回のリクエストをNativeからWebViewへ投げ, 10,000回のレスポンスを受信します
- `start sending 10000 request from JS` button (WebView)
  - 10,000回のリクエストをWebViewからNativeへ投げ, 10,000回のレスポンスを受信します

