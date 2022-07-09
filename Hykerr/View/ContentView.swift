//
//  ContentView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/4/22.
//

import SwiftUI
import FirebaseAuth



struct ContentView: View {
   
    @State var userIsLogout  = false
    @EnvironmentObject var authenticViewModel : AuthenticViewModel

    var body: some View {
        
        //Keeps user signed in
        if (authenticViewModel.signedIn == true) || (Auth.auth().currentUser != nil){
            MainView()
        }else{
            AppStartView()

        }
        
    }
        
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthenticViewModel())
        
        
    }
}

struct AppStartView: View {
    var body: some View {
        NavigationView{
        VStack{
            
            Text("Hykerr")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Image("hykerrLogo").resizable().frame(width: 400, height: 400, alignment: .center)
            
            
            NavigationLink("Login", destination: LoginView())
                .font(.body.bold())
                .frame(width: 200, height: 50, alignment: .center)
                .background(K.color.button.buttonColor)
                .foregroundColor(K.color.button.buttonTextColor)
                .cornerRadius(20)
            
            
            NavigationLink("Sign Up",destination: SignUpView())
                .font(.body.bold()).padding(20).foregroundColor(K.color.Text.textColor)
            
        }}
    }
}
