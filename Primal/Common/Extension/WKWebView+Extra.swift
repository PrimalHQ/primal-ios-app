//
//  WKWebView+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.5.24..
//

import WebKit

extension WKWebView {
    func calculateSize(callback: @escaping (CGFloat) -> Void) {
        evaluateJavaScript("document.readyState", completionHandler: { result, error in
            if result == nil || error != nil {
                return
            }
            self.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { result, error in
                if let height = result as? CGFloat {
                    callback(height)
                }
            })
        })
    }
}
