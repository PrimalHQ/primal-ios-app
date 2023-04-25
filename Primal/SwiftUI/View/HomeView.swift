//
//  HomeView.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @Binding var showMenu: Bool
    @Binding var imgURL: String
    @Binding var showImageViewer: Bool
        
    @State private var showingFeed = false
    
    @EnvironmentObject var feed: Feed
    @EnvironmentObject var uiState: UIState
        
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack (spacing: 0) {
                    HStack {
                        Button {
                            withAnimation{showMenu.toggle()}
                        } label: {
                            KFAnimatedImage(URL(string: feed.currentUser?.picture ?? ""))
                                .placeholder {
                                    Image("Profile")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 33, height: 33)
                                }
                                .onFailureImage((Image("Profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 33, height: 33) as? KFCrossPlatformImage))
                                .cacheOriginalImage()
                                .fade(duration: 0.25)
                                .startLoadingBeforeViewAppear()
                                .frame(width: 33, height: 33)
                                .clipShape(Circle())
                                .id(feed.currentUser?.picture)
                        }
                        
                        Spacer()
                        
                        Button {
                            showingFeed.toggle()
                        } label: {
                            Image("NEW - Feed picker")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .aspectRatio(contentMode: .fill)
                        }.sheet(isPresented: $showingFeed) {
                            FeedSheet()
                                .presentationDetents([.medium])
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    
                    Divider()
                }
                .transition(.scale)
                .overlay(
                    ToolbarFeedText()
                )
                .background(.thinMaterial)
                .zIndex(1)
                
                List {
                    Spacer(minLength: 45)
                    ForEach(feed.posts) { post in
                        NavigationLink(value: post) {
                            Post(imgURL: $imgURL, showImageViewer: $showImageViewer, post: post)
                        }
                        .isDetailLink(false)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .padding([.trailing], -18)
                        .onAppear() {
                            if self.feed.posts[safe: self.feed.posts.endIndex - 4] == post {
                                feed.requestNewPage(until: feed.posts.last?.post.created_at ?? 0)
                            }
                        }
                    }
                }
                .zIndex(0)
                .listStyle(.plain)
                .navigationDestination(for: PrimalPost.self) { item in
                    ThreadView(imgURL: $imgURL, showImageViewer: $showImageViewer, post: item)
                        .navigationBarBackButtonHidden(true)
                        .navigationTitle("Thread")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                NavigationBackButton()
                            }
                        }
                        .onAppear {
                            feed.requestThread(postId: item.post.id, subId: item.post.id)
                            uiState.isSideMenuDragGestureAllowed = false
                        }
                        .onDisappear {
                            uiState.isSideMenuDragGestureAllowed = true
                        }
                }
                .refreshable {
                    feed.refreshPage()
                }
            }.safeAreaInset(edge: .bottom, alignment: .trailing) {
                Button {} label: {
                    Image("AddPost")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: 56, height: 56)
                .offset(x: -13, y: -10)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Feed())
            .environmentObject(UIState())
    }
}
