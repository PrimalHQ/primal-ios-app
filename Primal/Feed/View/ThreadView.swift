//
//  ThreadView.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI
import Kingfisher

enum Field: Hashable {
    case reply
}

struct ThreadView: View {
    @State var message = ""

    @Binding var imgURL: String
    @Binding var showImageViewer: Bool
    
    @EnvironmentObject var feed: Feed

    @Environment(\.colorScheme) var colorScheme

    @FocusState private var focusedField: Field?
    
    let post: PrimalPost
    let formatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        return formatter
    }()
    
    var body: some View {
        ZStack() {
            VStack(alignment: .leading, spacing: 0) {
                List {
                    PrimaryThread()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(.bottom, 3)
                    ForEach(feed.threadPosts) { post in
                        Post(imgURL: $imgURL, showImageViewer: $showImageViewer, post: post)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .listRowInsets(EdgeInsets())
            }
        }.safeAreaInset(edge: .bottom, alignment: .trailing) {
            VStack(spacing: 10) {
                TextField("reply to \(post.user.name)...", text: $message)
                    .focused($focusedField, equals: .reply)
                    .padding()
                    .frame(height: 42)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(LinearGradient(gradient: Gradient(colors: [Color(hex: "#DD3A55"), Color(hex: "#5B12A4")]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                    }.toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                focusedField = nil
                            }
                        }
                    }
            }
            .frame(height: 62)
            .padding([.leading, .trailing], 22)
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
    }
    
    @ViewBuilder
    func PrimaryThread() -> some View {
        HStack (alignment: .top, spacing: 0) {
            VStack (spacing: 5) {
                ZStack {
                    KFAnimatedImage(URL(string: post.user.picture) ?? URL(string: "https://dev.primal.net/assets/logo-873f0213.svg")!)
                        .placeholder {
                            ProgressView()
                        }
                        .cacheOriginalImage()
                        .cacheMemoryOnly()
                        .fade(duration: 0.25)
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                        .id(post.user.picture)
                        
                }
                Text(post.user.displayName)
                    .font(Font.custom("RobotoFlex", size: 12))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
                .padding(12)
                .frame(maxWidth: getRect().width / 5)
                .zIndex(1)
            Spacer(minLength: 5)
                .zIndex(2)
            VStack (alignment: .leading) {
                HStack (alignment: .center, spacing: 2) {
                    Text(post.user.name)
                        .font(Font.custom("RobotoFlex", size: 16))
                        .frame(height: 5)
                        .foregroundColor(Color(hex: "#666666"))
                    Image("Verified")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color(hex: "#666666"))
                    let date = Date(timeIntervalSince1970: TimeInterval(post.post.created_at))
                    Text("\(post.user.getDomainNip05())")
                        .font(Font.custom("RobotoFlex", size: 16))
                        .foregroundColor(Color(hex: "#666666"))
                        .frame(height: 5)
                        .frame(alignment: .leading)
                        .truncationMode(.tail)
                    Text(" | \(formatter.localizedString(for: date, relativeTo: Date.now))")
                        .font(Font.custom("RobotoFlex", size: 16))
                        .foregroundColor(Color(hex: "#666666"))
                    Spacer()
                }

                let result: [String] = post.post.content.extractTagsMentionsAndURLs()
                let text: [String] = result.filter { r in
                    return !r.isValidURLAndIsImage

                }
                let imageUrls: [String] = result.filter { r in
                    return r.isValidURLAndIsImage
                }
                Group {
                    ForEach(text) { t in
                        if t.isValidURL {
                            Text(try! AttributedString(markdown: t.transformURLStringToMarkdown))
                                .font(Font.custom("RobotoFlex", size: 16))
                                .padding(.trailing, 16)
                        } else {
                            Text(t)
                                .font(Font.custom("RobotoFlex", size: 16))
                                .foregroundColor(t.isHashTagOrMention ? Color(hex: "#CA079F") : Color.primary)
                                .padding(.trailing, 16)
                        }
                    }
                    if imageUrls.count == 1 {
                        KFAnimatedImage(URL(string: imageUrls[0])!)
                            .placeholder {
                                ProgressView()
                            }
                            .cacheOriginalImage()
                            .cacheMemoryOnly()
                            .fade(duration: 0.25)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.trailing, 16)
                            .id(post.post.id)
                            .onTapGesture {
                                self.imgURL = imageUrls[0]
                                self.showImageViewer = true
                            }
                    } else if !imageUrls.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(imageUrls) { url in
                                    KFAnimatedImage(URL(string: url)!)
                                        .placeholder {
                                            ProgressView()
                                        }
                                        .cacheOriginalImage()
                                        .cacheMemoryOnly()
                                        .fade(duration: 0.25)
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .padding(.trailing, 16)
                                        .frame(maxHeight: 200)
                                        .frame(minHeight: 200)
                                        .id(post.post.id)
                                        .onTapGesture {
                                            self.imgURL = url
                                            self.showImageViewer = true
                                        }
                                }
                            }
                        }
                    }
                }
                HStack (alignment: .center, spacing: 5) {
                    Group {
                        Image("Replies")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .padding(.top, 8)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "#FFFFFF") : .primary)
                        Text(String(post.post.replies))
                            .font(Font.custom("RobotoFlex", size: 15))
                            .padding(.top, 8)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "#AAAAAA") : .primary)
                    }
                    Spacer()
                    Group {
                        Image("Likes")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .padding(.top, 8)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "#FFFFFF") : .primary)
                        Text(String(post.post.likes))
                            .font(Font.custom("RobotoFlex", size: 15))
                            .padding(.top, 8)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "#AAAAAA") : .primary)
                    }
                    Spacer()
                    Group {
                        Image("Reposts")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .padding(.top, 8)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "#FFFFFF") : .primary)
                        Text(String(post.post.mentions))
                            .font(Font.custom("RobotoFlex", size: 15))
                            .padding(.top, 8)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "#AAAAAA") : .primary)
                    }
                    Spacer()
                    Group {
                        Image("Zaps")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .padding(.top, 8)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "#FFFFFF") : .primary)
                        Text(String(post.post.satszapped))
                            .font(Font.custom("RobotoFlex", size: 15))
                            .padding(.top, 8)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "#AAAAAA") : .primary)
                    }
                }
                .padding([.bottom, .trailing], 16)
            }
                .zIndex(3)
                .padding(.top, 16)
        }
        .background(colorScheme == .dark ? Color(hex: "#181818") : Color(UIColor.systemBackground))
        .overlay(alignment: .leading) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#DD3A55"), Color(hex: "#5B12A4")]), startPoint: .top, endPoint: .bottom)
            }
            .frame(width: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct ThreadView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Feed())
            .environmentObject(UIState())
    }
}
