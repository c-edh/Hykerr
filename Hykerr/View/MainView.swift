//
//  MainView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/4/22.
//

import SwiftUI
import CoreLocation
//import MapKit
import CoreLocationUI




struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    @State var menuOpened = false
    @State var locationSearch = ""
    @State var searchBarShowing = true
    @State private var recordInfoOpen = false
    
    var body: some View {
        NavigationView{
            ZStack{
                //UIVIEWRepresentable
                mapView(currentLocation: $viewModel.currentLocation, path: $viewModel.path)
                    .border(K.color.button.buttonColor).ignoresSafeArea(edges: .bottom).accentColor(K.color.button.buttonColor).onAppear{
                                        viewModel.checkIfLocationServiceIsEnabled()
                                    }
                
                //TODO Add sliding animation to dismiss searchbar
                
                if searchBarShowing == true{
                    SearchBarField(
                        locationSearch: $locationSearch , toggleSearch: toggleSearch).transition(.move(edge: .top))
                }
               //Make a way so user can swipe search back down
            

                    
                       
                //Max needs to be in corner, needs to be higher on iphone 8
                Button("Record"){
//                    withAnimation(.spring(dampingFraction: 0.5).speed(3)){}
                        recordInfoOpen.toggle()
                    print("Should have sent location, check")
                }
                .frame(width: 100, height: 100, alignment: .center)
                .shadow(color: .black, radius: 10.0)
                .background(K.color.button.buttonColor.opacity(0.8)).foregroundColor(K.color.button.buttonTextColor)
                .cornerRadius(100)
                .offset(x: 125, y: 240)
                
          
                
                RecordInfoView(toggleRecordMenu: $recordInfoOpen, viewModel: viewModel)
            
                    
                SideMenu(width: UIScreen.main.bounds.width/1.5,
                             menuOpened: menuOpened,
                             toggleMenu: toggleMenu)
                
            }.ignoresSafeArea(.keyboard)
        
            .navigationTitle(menuOpened ? "": "Hykerr")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    if !menuOpened{
                        Button(
                            action: { menuOpened.toggle()},
                            label: { Image(systemName: "line.3.horizontal").foregroundColor(K.color.button.buttonColor)}
                        )
                        
                    }

                }

            }
            
        }

        
    }
    func toggleSearch(){
        searchBarShowing.toggle()
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
        MenuItem(text: "Trip History", symbol: "clock.arrow.circlepath"),
        MenuItem(text: "Settings", symbol: "gearshape"),
    ]
    
    @EnvironmentObject var authenticViewModel : AuthenticViewModel
    @StateObject var mainViewModel = MainViewModel()

    var body: some View{
        
        ZStack{
            Color(UIColor.systemBackground)
           
            VStack(alignment: .center, spacing: 0){
                
                Image(uiImage:mainViewModel.profileImage)
                    .resizable().frame(width: 100, height: 100, alignment: .center)
                    .cornerRadius(100)
                    .shadow(color: .black, radius: 2, y:3)
                    .padding(.top, 40)
                    .foregroundColor(K.color.Text.textColor).onAppear{
                        mainViewModel.getUserPicture()
                    }
                
                Text(mainViewModel.userName)
                    .foregroundColor(K.color.Text.textColor).font(.system(size: 22)).fontWeight(.heavy)
                    .frame(width:100,alignment:.center).padding(.top,25).onAppear{
                        mainViewModel.getUserName()
                    }

                Divider().foregroundColor(.black).padding()
                
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

//MARK: - Search Bar

struct SearchBarField: View {
    
    @Binding var locationSearch: String
    @State var searchBarY : CGFloat = -275
    let toggleSearch: () -> Void

    
    var body: some View {
        ZStack {
            
            TextField("", text: $locationSearch)
                .multilineTextAlignment(.center)
                .frame(width: 175, height: 50, alignment: .center)
                .background(K.color.button.buttonColor.opacity(0.8))
                .foregroundColor(K.color.button.buttonTextColor)
                .cornerRadius(30)
            
            Text("Search")
                .foregroundColor(K.color.button.buttonTextColor.opacity(0.8))
            
            Image(systemName: "magnifyingglass").offset(x: 50).foregroundColor(K.color.button.buttonTextColor.opacity(0.8))
        
        }.offset(y:searchBarY)
            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onChanged({ value in
                    if searchBarY > -300 && searchBarY < -249 {
                        searchBarY += value.translation.height
                        print(searchBarY)
                    }
                })
                .onEnded({ value in
                    if value.translation.height < 0 {
                        self.toggleSearch()
                        }
                })
            )
    }
}

//MARK: - Record Info (Place to Record Drivers info)

struct RecordInfoView: View {
    
    @Binding var toggleRecordMenu : Bool
    @State var viewModel: MainViewModel
    @State var stateLicenese = ""
    @State var carLicenses = ""
    
    var body: some View {
        
        if toggleRecordMenu{
            
        VStack{
            
            Text("Driver's Information")
            
            HStack{
              
                TextField("State",text: $stateLicenese)
                    .frame(width: 75, alignment: .center)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Car's License", text: $carLicenses)
                    .textFieldStyle(.roundedBorder)
            
            }.padding(20)
                .shadow(color: .black, radius: 1.0)
            
            Button("Submit"){
                withAnimation(
                    .easeIn(duration: 4)){
                        toggleRecordMenu.toggle()
                        viewModel.userTripInfoToFirebase(state: stateLicenese, license: carLicenses)
                    }
                
                print("test")
            }.frame(width: 200, height: 50, alignment: .center)
                .foregroundColor(K.color.button.buttonTextColor)
                .background(K.color.button.buttonColor)
                .cornerRadius(100).padding()
            
        }.frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height/4, alignment: .center)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .offset(y:UIScreen.main.bounds.height/3)
            .compositingGroup()
            .shadow(color: .black, radius: 10)
       
        }
        
    }
}


//MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
//        RecordInfoView(toggleRecordMenu: true)
        
        MainView().environmentObject(AuthenticViewModel()).environmentObject(MainViewModel()).preferredColorScheme(.light)
        MainView().environmentObject(AuthenticViewModel()).environmentObject(MainViewModel()).preferredColorScheme(.dark)
        
        
    }
}
