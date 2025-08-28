//
//  FeedElementWebkitLinkPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.1.25..
//

import UIKit
import WebKit

class FeedElementWebkitLinkPreviewCell: FeedElementBaseCell, RegularFeedElementCell, WebPreviewCell {
    static var cellID: String { "FeedElementWebkitLinkPreviewCell" }
    
    let linkPresentation = LargeLinkPreview()
    
    let webView: WKWebView = {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let view = WKWebView(frame: .zero, configuration: webViewConfiguration)
        view.scrollView.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    var tapAction = { }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(webView)
        webView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        webView.alpha = 0
        
        contentView.addSubview(linkPresentation)
        linkPresentation
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        linkPresentation.heightAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        linkPresentation.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.tapAction()
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateWebPreview(_ metadata: LinkMetadata) {
        linkPresentation.data = metadata
        linkPresentation.alpha = 1
        
        webView.alpha = 0.01
        
        tapAction = { [weak self] in
            self?.turnToWebkitPreview(metadata)
        }
    }
    
    override func update(_ content: ParsedContent) {
        linkPresentation.updateTheme()
    }
    
    func turnToWebkitPreview(_ metadata: LinkMetadata) {
        webView.loadEmbeddedURL(metadata.url, size: linkPresentation.frame.size)
        
        UIView.animate(withDuration: 0.3, delay: 1) {
            self.linkPresentation.alpha = 0
            self.webView.alpha = 1
        }
    }
}

public extension URL {
    var isYoutubeVideoURL: Bool {
        isYoutubeURL && youtubeID != nil
    }
    
    var isTidalMusicURL: Bool {
        isTidalURL && tidalEmbedURL != nil
    }
    
    var isSpotifyMusicURL: Bool {
        isSpotifyURL && spotifyEmbedURL != nil
    }
}

private extension URL {
    var youtubeID: String? {
        if path().contains("/shorts/") || path.contains("/live/") {
            return lastPathComponent
        }
        
        if host?.contains("youtube.com") == true {
            let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems
            return queryItems?.first(where: { $0.name == "v" })?.value
        }
        
        if host == "youtu.be" {
            return pathComponents.dropFirst().first // Path components drop "/" at the start
        }
        return nil
    }
    
    var tidalEmbedURL: URL? {
        var embedString = ""
        
        if embedString.contains("listen.tidal.com") {
            embedString = absoluteString.replacingOccurrences(of: "listen.tidal.com", with: "embed.tidal.com")
            embedString = embedString.replacingOccurrences(of: "/playlist/", with: "/playlists/")
            embedString = embedString.replacingOccurrences(of: "/track/", with: "/tracks/")
        } else {
            if let trackIDIndex = pathComponents.firstIndex(of: "track"), let trackID = pathComponents[safe: trackIDIndex + 1] {
                embedString = "https://embed.tidal.com/tracks/\(trackID)"
            } else if let playlistIDIndex = pathComponents.firstIndex(of: "playlist"), let playlistID = pathComponents[safe: playlistIDIndex + 1] {
                embedString = "https://embed.tidal.com/playlists/\(playlistID)"
            }
        }
        
        if embedString.isEmpty { return nil }
        
        return URL(string: embedString)
    }
    
    var spotifyEmbedURL: URL? {
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        guard let path = urlComponents?.path else {
            print("Unable to parse Spotify URL path")
            return nil
        }

        // Split the path to extract type and ID
        let pathComponents = path.split(separator: "/")
        guard let type = pathComponents[safe: 0], let id = pathComponents[safe: 1] else { return nil }
        
        if type == "genre" { return nil }

        // Construct the embed URL
        let embedURL = "https://open.spotify.com/embed/\(type)/\(id)?autoplay=1"
        return URL(string: embedURL)
    }
    
    var rumbleEmbedCode: String? {
        guard isRumbleURL else { return nil }
        
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        
        guard let path = urlComponents?.path else { return nil }
        
        guard let lastComponent = path.split(separator: "/").last else { return nil }
        
        let videoID = lastComponent.split(separator: "-").first
        
        guard let videoID = videoID else { return nil }
        
        let embedCode = """
        <iframe src="\(absoluteString)" frameborder="0" width="100%" height="100%" allowfullscreen></iframe>
        
        <script>!function(r,u,m,b,l,e){r._Rumble=b,r[b]||(r[b]=function(){(r[b]._=r[b]._||[]).push(arguments);if(r[b]._.length==1){l=u.createElement(m),e=u.getElementsByTagName(m)[0],l.async=1,l.src="https://rumble.com/embedJS/u4"+(arguments[1].video?'.'+arguments[1].video:'')+"/?url="+encodeURIComponent(location.href)+"&args="+encodeURIComponent(JSON.stringify([].slice.apply(arguments))),e.parentNode.insertBefore(l,e)}})}(window, document, "script", "Rumble");</script>

        <div id="rumble_v66s2gs"></div>
        <script>
        Rumble("play", {"video":"v66s2gs","div":"rumble_v66s2gs"});</script>
        
        """
        
        return embedCode
    }
}

extension WKWebView {
    func loadEmbeddedURL(_ url: URL, size: CGSize) {
        var embedCode: String?
        
        if url.isTidalURL, let embedURL = url.tidalEmbedURL {
            load(URLRequest(url: embedURL))
            //            embedCode = """
            //            <iframe src="\(embedURL)" width="\(size.width - 10)" height="\(size.height)" allow="encrypted-media" sandbox="allow-same-origin allow-scripts allow-forms allow-popups" title="TIDAL Embed Player" />
            //            """
            return
        }
        
        if url.isSpotifyURL, let embedURL = url.spotifyEmbedURL {
            load(URLRequest(url: embedURL))
            return
            //            embedCode = """
            //            <div class="embed-container">
            //            <iframe style="border-radius:12px" src="\(embedURL)" width="100%" height="\(size.height)" frameBorder="0" allowfullscreen="" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy">
            //            </iframe>
            //            </div>
            //            """
        }
        
        if url.isRumbleURL, let embedURL = URL(string: "https://rumble.com/embed/v66s2gs/?pub=4&autoplay=1") {
            load(URLRequest(url: embedURL))
            return
            //            embedCode = url.rumbleEmbedCode
        }
        if url.isYoutubeURL, let id = url.youtubeID, let embedURL = URL(string: "https://www.youtube.com/embed/\(id)?autoplay=1&rel=0&showinfo=0&modestbranding=1") {
            embedCode = """
            <iframe src="\(embedURL)" width="\(size.width)" height="\(size.height - 10)" sandbox="allow-same-origin allow-scripts allow-forms allow-popups" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
            """
        }
        
        guard let embedCode else { return }
        
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
            body { margin: 0; width:100%%; height:100%%;  background-color:#000000; }
            html { width:100%%; height:100%%; background-color:#000000; }

            .embed-container iframe,
            .embed-container object,
            .embed-container embed {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%% !important;
                height: 100%% !important;
            }
            </style>
        </head>
        <body>
            \(embedCode)
        </body>
        </html>
        """

        loadHTMLString(embedHTML, baseURL: URL(string: "https://primal.net/embed/"))
    }
}
