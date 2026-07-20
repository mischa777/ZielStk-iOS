//Created on 11/9/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit
import WebKit

class SelectionWebVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    @IBOutlet weak var webKitView: WKWebView!
    
    var urlString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        showPreloader()
        setUrlToWebkitView()
    }
    
    private func setUrlToWebkitView() {
        webKitView.navigationDelegate = self
        if let url = URL(string: urlString) {
            let urlRequest: URLRequest = URLRequest(url: url)
            webKitView.load(urlRequest)
        } else {
            showWebError()
        }
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        if webKitView.canGoBack {
            webKitView.goBack()
        } else {
            if let nc = navigationController {
                nc.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func showWebError() {
        hidePreloader()
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("WebViewError", comment: "")
        showAlert(title: title, message: message)
    }
    
}

extension SelectionWebVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showWebError()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hidePreloader()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showWebError()
    }
}
