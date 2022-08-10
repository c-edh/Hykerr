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


struct MenuContent: View{
    let toggleMenu: () -> Void

    
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
                
                HStack{
                    Text("Hi,").foregroundColor(K.color.Text.textColor).font(.system(size: 22))
                    Text(sideMenuViewModel.userName)
                    .foregroundColor(K.color.Text.textColor).font(.system(size: 22)).fontWeight(.heavy).minimumScaleFactor(0.05)
                    }.frame(width:150,alignment:.center).padding(.top,25).onAppear{
                        sideMenuViewModel.getUserName()
                    }

                Divider().foregroundColor(.black).padding()
                
                ForEach(SideMenuContentModel.allCases, id: \.self){item in
                   SideMenuContentView(viewModel: item)
                    
                
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

struct SideMenuContentView: View {
    let viewModel : SideMenuContentModel
    
    @State private var destinationView : SideMenuContentModel? = .settings
    
    var body: some View {
        HStack{
            NavigationLink(destination: view(goto: viewModel) , label:{
                Image(systemName: viewModel.symbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(K.color.Text.textColor)
                    .frame(width: 32, height: 32, alignment: .center)
                
                Text(viewModel.title)
                    .foregroundColor(K.color.Text.textColor)
                    .bold()
                    .font(.system(size: 22))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            })
            
        }
    }
    
    @ViewBuilder
    func view(goto destination: SideMenuContentModel?) -> some View{
        switch destination{
        case .some(.settings): SettingsView()
        case .some(.triphistory): TripHistoryView()
        default:
            EmptyView()
        }
    }
}
