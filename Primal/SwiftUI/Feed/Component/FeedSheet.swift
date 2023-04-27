//
//  FeedSheet.swift
//  Primal
//
//  Created by Nikola Lukovic on 25.2.23..
//

import SwiftUI

struct FeedSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var feed: Feed

    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(maxHeight: 20)
            Text("My Nostr Feeds")
                .font(Font.custom("RobotoFlex-Regular", size: 40)
                    .weight(.semibold))
            List {
                ForEach(feed.currentUserSettings?.content.feeds ?? [], id: \.name.id) { feed in
                    FeedButton(text: feed.name, dismiss: dismiss)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
        }
        .frame(maxHeight: .infinity)
        .background(colorScheme == .dark ? Color(hex: "#1C1C1C") : Color.white)
    }
}

struct FeedSheet_Previews: PreviewProvider {
    static var previews: some View {
        FeedSheet()
            .environmentObject(Feed())
            .environmentObject(UIState())
    }
}
