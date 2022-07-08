//
//  MainView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/4/22.
//

import SwiftUI
import CoreLocation
import MapKit
import CoreLocationUI
import Firebase




struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    @State var menuOpened = false

    
    var body: some View {
        NavigationView{
            ZStack{
                Map(coordinateRegion: $viewModel.region,showsUserLocation: true).cornerRadius(20).border(K.color.button.buttonColor).ignoresSafeArea(edges: .bottom).onAppear{
                    viewModel.checkIfLocationServiceIsEnabled()
                }
           
            //Max needs to be in corner, needs to be higher on iphone 8
            Button("Record"){
                self.menuOpened.toggle()
            }
            .frame(width: 100, height: 100, alignment: .center)
            .shadow(color: .black, radius: 10.0)
            .background(K.color.button.buttonColor.opacity(0.8)).foregroundColor(K.color.button.buttonTextColor)
            .cornerRadius(100)
            .offset(x: 125, y: 240)
                
            SideMenu(width: UIScreen.main.bounds.width/1.5,
                         menuOpened: menuOpened,
                         toggleMenu: toggleMenu)
            
            }
        
            .navigationTitle(menuOpened ? "": "Hykerr")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    if !menuOpened{
                        Button(action: {
                            menuOpened.toggle()
                        }, label: {
                            Image(systemName: "line.3.horizontal").foregroundColor(K.color.button.buttonColor)
                        })
                        
                    }

                }

            }
            
        }

        
    }
    
    func toggleMenu(){
        menuOpened.toggle()
    }
}





//MARK: - sidemenu

struct SideMenu: View {
   
    let width: CGFloat
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
            Spacer()
        }.ignoresSafeArea()
    }
}

struct MenuItem: Identifiable{
    var id = UUID()
    let text: String
    let hander: () -> Void = {
        print("Tapped Item")
    }
}
struct MenuContent: View{
    let toggleMenu: () -> Void

    
  //  let userProfilePicture: Image?
    let items : [MenuItem] = [
        MenuItem(text: "Settings"),
    ]
    
    @State var userName = "Name"
    @EnvironmentObject var loginViewModel : LoginViewModel

    var body: some View{
        
        ZStack{
            Color(UIColor(red: 255/255.0, green: 255/255.0, blue: 1, alpha: 1))
           
            VStack(alignment: .leading, spacing: 0){
                
                Image(systemName: "person.circle")
                    .resizable().frame(width: 100, height: 100, alignment: .center)
                    .padding()
                    .foregroundColor(.black)
                
                Text(userName)
                    .foregroundColor(.black)
                    .frame(alignment:.center)

                ForEach(items){item in
                    
                    HStack{
                        
                        Image(systemName: "house")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32, alignment: .center)
                        
                        Text(item.text)
                            .foregroundColor(Color.black)
                            .bold()
                            .font(.system(size: 22))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    
                    Divider().border(.black, width: 3)
                }
                
            }.padding()
            
            Button("Logout"){loginViewModel.logOut()}
                .font(.body.bold())
                .frame(width: 120, height: 40, alignment: .center)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
        }
    }
}






struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainView().environmentObject(LoginViewModel())
        
    }
}
