//
//  SideMenuView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/24/22.
//

import SwiftUI

struct SideMenuView: View {
   
    private let width: CGFloat = UIScreen.main.bounds.width/1.5
    let menuOpened: Bool
    let toggleMenu: () -> Void
    
    var body: some View {
        //dimmed background
        GeometryReader{ _ in
            EmptyView()
        }.background(Color.gray.opacity(0.5))
            .opacity(self.menuOpened ? 1: 0)
            .animation(Animation.easeIn(duration: 0.5))
            .onTapGesture {
                withAnimation(Animation.easeIn(duration: 0.5)) {}
                self.toggleMenu()
            }
      //menucontent
        HStack{
            MenuContent(toggleMenu: toggleMenu)
                .frame(width: width)
                .offset(x: menuOpened ? 0 : -width)
                .animation(.default)
                .gesture(
                    DragGesture(minimumDistance: 20).onEnded({ _ in
                        self.toggleMenu()
                    })
                )
            Spacer()
        }.ignoresSafeArea()
    }
}

struct MenuItem: Identifiable{
    var id = UUID()
    let text: String
    let symbol : String
}
struct MenuContent: View{
    let toggleMenu: () -> Void

    
  //  let userProfilePicture: Image?
    let items : [MenuItem] = [
        //MenuItem(text:"Home", symbol: "house.circle"),
        MenuItem(text: "Trip History", symbol: "clock.arrow.circlepath"),
        MenuItem(text: "Settings", symbol: "gear")
       // MenuItem(text: "Settings", symbol: "gearshape"),
    ]
    
    @EnvironmentObject var authenticViewModel : AuthenticViewModel
    @StateObject var sideMenuViewModel = SideMenuViewModel()

    var body: some View{
        
        ZStack{
            Color(UIColor.systemBackground)
           
            VStack(alignment: .center, spacing: 0){
                
                Image(uiImage:sideMenuViewModel.profileImage)
                    .resizable().frame(width: 100, height: 100, alignment: .center)
                    .cornerRadius(100)
                    .shadow(color: .black, radius: 2, y:3)
                    .padding(.top, 40)
                    .foregroundColor(K.color.Text.textColor).onAppear{
                        sideMenuViewModel.getUserPicture()
                    }
                
                Text(sideMenuViewModel.userName)
                    .foregroundColor(K.color.Text.textColor).font(.system(size: 22)).fontWeight(.heavy)
                    .frame(width:100,alignment:.center).padding(.top,25).onAppear{
                        sideMenuViewModel.getUserName()
                    }

                Divider().foregroundColor(.black).padding()
                
                ForEach(items){item in
                    
                    HStack{
                        NavigationLink(destination: TripHistoryView(), label:{
                        Image(systemName: item.symbol)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(K.color.Text.textColor)
                            .frame(width: 32, height: 32, alignment: .center)
                        
                        Text(item.text)
                            .foregroundColor(K.color.Text.textColor)
                            .bold()
                            .font(.system(size: 22))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        })
                        
                    }
//                    Divider()
                }.padding(.top,20)
                
            }.padding().offset(y:-250)
            
            Button("Logout"){authenticViewModel.logOut()}
                .font(.body.bold())
                .frame(width: 120, height: 40, alignment: .center)
                .background(K.color.button.buttonColor)
                .foregroundColor(K.color.button.buttonTextColor)
                .cornerRadius(20)
                .offset(y:250)
        }
    }
  
}


//struct SideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        //SideMenuView()
//    }
//}
