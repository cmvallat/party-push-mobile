//
//  UserRow.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/30/24.
//

import SwiftUI

struct PartyRow: View {
    var party_name: String
    var isHost: Bool
    
    var body: some View {
        HStack{
            Image(systemName: isHost ? "party.popper.fill" : "person.fill")
                .resizable()
                .frame(width: 25, height: 25)
            Text(party_name)
            Spacer()
        }
    }
}

