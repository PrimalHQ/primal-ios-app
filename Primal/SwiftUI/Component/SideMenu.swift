//
//  SideMenu.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI
import Kingfisher

struct SideMenu: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var feed: Feed
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                KFAnimatedImage(URL(string: feed.currentUser?.picture ?? ""))
                    .placeholder {
                        Image("Profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 65, height: 65)
                    }
                    .onFailureImage((Image("Profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 65, height: 65) as? KFCrossPlatformImage))
                    .cacheOriginalImage()
                    .fade(duration: 0.25)
                    .startLoadingBeforeViewAppear()
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                    .id(feed.currentUser?.picture)
                HStack(alignment: .center, spacing: 4) {
                    Text(feed.currentUser?.displayName ?? "")
                        .font(Font.custom("RobotoFlex-Regular", size: 24).weight(.bold))
                    Image("Verified")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color(hex: "#5B12A4"))
                }
                HStack (alignment: .center, spacing: 2) {
                    Text(feed.currentUser?.name ?? "")
                        .font(Font.custom("RobotoFlex-Regular", size: 16))
                    Image("Verified")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 12, height: 12)
                        .foregroundColor(.primary)
                    Text(feed.currentUser?.getDomainNip05() ?? "")
                        .font(Font.custom("RobotoFlex-Regular", size: 16))
                }
                HStack(spacing: 12) {
                    Button {} label: {
                        Label {
                            Text("Followers")
                                .font(Font.custom("RobotoFlex-Regular", size: 16))
                        } icon: {
                            Text("\(feed.currentUserStats?.followers_count ?? -1)")
                                .font(Font.custom("RobotoFlex-Regular", size: 16).weight(.bold))
                        }
                    }
                    Button {} label: {
                        Label {
                            Text("Following")
                                .font(Font.custom("RobotoFlex-Regular", size: 16))
                        } icon: {
                            Text("\(feed.currentUserStats?.follows_count ?? -1)")
                                .font(Font.custom("RobotoFlex-Regular", size: 16).weight(.bold))
                        }
                    }
                }.foregroundColor(.primary)
            }
            .padding()
            .padding(.leading)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 45) {
                        TabButton(title: "PROFILE")
                        TabButton(title: "BLOCKED USERS")
                        TabButton(title: "NOSTR RELAYS")
                        TabButton(title: "SETTINGS")
                    }
                    .padding(.horizontal)
                    .padding(.leading)
                    .padding(.top, 45)
                }
            }
            
            SignoutButton(title: "SIGN OUT")
                .padding(.horizontal)
                .padding(.leading)
                .padding(.bottom, 45)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: getRect().width - 90)
        .frame(maxHeight: .infinity)
        .background(Color.primary.opacity(0.04).ignoresSafeArea(.container, edges: .vertical))
        .frame(maxWidth: .infinity, alignment: .leading)
        .onDisappear {
            showMenu = false
        }
    }
    
    @ViewBuilder
    func TabButton(title: String)-> some View {
        NavigationLink {
            Text("\(title.capitalized) View")
                .navigationTitle(title)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: NavigationBackButton())
        } label: {
            Text(title)
                .font(Font.custom("RobotoFlex-Regular", size: 20).weight(.heavy))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    func SignoutButton(title: String) -> some View {
        Button {
            do {
                try clear_keypair()
                RootViewController.instance.set(OnboardingParentViewController())
            } catch {
                print("failed to clear keypair")
            }
        } label: {
            Text(title)
                .font(Font.custom("RobotoFlex-Regular", size: 20).weight(.heavy))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Feed())
            .environmentObject(UIState())
    }
}
