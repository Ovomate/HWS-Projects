//
//  ViewController.swift
//  Project4
//
//  Created by Stefan Storm on 2024/08/29.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var selectedWebsite: String?
    var safeWebsites: [String]?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsLinkPreview = true
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: #selector(webView.reload))
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: webView, action: #selector(webView.goBack))
        let forward = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: webView, action: #selector(webView.goForward))
        toolbarItems = [progressButton, spacer, refresh, back, forward]
        navigationController?.isToolbarHidden = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        if let website = selectedWebsite{
            let url = URL(string: "https://" + website)!
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }


    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    
    //MARK: Code to check which websites are allowed.

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url

        guard let host = url?.host else { decisionHandler(.cancel); return}
        guard let safeWebsites = safeWebsites else { decisionHandler(.cancel); return}
        
            for website in safeWebsites {
                
                if host.contains(website){
                    print("Success")
                    decisionHandler(.allow)
                    return
                }
                
            }
  
        
        
        let ac = UIAlertController(title: "Site not allowed!", message: "Oops!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(ac, animated: true)
        decisionHandler(.cancel )
        
    }
}




