//
//  UserRow.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/30/24.
//

import SwiftUI

struct HostRow: View {
    var host: Host
    
    var body: some View {
        HStack{
            host.image
                .resizable()
                .frame(width: 25, height: 25)
            Text(host.party_name)
            Spacer()
        }
    }
}

#Preview() {
    Group{
        HostRow(host: hosts[0])
        HostRow(host: hosts[1])
    }
}
