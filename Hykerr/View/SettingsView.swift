//
//  SettingsView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/30/22.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @State private var profileImage = UIImage(systemName: "person.circle")!
    @State private var userName = ""
    @State private var userEmail = ""
    @State private var userPhoneNumber = ""
    @State private var userEmergencyContact = ""
    
    @State private var bioMetricsIsOn = false

    var body: some View {
        VStack{
            Image(uiImage: profileImage)
                .resizable().frame(width: 100, height: 100, alignment: .center)
                .cornerRadius(100)
                .shadow(color: .black, radius: 2, y:3)
                .padding(20)
            
            VStack{
                TextField("Name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Email", text: $userEmail)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Phone Number", text: $userPhoneNumber).keyboardType(.phonePad)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top)
                
                TextField("Emergency Contact", text: $userEmergencyContact).keyboardType(.phonePad)
                    .textFieldStyle(.roundedBorder)
                
                
                
            }.onAppear{
                viewModel.getUserInformation()
            }
            .frame(width:270)
            .padding(20).background(K.color.button.buttonColor).cornerRadius(20).shadow(radius: 10)
            
            Toggle(isOn: $bioMetricsIsOn) {
                Text("End Emergencies\nWith Biometrics").foregroundColor(K.color.button.buttonTextColor)
            }.padding().frame(width: 300, height: 100, alignment: .center).background(K.color.button.buttonColor).cornerRadius(20).shadow(radius: 10)
            
            Button(action: {
                
            }, label: {
                Text("Update")
                    .frame(width: 150, height:50)
                    .foregroundColor(K.color.button.buttonTextColor)
                    .background(K.color.button.buttonColor).cornerRadius(20)

            }).padding()

            
            
            
            
            
            
        }.onAppear{
            
        }.navigationTitle("Settings")
        
        
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
