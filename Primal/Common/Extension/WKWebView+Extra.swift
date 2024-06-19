//
//  WKWebView+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.5.24..
//

import WebKit

struct WebViewCache {
    private static var cached = WKWebView()
    
    static func setup() {
        cached.loadHTMLString("", baseURL: Bundle.main.bundleURL)
        cached.injectScript(fontFileName: "Nacelle-Regular", type: .otf, fontFamilyName: "Nacelle")
    }
    
    static func getWebView() -> WKWebView {
        let old = cached
        cached = WKWebView()
        setup()
        return old
    }
}

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

extension WKWebView: Themeable {
    func updateTheme() {
        evaluateJavaScript("document.body.className = '\(Theme.current.shortTitle) \(FontSizeSelection.current.name)'")
    }
}

extension WKWebView {
    enum FontType: String {
        case otf
        case ttf
        var format: String {
            switch self {
            case .otf:
                return "opentype"
            case .ttf:
                return "truetype"
            }
        }
    }
    
    func injectScript(fontFileName: String, type: FontType, fontFamilyName: String) {
        let fontFileUrl = bundleFileURL(name: fontFileName, type: type.rawValue)
        guard let fontData = try? Data(contentsOf: fontFileUrl) else {
            return
        }
        let css = """
                @font-face {
                    font-family: '\(fontFamilyName)';
                    src: url(data:font/octet-stream;base64,\(fontData.base64EncodedString()))
                    format('\(type.format)');
                }
                """
        let cssStyle = """
               javascript:(function() {
               var parent = document.getElementsByTagName('head').item(0);
               var style = document.createElement('style');
               style.innerHTML = window.atob('\(encodeStringTo64(fromString: css))');
               parent.appendChild(style)})()
           """
        let cssScript = WKUserScript(source: cssStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(cssScript)
    }
    
    private func bundleFileURL(name: String, type: String) -> URL {
        let bundleURL = Bundle.main.bundleURL
        return bundleURL.appendingPathComponent(name).appendingPathExtension(type)
    }
    
    private func encodeStringTo64(fromString: String) -> String {
        let plainData = fromString.data(using: .utf8)
        return plainData?.base64EncodedString(options: []) ?? ""
    }
}
