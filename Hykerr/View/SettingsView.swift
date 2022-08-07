//
//  SettingsView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/30/22.
//

import SwiftUI

struct SettingsView: View {
    @State private var profileImage = UIImage(systemName: "person.circle")!
    @State private var userName = ""
    @State private var userEmail = ""
    @State private var userPhoneNumber = ""
    @State private var userEmergencyContact = ""

    var body: some View {
        VStack{
            Image(uiImage: profileImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, alignment: .center).padding(20)
            
            VStack{
                TextField("Name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Email", text: $userEmail)
                    .textFieldStyle(.roundedBorder)
                
                TextField("PhoneNumber", text: $userPhoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top)
                
                TextField("Emergency Contact", text: $userEmergencyContact)
                    .textFieldStyle(.roundedBorder)
                
            }
            .frame(width:270,height: 200)
            .padding(20).background(Color(hue: 1.0, saturation: 0.001, brightness: 0.906)).cornerRadius(50).shadow(radius: 10)
            
            Button(action: {
                
            }, label: {
                Text("Update")
                    .frame(width: 150, height:50)
                    .foregroundColor(K.color.button.buttonTextColor)
                    .background(K.color.button.buttonColor).cornerRadius(20)

            }).padding()

            
            
            
            
            
            
        }.navigationTitle("Settings")
        
        
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
