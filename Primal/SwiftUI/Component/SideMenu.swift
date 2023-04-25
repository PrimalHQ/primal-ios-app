//
//  SideMenu.swift
//  Primal
//
//  Created by Nikola Lukovic on 20.2.23..
//

import SwiftUI

struct SideMenu: View {
    @Binding var showMenu: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                Image("Profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 65, height: 65)
                HStack(alignment: .center, spacing: 4) {
                    Text("miljan")
                        .font(Font.custom("RobotoFlex-Regular", size: 24).weight(.bold))
                    Image("Verified")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color(hex: "#5B12A4"))
                }
                HStack (alignment: .center, spacing: 2) {
                    Text("miljan")
                        .font(Font.custom("RobotoFlex-Regular", size: 16))
                    Image("Verified")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 12, height: 12)
                        .foregroundColor(.primary)
                    Text("primal.net")
                        .font(Font.custom("RobotoFlex-Regular", size: 16))
                }
                HStack(spacing: 12) {
                    Button {} label: {
                        Label {
                            Text("Followers")
                                .font(Font.custom("RobotoFlex-Regular", size: 16))
                        } icon: {
                            Text("135")
                                .font(Font.custom("RobotoFlex-Regular", size: 16).weight(.bold))
                        }
                    }
                    Button {} label: {
                        Label {
                            Text("Following")
                                .font(Font.custom("RobotoFlex-Regular", size: 16))
                        } icon: {
                            Text("345")
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
            
            TabButton(title: "SIGN OUT")
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
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(showMenu: .constant(true))
    }
}
