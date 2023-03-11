//
//  Post.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI
import Kingfisher

struct Post: View {
    @Binding var imgURL: String
    @Binding var showImageViewer: Bool
    
    @Environment(\.colorScheme) var colorScheme
        
    let post: PrimalPost
    
    let formatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        return formatter
    }()
    
    var body: some View {
        let result: [String] = post.post.content.extractTagsMentionsAndURLs()
        let text: [String] = result.filter { r in
            return !r.isValidURLAndIsImage
            
        }
        let imageUrls: [String] = result.filter { r in
            return r.isValidURLAndIsImage
        }
        
        VStack (alignment: .leading) {
            HStack (alignment: .center) {
                Text(post.user.name)
                    .font(Font.custom("RobotoFlex", size: 16))
                    .foregroundColor(Color(hex: "#666666"))
                Image("Verified")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color(hex: "#666666"))
                let date = Date(timeIntervalSince1970: TimeInterval(post.post.created_at))
                Text("\(post.user.getDomainNip05())")
                    .font(Font.custom("RobotoFlex", size: 16))
                    .foregroundColor(Color(hex: "#666666"))
                    .frame(alignment: .leading)
                    .truncationMode(.tail)
                Text("| \(formatter.localizedString(for: date, relativeTo: Date.now))")
                    .font(Font.custom("RobotoFlex", size: 16))
                    .foregroundColor(Color(hex: "#666666"))
            }
            .padding(.leading, getRect().width / 5)
            VStack (alignment: .leading) {
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

                }
                .padding(.leading, getRect().width / 5)
            }
            VStack {
                if imageUrls.count == 1 {
                    KFAnimatedImage(URL(string: imageUrls[0])!)
                        .placeholder {
                            ProgressView()
                        }
                        .cacheOriginalImage()
                        .fade(duration: 0.25)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.trailing, 16)
                        .id(imageUrls[0])
                        .onTapGesture {
                            self.imgURL = imageUrls[0]
                            self.showImageViewer = true
                        }
                        .padding(.leading, getRect().width / 5)
                } else if !imageUrls.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(imageUrls) { url in
                                KFAnimatedImage(URL(string: url)!)
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .cacheOriginalImage()
                                    .fade(duration: 0.25)
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.trailing, 16)
                                    .frame(maxHeight: 200)
                                    .frame(minHeight: 200)
                                    .id(url)
                                    .onTapGesture {
                                        self.imgURL = url
                                        self.showImageViewer = true
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.top, 12)
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
            .padding(.leading, getRect().width / 5)
        }
        .padding(16)
        .overlay(alignment: .topLeading) {
            VStack (alignment: .leading, spacing: 5) {
                KFAnimatedImage(URL(string: post.user.picture))
                    .placeholder {
                        Image("Profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 52, height: 52)
                    }
                    .onFailureImage((Image("Profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 52, height: 52) as? KFCrossPlatformImage))
                    .cacheOriginalImage()
                    .fade(duration: 0.25)
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .id(post.user.picture)
                Text(post.user.displayName)
                    .font(Font.custom("RobotoFlex", size: 12))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: getRect().width / 5)
            .padding([.leading, .top], 12)
        }
        .background(colorScheme == .dark ? Color(hex: "#181818") : Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.bottom, 4)
    }
}

struct Post_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Feed())
            .environmentObject(UIState())
    }
}
