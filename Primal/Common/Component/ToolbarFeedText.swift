//
//  ToolbarFeedText.swift
//  Primal
//
//  Created by Nikola Lukovic on 25.2.23..
//

import SwiftUI

struct ToolbarFeedText: View {
    @EnvironmentObject var feed: Feed
    
    var body: some View {
        FeedText()
    }
    
    @ViewBuilder
    func FeedText() -> some View {
        switch feed.currentFeed {
        case .myFeed: HighlightText("Latest, Following")
        case .trending: HighlightText("Trending, my network")
        case .highlights: HighlightText("Nostr Highlighys by Primal")
        case .snowden: HighlightText("Edward Snowden's feed")
        case .dorsey: HighlightText("Jack Dorsey's feed")
        case .nvk: HighlightText("NVK's feed")
        }
    }
    
    @ViewBuilder
    func HighlightText(_ text: String) -> some View {
        Text(text)
            .font(Font.custom("RobotoFlex-Regular", size: 18)
                .weight(.bold))
    }
}

struct ToolbarFeedText_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarFeedText()
            .environmentObject(Feed())
    }
}
