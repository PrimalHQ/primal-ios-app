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
    

    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(maxHeight: 20)
            Text("My Nostr Feeds")
                .font(Font.custom("RobotoFlex-Regular", size: 40)
                    .weight(.semibold))
            Group {
                Spacer()
                    .frame(maxHeight: 50)
                
                FeedButton(feedType: .myFeed, text: "Latest, Following", dismiss: dismiss)
            }
            Group {
                Spacer()
                    .frame(maxHeight: 10)
                FeedButton(feedType: .trending, text: "Trending, My network", dismiss: dismiss)
            }
            Group {
                Spacer()
                    .frame(maxHeight: 10)
                FeedButton(feedType: .myFeed, text: "Nostr highlights by Primal", dismiss: dismiss)
            }
            Group {
                Spacer()
                    .frame(maxHeight: 10)
                FeedButton(feedType: .snowden, text: "Edward Snowden's feed", dismiss: dismiss)
            }
            Group {
                Spacer()
                    .frame(maxHeight: 10)
                FeedButton(feedType: .dorsey, text: "Jack Dorsey's feed", dismiss: dismiss)
            }
            Group {
                Spacer()
                    .frame(maxHeight: 10)
                FeedButton(feedType: .nvk, text: "NVK's feed", dismiss: dismiss)
            }
            
        }
        .frame(maxHeight: .infinity)
        .background(colorScheme == .dark ? Color(hex: "#1C1C1C") : Color.white)
    }
}

struct FeedSheet_Previews: PreviewProvider {
    static var previews: some View {
        FeedSheet()
    }
}
