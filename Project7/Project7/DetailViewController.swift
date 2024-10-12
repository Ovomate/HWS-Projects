//
//  DetailViewController.swift
//  Project7
//
//  Created by Stefan Storm on 2024/09/09.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else {return}
        
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width", initial-scale=1">
        <title>My Website</title>
        <style> body {font-size: 150% } </style>
        </head>
        <body>
        <h1>Hacking with swift: Project 7</h1> 
        <hr>
        <img src="https://petitions.obamawhitehouse.archives.gov/profiles/petitions/themes/petitions_responsive/images/wtp_header_large.jpg" alt="petitions.obamawhitehouse.archives.gov" style="width:360px;height:128px;">
        <hr>
        
        \(detailItem.body)
        
        <hr>
        
        </body>
        <head>
        """
        
        webView.loadHTMLString(html, baseURL: nil)

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
