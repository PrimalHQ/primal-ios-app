//
//  HomeView.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI

struct HomeView: View {
    @Binding var showMenu: Bool
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
                            Image("ProfilePicture")
                                .resizable()
                                .frame(width: 33, height: 33)
                                .aspectRatio(contentMode: .fill)
                        }
                        
                        Spacer()
                        
                        Button {
                            showingFeed.toggle()
                        } label: {
                            Image("Feed")
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
                    ForEach(feed.posts, id: \.post.id) { post in
                        NavigationLink(value: post) {
                            Post(post: post)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .padding([.trailing], -16)
                        .onAppear() {
                            if self.feed.posts.last == post {
                                print("Hit rock bottom")
                                feed.requestNewPage(until: feed.posts.last?.post.created_at ?? 0)
                            }
                        }
                    }
                }
                .zIndex(0)
                .listStyle(.plain)
                .navigationDestination(for: PrimalPost.self) { item in
                    ThreadView(post: item)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: NavigationBackButton())
                        .navigationTitle("Thread")
                        .onAppear {
                            feed.requestThread(postId: item.post.id, subId: item.post.id)
                            uiState.isSideMenuDragGestureAllowed = false
                        }
                        .onDisappear {
                            uiState.isSideMenuDragGestureAllowed = true
                        }
                }
            }.safeAreaInset(edge: .bottom, alignment: .trailing) {
                Button {} label: {
                    Image("AddPost")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: 55, height: 55)
                .offset(x: -35, y: -35)
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
