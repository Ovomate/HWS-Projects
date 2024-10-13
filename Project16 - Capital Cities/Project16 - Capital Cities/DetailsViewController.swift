//
//  DetailsViewController.swift
//  Project16 - Capital Cities
//
//  Created by Stefan Storm on 2024/10/01.
//

import UIKit
import WebKit

class DetailsViewController: UIViewController, WKNavigationDelegate {
    
    var capital : Capital?
    var webView : WKWebView = {
       let wv = WKWebView()
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.allowsLinkPreview = true
        wv.allowsBackForwardNavigationGestures = true
        return wv
        
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: #selector(webView.reload))
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: webView, action: #selector(webView.goBack))
        let forward = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: webView, action: #selector(webView.goForward))
        toolbarItems = [refresh, back, forward]
        navigationController?.isToolbarHidden = false
        
        
        setupDetailsViewController()
        
        if let capital = capital?.title{
            if let url = URL(string: "https://en.wikipedia.org/wiki/\(capital.replacingOccurrences(of: " ", with: "_"))"){
                webView.load(URLRequest(url: url))
            }
        }

    }

    
    func setupDetailsViewController(){
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            
            webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)

        ])
        
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let capital = capital?.title else {return}
        if let host = navigationAction.request.url?.host{
            
            if host == "en.m.wikipedia.org" || host == "en.wikipedia.org" {
                decisionHandler(.allow)
                return
            }
        }
        decisionHandler(.cancel)
    }
    



}
