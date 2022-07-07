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
    @EnvironmentObject var loginViewModel : LoginViewModel

    var body: some View {
        if !loginViewModel.signedIn{
                AppStartView()
        }else{
            withAnimation(Animation.easeIn(duration: 0.5)) {
                MainView()
            }
          
        }
        
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(LoginViewModel())
        
        
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
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
            
            
            NavigationLink("Sign Up",destination: SignUpView())
                .font(.body.bold()).padding(20)
            
        }}
    }
}
