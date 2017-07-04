// Copyright © 2017 DWANGO Co., Ltd.

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var webView: WKWebView = WKWebView()
    var dataBus: CBBDataBus?
    var handlerIds: NSMutableArray?

    override func viewDidLoad() {
        super.viewDidLoad()
        handlerIds = NSMutableArray()
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        let label = UILabel(frame: CGRect(x: 4, y: 30, width: width - 8, height: 30))
        label.text = "CBBWKWebViewDataBus (native)"
        self.view.addSubview(label)

        // ボタンを準備
        self.addButton(frame: CGRect(x: 4, y:70, width: 200, height: 30), title: "Add handler", action:#selector(self.addHandler(sender:)))
        self.addButton(frame: CGRect(x: 4, y:110, width: 200, height: 30), title: "Send message", action:#selector(self.sendMessage(sender:)))
        self.addButton(frame: CGRect(x: 4, y:150, width: 200, height: 30), title: "Remove a handler", action:#selector(self.removeHandler(sender:)))
        self.addButton(frame: CGRect(x: 4, y:190, width: 200, height: 30), title: "destroy", action:#selector(self.destroy(sender:)))

        // WKWebViewを準備（※この時点ではまだコンテンツを読み込まない）
        self.webView.frame = CGRect(x: 4, y: height / 2 + 4, width: width - 8, height: height / 2 - 8)
        self.webView.layer.borderWidth = 2.0
        self.webView.layer.borderColor = UIColor.blue.cgColor
        self.webView.layer.cornerRadius = 10.0
        self.webView.navigationDelegate = self
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView.uiDelegate = self

        // WKWebView　は App bundle のファイルを読めない為, bundleの内容を tmp
        // へコピーしてそこから読み込む
        self.copy(target: "index.html")
        self.copy(target: "script.js")
        self.view.addSubview(self.webView)

        // CBBDataBusを準備
        self.dataBus = CBBWKWebViewDataBus(wkWebView: self.webView)
    
        // WKWebView にコンテンツを読み込む（CBBDataBusがインジェクトされる）
        let urlString = NSString.localizedStringWithFormat("file://%@/index.html", self.tmpFolder()) as String
        let url = URL(fileURLWithPath: urlString)
        self.webView.loadFileURL(url, allowingReadAccessTo: url)
    }

    func addButton(frame: CGRect, title: String, action: Selector) {
        let b = UIButton(type: UIButtonType.roundedRect)
        b.frame = frame
        b.layer.cornerRadius = 2.0
        b.layer.borderColor = UIColor.blue.cgColor
        b.layer.borderWidth = 1.0
        b.setTitle(title, for: UIControlState.normal)
        b.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        self.view.addSubview(b)
    }

    func addHandler(sender: Any) {
        let h: CBBDataBusHandler = { (message: [Any]) in
            // JavaScript側メッセージ受信時の処理
            let alert = UIAlertController(title: "Alert from Native", message: NSString.localizedStringWithFormat("Received message\n%@", message) as String, preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        self.dataBus?.addHandler(h)
    }

    func sendMessage(sender: Any) {
        self.dataBus?.sendData(["This", "is", "test", 1234])
    }

    func removeHandler(sender: Any) {
        self.dataBus?.removeAllHandlers()
    }

    func destroy(sender: Any) {
        self.dataBus?.destroy()
    }

    func tmpFolder() -> String {
        return NSTemporaryDirectory().appending("www")
    }

    // AppBundleの内容はWKWebViewから参照できないのでテンポラリディレクトリにコピーして用いる
    func copy(target: String) {
        let sourceFile = Bundle.main.path(forResource:target, ofType:nil)
        let destFile = self.tmpFolder().appending("/").appending(target)
        let fm = FileManager.default
        if !fm.fileExists(atPath: sourceFile!) {
            return
        }
        if fm.fileExists(atPath: destFile) {
            try! fm.removeItem(atPath: destFile)
        }
        try! fm.createDirectory(atPath: self.tmpFolder(), withIntermediateDirectories: true, attributes: nil)
        try! fm.copyItem(atPath: sourceFile!, toPath: destFile)
    }

    // JavaScript側でalertを発行した時の処理
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Alert from JS", message: NSString.localizedStringWithFormat("Received message\n%@", message) as String, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            completionHandler()
        })
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

