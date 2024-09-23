//
//  AddHostSheet.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/15/24.
//

import SwiftUI

struct AddHostSheet: View 
{
    @State var partyName = ""
    @State var partyCode = ""
    @Binding var showAddPartyView: Bool
    @State private var inviteOnly: Bool = false
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Spacer()
                Button(action:{
                    showAddPartyView.toggle()
                })
                {
                    Label("", systemImage: "xmark.circle.fill")
                }
            }
            .padding(.top, 5)
            
            Spacer()
            
            Text("Create New Party")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding([.leading,.trailing], 15)
            
            TextField("Party Name", text: $partyName)
                .textFieldStyle(.roundedBorder)
                .padding([.leading,.trailing], 15)
            
            TextField("Party Code", text: $partyCode)
                .textFieldStyle(.roundedBorder)
                .padding([.leading,.trailing], 15)
            
            Toggle(isOn: $inviteOnly) {
                    Text("Private party")
                  }
            .toggleStyle(StyleHelpers.CheckboxToggleStyle())
                  .padding()
            
            Button(action:{
                //Todo: call add-host api
            })
            {
                Label("Submit", systemImage: "arrowshape.turn.up.forward.fill")
                    .tint(Color(red: 0, green: 0.65, blue: 0))
            }

            Spacer()
        }
        .background(Gradient(
            colors: [.blue, .pink]).opacity(0.2))
    }
}

#Preview {
    AddHostSheet(showAddPartyView: .constant(true))
}
