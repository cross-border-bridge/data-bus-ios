// Copyright © 2017 DWANGO Co., Ltd.

//import CBBWKWebViewDataBus
import UIKit
import WebKit

class ViewController: UIViewController {
    var webView: WKWebView
    //var dataBus: CBBDataBus
    var handlerIds: NSMutableArray

    override func viewDidLoad() {
        super.viewDidLoad()
        handlerIds = NSMutableArray()
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        let label = UILabel(frame: CGRect(x: 4, y: 30, width: width - 8, height: 30))
        label.text = "CBBWKWebViewDataBus (native)"
        self.view.addSubview(label)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

