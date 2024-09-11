//
//  GuestRow.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/2/24.
//

import SwiftUI

struct GuestRow: View {
    var guest: Guest
    
    var body: some View {
        HStack{
            Image(systemName: "party.popper.fill")
                .resizable()
                .frame(width: 25, height: 25)
            Text(guest.party_code)
            Spacer()
        }
    }
}

#Preview() {
    Group{
        GuestRow(guest: guests[0])
        GuestRow(guest: guests[1])
        GuestRow(guest: guests[2])
    }
}
