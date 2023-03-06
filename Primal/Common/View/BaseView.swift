//
//  BaseView.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI

struct BaseView: View {
    init() {
        UITabBar.appearance().isHidden = true
    }
    @EnvironmentObject var uiState: UIState
        
    @State var showMenu: Bool = false
    @State var currentTab = "Home"
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @State var imgURL = ""
    @State var showImageViewer = false
    
    @GestureState var gestureOffset: CGFloat = 0
    
    var body: some View {
        let sidebarWidth = getRect().width - 90
        let dragGesture = DragGesture()
            .updating($gestureOffset, body: { value, out, _ in
                out = value.translation.width
            })
            .onEnded(onEnd(value:))
        
        NavigationView {
            HStack (spacing: 0) {
                SideMenu(showMenu: $showMenu)
                VStack(alignment: .leading, spacing: 0) {
                    TabView(selection: $currentTab) {
                        HomeView(showMenu: $showMenu, imgURL: $imgURL, showImageViewer: $showImageViewer)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Home")
                        Text("Explore")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Explore")
                        Text("Search")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Search")
                        Text("Messages")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Messages")
                        Text("Notifications")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(true)
                            .tag("Notifications")
                    }
                    
                    VStack (spacing: 0) {
                        Divider()
                        HStack (spacing: 0) {
                            TabButton(image: "Home")
                            TabButton(image: "Explore")
                            TabButton(image: "Search")
                            TabButton(image: "Messages")
                            TabButton(image: "Notifications")
                        }
                        .padding(.top, 15)
                        .padding(.bottom, safeArea().bottom == 0 ? 15 : 0)
                    }
                }
                .frame(width: getRect().width)
                .overlay(
                    Rectangle()
                        .fill(
                            Color.primary.opacity(Double((offset / sidebarWidth) / 5))
                        )
                        .ignoresSafeArea(.container, edges: .vertical)
                        .onTapGesture {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }
                    )
            }
            .frame(width: getRect().width + sidebarWidth)
            .offset(x: -sidebarWidth / 2)
            .offset(x: offset > 0 ? offset : 0)
            .gesture(uiState.isSideMenuDragGestureAllowed ? dragGesture : nil)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .animation(.easeInOut, value: offset == 0)
        .onChange(of: showMenu) { newValue in
            if showMenu && offset == 0 {
                offset = sidebarWidth
                lastOffset = offset
            }
            
            if !showMenu && offset == sidebarWidth {
                offset = 0
                lastOffset = 0
            }
        }
        .onChange(of: gestureOffset) { newValue in
            onChange()
        }
        .overlay(ImageViewerRemote(imageURL: self.$imgURL, viewerShown: self.$showImageViewer))
    }
    
    
    func onChange() {
        let sidebarWidth = getRect().width - 90
        
        offset = (gestureOffset != 0) ? ((gestureOffset + lastOffset) < sidebarWidth ? (gestureOffset + lastOffset) : offset) : offset
        
        offset = (gestureOffset + lastOffset) > 0 ? offset : 0
    }
    
    func onEnd(value: DragGesture.Value){
        let sideBarWidth = getRect().width - 90
        
        let translation = value.translation.width
        
        withAnimation{
            if translation > 0{
                
                if translation > (sideBarWidth / 2){
                    offset = sideBarWidth
                    showMenu = true
                }
                else {
                    
                    if offset == sideBarWidth || showMenu{
                        return
                    }
                    offset = 0
                    showMenu = false
                }
            }
            else{
                
                if -translation > (sideBarWidth / 2){
                    offset = 0
                    showMenu = false
                }
                else{
                    
                    if offset == 0 || !showMenu{
                        return
                    }
                    
                    offset = sideBarWidth
                    showMenu = true
                }
            }
        }
        
        lastOffset = offset
    }
    
    @ViewBuilder
    func TabButton(image: String)->some View{
        Button {
            withAnimation{currentTab = image}
        } label: {
            Image("NEW - \(image)")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 23, height: 22)
                .foregroundColor(currentTab == image ? .primary : .gray)
                .frame(maxWidth: .infinity)
        }
        
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Feed())
            .environmentObject(UIState())
    }
}
