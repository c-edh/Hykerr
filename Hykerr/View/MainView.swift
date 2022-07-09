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
    @State var locationSearch = ""
    @State var searchBarShowing = true
    
    var body: some View {
        NavigationView{
            ZStack{
                Map(coordinateRegion: $viewModel.region,showsUserLocation: true).border(K.color.button.buttonColor).ignoresSafeArea(edges: .bottom).accentColor(K.color.button.buttonColor).onAppear{
                    viewModel.checkIfLocationServiceIsEnabled()
                }
                
                //TODO Add sliding animation to dismiss searchbar
                
                if searchBarShowing == true{
                    SearchBarField(locationSearch: $locationSearch)
                }
               
                else{
                    EmptyView()
                        .frame(width: 220, height: 30, alignment: .center)
                        .background(.black).offset(y:-300)
                        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local).onEnded({ value in
                            if value.translation.height > 0{ searchBarShowing.toggle() }}))
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
    let hander: () -> Void = {
        print("Tapped Item")
    }
}
struct MenuContent: View{
    let toggleMenu: () -> Void

    
  //  let userProfilePicture: Image?
    let items : [MenuItem] = [
        MenuItem(text: "Settings", symbol: "gearshape.fill"),
    ]
    
    @State var userName = "Name"
    @EnvironmentObject var authenticViewModel : AuthenticViewModel

    var body: some View{
        
        ZStack{
            Color(UIColor.systemBackground)
           
            VStack(alignment: .leading, spacing: 0){
                
                Image(systemName: "person.circle")
                    .resizable().frame(width: 100, height: 100, alignment: .center)
                    .padding(.top, 40)
                    .foregroundColor(K.color.Text.textColor)
                
                Text(userName)
                    .foregroundColor(K.color.Text.textColor).fontWeight(.heavy)
                    .frame(width:100,alignment:.center).padding(.top,25)

                ForEach(items){item in
                    
                    HStack{
                        
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
                    }
                    
                    Divider().border(.black, width: 3)
                }.padding(.top,20)
                
            }.padding().offset(x:50,y:-250)
            
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






struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainView().environmentObject(AuthenticViewModel())
        
    }
}

struct SearchBarField: View {
    
    @Binding var locationSearch: String
    var body: some View {
        ZStack {
            TextField("", text: $locationSearch)
                .multilineTextAlignment(.center)
                .frame(width: 175, height: 50, alignment: .center)
                .background(K.color.button.buttonColor.opacity(0.8))
                .foregroundColor(K.color.button.buttonTextColor)
                .cornerRadius(30)
            Text("Search").foregroundColor(K.color.button.buttonTextColor.opacity(0.8))
            Image(systemName: "magnifyingglass").offset(x: 50).foregroundColor(K.color.button.buttonTextColor.opacity(0.8))
        }.offset(y:-275)
            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.height < 0 {// searchBarShowing.toggle()
                        
                    }}))
    }
}
