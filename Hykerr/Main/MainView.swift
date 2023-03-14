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

struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    @State var menuOpened = false
    @State var locationSearch = ""
    @State var searchBarShowing = true
    
    var body: some View {
        NavigationView{
            ZStack{
                mapView(coordsInTrip: $viewModel.coordsInTrip)
                    .border(K.color.button.buttonColor)
                    .ignoresSafeArea(edges: .bottom)
                    .accentColor(K.color.button.buttonColor)
                    .onAppear{
                        viewModel.checkIfLocationServiceIsEnabled()
                    }
                
                //TODO Add sliding animation to dismiss searchbar
                
                if searchBarShowing == true{
                    SearchBarField(locationSearch: $locationSearch,
                                   toggleSearch: toggleSearch)
                    .transition(.move(edge: .top))
                }
                
                RecordInfoView(viewModel: viewModel)
                SideMenuView(menuOpened: menuOpened,
                             toggleMenu: toggleMenu)
                
            }.ignoresSafeArea(.keyboard)
                .navigationTitle(menuOpened ? "": "Hykerr")
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        if !menuOpened{
                            Button{ menuOpened.toggle()}
                        label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(K.color.button.buttonColor)
                        }
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

//MARK: - Record Info (Place to Record Drivers info)

struct RecordInfoView: View {
    
    @State var viewModel: MainViewModel
    @State var stateLicense = ""
    @State var carLicenses = ""
    
    @State private var recordInfoOpen = false
    @State private var tripStart = false
    @State private var emergencyReported = false
    
    
    // @State private var recordInfoY : CGFloat = UIScreen.main.bounds.height/3
    var body: some View {
        
        
        Button(tripStart ? "End" : "Record"){
            if tripStart == false{
                withAnimation(Animation.default) {
                    recordInfoOpen.toggle()}
            }
            
            else{
                tripStart.toggle()
                viewModel.tracking = false
                viewModel.userSaveTripInfoToFirebase(state: stateLicense, license: carLicenses)
            }
        }
        .frame(width: 100, height: 100, alignment: .center)
        .shadow(color: .black, radius: 10.0)
        .background(K.color.button.buttonColor.opacity(0.8)).foregroundColor(K.color.button.buttonTextColor)
        .cornerRadius(100)
        .offset(x: 125, y: 240)
        
        if tripStart == true{
            Button(emergencyReported ? "Stop" : "Emergency"){
                //Inform Emergency Contact (server side)
                emergencyReported.toggle()
                viewModel.emergency(state: stateLicense, car: carLicenses, activeEmergency: emergencyReported)
                
            }.frame(width:100,height:100, alignment: .center).background(K.color.button.emergencyButtonColor).cornerRadius(20).offset(x:-125,y: 240)
            
        }
        
        
        if recordInfoOpen{
            GeometryReader{ _ in
                EmptyView()
            }.background(Color.gray.opacity(0.5))
                .opacity(recordInfoOpen ? 1: 0)
                .animation(Animation.easeIn(duration: 0.5))
                .onTapGesture {
                    recordInfoOpen.toggle()
                }
            
            VStack{
                
                Text("Driver's Information").font(.title)
                
                HStack{
                    Spacer()
                    TextField("State",text: $stateLicense)
                        .frame(width: 75, alignment: .center)
                        .textFieldStyle(.roundedBorder)
                        .shadow(color: .black, radius: 1.0)
                    
                    
                    TextField("Car's License", text: $carLicenses)
                        .textFieldStyle(.roundedBorder)
                        .shadow(color: .black, radius: 1.0)
                    
                    
                    Button(
                        action:{
                            print("Place holder")//Get license plate
                        },
                        label:{
                            Image(systemName: "camera.viewfinder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:30)
                        })
                    Spacer()
                }
                
                Button("Submit"){
                    withAnimation(
                        .easeIn(duration: 4)){
                            recordInfoOpen.toggle()
                            tripStart.toggle()
                            viewModel.tracking = true
                            viewModel.userTripInfoToFirebase(state: stateLicense, license: carLicenses)
                        }
                    
                }.frame(width: 200, height: 50, alignment: .center)
                    .foregroundColor(K.color.button.buttonTextColor)
                    .background(K.color.button.buttonColor)
                    .cornerRadius(100).padding()
                
            }.frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height/3, alignment: .center)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .offset(y: UIScreen.main.bounds.height/3)
                .compositingGroup()
                .shadow(color: .black, radius: 10)
        }
        
    }
}


//MARK: - Search Bar

struct SearchBarField: View {
    
    @Binding var locationSearch: String
    @State private var searchBarY : CGFloat = -275
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
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged({ value in
                        if searchBarY > -300 && searchBarY < -249 {
                            searchBarY += value.translation.height
                            print(searchBarY)
                        }})
                    .onEnded({ value in
                        if value.translation.height < 0 {
                            self.toggleSearch()
                        }})
            )
    }
}


//MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainView().environmentObject(AuthenticationViewModel()).environmentObject(MainViewModel()).preferredColorScheme(.light)
        MainView().environmentObject(AuthenticationViewModel()).environmentObject(MainViewModel()).preferredColorScheme(.dark)
        
        
    }
}


//MARK: - MapView

struct mapView: UIViewRepresentable{
    func makeCoordinator() -> Coordinator {
        return mapView.Coordinator()
    }
    //@Binding var region : MKCoordinateRegion
    @Binding var coordsInTrip: LinkedList?
    
    let mapViewDelegate = Coordinator()
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        
        if let coordsInTrip = coordsInTrip {
            let region = MKCoordinateRegion(
                center: coordsInTrip.head.value  as! CLLocationCoordinate2D,
                latitudinalMeters: 750,
                longitudinalMeters: 750
            )
            map.region = region
        }
        
        return map
    }
    
    func updateUIView(_ map: MKMapView, context: Context) {
        
        guard let coordsInTrip = coordsInTrip else { return }
        
        let currentLocation = coordsInTrip.tranverseToIndex(coordsInTrip.length)
        
        let region = MKCoordinateRegion(
            center: currentLocation.value as! CLLocationCoordinate2D,
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
        
        map.delegate = mapViewDelegate
        map.showsUserLocation = true
        map.region = region
        
        addPath(to: map)
    }
    
    func addPath(to map : MKMapView){
        print("this updated")
        
        guard let coordsInTrip = coordsInTrip else { print("addPath failed"); return }
        
        let path = MKPolyline(coordinates: coordsInTrip.mapPath(), count: coordsInTrip.mapPath().count)
        
        
        if !map.overlays.isEmpty{ map.removeOverlays(map.overlays) }
        
        //map.setVisibleMapRect(path.boundingMapRect, animated: true)  //Shows whole path
        map.addOverlay(path, level: .aboveRoads)
    }
    
    
    
    class Coordinator : NSObject,MKMapViewDelegate{
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
            let render = MKPolylineRenderer(overlay: overlay)
            render.strokeColor = .black
            render.lineCap = .round
            render.lineWidth = 3.0
            return render
        }
    }
    
    
    
}
