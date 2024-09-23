import SwiftUI

struct HostManagementPage: View {
    
    var host: Host
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(host.party_name)
                    .font(.title)
                
                HStack {
                    Text("party code: \(host.party_code)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                Divider()
                
                Text("About the Party")
                    .font(.title2)
                    .padding(.bottom, 10)
                Text("Add description here if we want to add it to the Host object schema in the database.")
                    .font(.subheadline)
            }
            .padding()
            
            Spacer()
        }
    }
}

#Preview {
    HostManagementPage(host: hosts[0])
}
