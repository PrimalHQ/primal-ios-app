//
//  RemoteSignerWidgetLiveActivity.swift
//  RemoteSignerWidget
//
//  Created by Pavle Stevanović on 15. 12. 2025..
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct RemoteSignerWidgetExpandedView: View {
    let context: ActivityViewContext<RemoteSignerWidgetAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                HStack {
                    Image(context.attributes.isBlue ? .dynamicIslandLogoBlue :.dynamicIslandLogo)
                    
                    
                    Text(context.state.titleText())
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                }
                
                Text(context.attributes.timeStarted, style: .timer)
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.trailing)
            }
            
            HStack(alignment: .bottom) {
                if let currentlyPlaying = context.state.currentlyPlaying {
                    VStack {
                        Text((context.state.isMuted ? "Muted: " : "Now playing: ") + currentlyPlaying)
                            .font(.system(size: 12))
                        
                        HStack(spacing: 30) {
                            Button(intent: PrevSongOrderIntent()) {
                                Image(.prevSong)
                            }
                            .buttonStyle(.plain)
                            
                            Button(intent: MuteOrderIntent()) {
                                Image(context.state.isMuted ? .soundMuted : .sound)
                            }
                            .buttonStyle(.plain)
                            
                            Button(intent: NextSongOrderIntent()) {
                                Image(.nextSong)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Spacer()
                }
                
                Button(intent: EndSessionOrderIntent()) {
                    Text("End Session")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(Color("buttonBackground"))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct RemoteSignerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RemoteSignerWidgetAttributes.self) { context in
            
            RemoteSignerWidgetExpandedView(context: context)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    RemoteSignerWidgetExpandedView(context: context)
                }
            } compactLeading: {
                Image(context.attributes.isBlue ? .dynamicIslandLogoBlue :.dynamicIslandLogo)
            } compactTrailing: {
                Image(.signingSession)
                    .foregroundStyle(Color(uiColor: .init(rgb: 0xDDDDDD)))
            } minimal: {
                Image(context.attributes.isBlue ? .dynamicIslandLogoBlue :.dynamicIslandLogo)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension RemoteSignerWidgetAttributes {
    fileprivate static var preview: RemoteSignerWidgetAttributes {
        .init(timeStarted: .now, isBlue: false)
    }
}

extension RemoteSignerWidgetAttributes.ContentState {
    fileprivate static var primalForest: RemoteSignerWidgetAttributes.ContentState {
        RemoteSignerWidgetAttributes.ContentState(connectedApps: ["Primal WebApp"], currentlyPlaying: "Forest", isMuted: true)
     }
}

#Preview("Notification", as: .content, using: RemoteSignerWidgetAttributes.preview) {
   RemoteSignerWidgetLiveActivity()
} contentStates: {
    RemoteSignerWidgetAttributes.ContentState.primalForest
}
