//
//  UserList.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/30/24.
//

import SwiftUI

struct HostList: View {
    var body: some View {
        NavigationSplitView {
                List(hosts) { host in
                    NavigationLink {
                        HostManagementPage(host: host)
                    } label: {
                        HostRow(host: host)
                    }
                }
                .navigationTitle("Guest parties")
        }    detail: {
            Text("Select a party")
        }
    }
}

#Preview {
    HostList()
}
