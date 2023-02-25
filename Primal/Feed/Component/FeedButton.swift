//
//  FeedButton.swift
//  Primal
//
//  Created by Nikola Lukovic on 25.2.23..
//

import SwiftUI

struct FeedButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var feed: Feed
    
    @State var tap = false
    
    let feedType: FeedType
    let text: String
    let dismiss: DismissAction

    var body: some View {
        let highlightColor = colorScheme == .dark ? Color(hex: "#2C2C2F") : Color.gray.opacity(0.3)
        let primary = colorScheme == .dark ? Color(hex: "#1C1C1C") : Color.white

        Button {
            feed.setCurrentFeed(feedType)
            tap.toggle()
            dismiss()
        } label: {
            Text(text)
                .font(Font.custom("RobotoFlex-Regular", size: 20))
                .frame(maxWidth: .infinity)
                .padding([.top, .bottom], 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(tap ? highlightColor : primary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding([.leading, .trailing], 20)
    }
}

struct FeedButton_Previews: PreviewProvider {
    static var previews: some View {
        FeedSheet()
    }
}
