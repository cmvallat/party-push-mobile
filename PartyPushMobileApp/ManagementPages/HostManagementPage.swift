import SwiftUI
//import Foundation

struct HostManagementPage: View {
    
    var host: Host
    // For testing:
    // var demoFoodListFromApi: [Food]
    // var demoGuestListFromApi: [Guest]
    @StateObject var viewModel = ViewModel()
    let authUser: AuthUser
    @State private var showGuestPopover: Bool = false
    @State private var itemToDelete: Food?
    @State private var showAddFoodView = false
    @State var newFoodItem: String = ""

    var body: some View {
        VStack
        {
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
                
                Divider()
                
                List{
                    Section{
                        ForEach(viewModel.foods) { row in
                            HStack {
                                Text(row.item_name)
                                    .swipeActions(edge: .trailing)
                                    {
                                        // Delete item button
                                        Button(role: .destructive) { print("deleted food")
                                            viewModel.deleteFoodItem(authUser: authUser, host: host, item_name: row.item_name)
                                        }
                                        label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .tint(Color.red)
                                        
                                        // Report low button
                                        Button {
                                            viewModel.reportFood(authUser: authUser, itemName: row.item_name, partyCode: host.party_code, status: "low")
                                            print("\(row.item_name) reported low")
                                        }
                                        label: {
                                            Label("Low", systemImage: "exclamationmark.triangle.fill")
                                        }
                                        .tint(Color.yellow)
                                        
                                        // Report refilled button
                                        Button {
                                            viewModel.reportFood(authUser: authUser, itemName: row.item_name, partyCode: host.party_code, status: "full")
                                            print("\(row.item_name) reported refilled")
                                        }
                                        label: {
                                            Label("Refilled", systemImage: "arrow.trianglehead.2.counterclockwise")
                                        }//5
                                        .tint(Color.green)
                                    }//4
                                Spacer()
                            } //3
                        }//2
                        Button {
                            // show add food sheet
                            showAddFoodView.toggle()
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }//1
//                    .toolbar {
//                    }
                    header: {
                        Text("Food/Drinks")
                            .font(.headline)
                    }
                    .headerProminence(.increased)


                    Section{
                        // add toggle for current/invited guests
                        ForEach(viewModel.guests) { row in
                                HStack {
                                    Text(row.guest_name)
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                print("deleted guest")
                                                viewModel.deleteGuest(authUser: authUser, host: host, guest: row)
                                            }
                                            label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                    }
                    header: {
                        HStack{
                            Text("Guests")
                                .font(.headline)
                            Button("", systemImage: "info.circle")
                            {
                                showGuestPopover.toggle()
                            }
                            .popover(isPresented: $showGuestPopover, attachmentAnchor: .point(.bottom), content: {
                                Text("Swipe to remove a guest from your party, and toggle to see current guests only vs all guests (current AND invited).")
                                    .font(.caption)
                                    .presentationCompactAdaptation(.popover)
                                    .padding([.leading, .trailing], 5)
                            })
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            .padding()
            
            Spacer()
        }
        .sheet(isPresented: $showAddFoodView, content: {
            AddFoodSheet(host: host, authUser: authUser, showAddFoodView: $showAddFoodView)
        })
        .refreshable {
            viewModel.getFoodList(authUser: authUser, host: host)
            viewModel.getGuestList(authUser: authUser, host: host)
        }
        .onAppear(perform:{
//            sendNotification(authUser: authUser, title: "Party Push", body: "Test host mgmt page")
            viewModel.getFoodList(authUser: authUser, host: host)
            viewModel.getGuestList(authUser: authUser, host: host)
        })
    }
}

extension HostManagementPage
{
    // add notifications
    class ViewModel: ObservableObject
    {
        @Published var foods = [Food]()
        @Published var guests = [Guest]()
        @Published var addFoodResponse = ""
        @Published var reportFoodResponse = ""
        
//        func getFoodList(authUser: AuthUser, host: Host completion: @escaping (String) -> Void)
//        {
//        }
        
        func getFoodList(authUser: AuthUser, host: Host)
        {
            let authorizedUser = authorizeCall(authUser: authUser)
            
            let queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString), URLQueryItem(name: "party_code", value: host.party_code)]
            
            // Todo: store url somewhere?
            var urlComps = URLComponents(string: "https://92q2nhqvgb.execute-api.us-east-1.amazonaws.com/Prod")!
            urlComps.queryItems = queryItems
            
            // Todo: don't use force unwrap
            var request = URLRequest(url: urlComps.url!)
            request.httpMethod = "GET"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
                        
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                }
//                else if let data = $0
//                {
                else if let data = $0, let resp = try? JSONDecoder().decode(APIResponse<Food>.self, from: data)
                {
                    let foodList = resp.data
                    
                    DispatchQueue.main.async{
                        [weak self] in
                        self?.foods = foodList
                    }
                }
                else
                {
                    print("else")
                    let s = String(data: $0!, encoding: .utf8)!
                    print(s)
                }
            }
            task.resume()
        }
        
        func getGuestList(authUser: AuthUser, host: Host)
        {
            let authorizedUser = authorizeCall(authUser: authUser)

            let queryItems = [URLQueryItem(name: "party_code", value: host.party_code)]
            
            // Todo: store url somewhere?
            var urlComps = URLComponents(string: "https://sihkfz9re8.execute-api.us-east-1.amazonaws.com/Prod")!
            urlComps.queryItems = queryItems
            
            // Todo: don't use force unwrap
            var request = URLRequest(url: urlComps.url!)
            request.httpMethod = "GET"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
            
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                }
                else if let data = $0, let guests = try? JSONDecoder().decode([Guest].self, from: data)
                {
                    let s = String(data: $0!, encoding: .utf8)!
                    print(s)
                    
                    DispatchQueue.main.async
                    { [weak self] in
                        self?.guests = guests
                    }
                }
                else
                {
                    print("else")
                    let s = String(data: $0!, encoding: .utf8)!
                    print(s)
                }
            }
            task.resume()
        }
        
        func deleteFoodItem(authUser: AuthUser, host: Host, item_name: String)
        {
            let authorizedUser = authorizeCall(authUser: authUser)
            
            let queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString), URLQueryItem(name: "party_code", value: host.party_code),URLQueryItem(name: "item_name", value: item_name)]
                        
            // Todo: store url somewhere?
            var urlComps = URLComponents(string: "https://e8ro13vvl3.execute-api.us-east-1.amazonaws.com/Prod")!
            urlComps.queryItems = queryItems
            
            // Todo: don't use force unwrap
            var request = URLRequest(url: urlComps.url!)
            request.httpMethod = "DELETE"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
            
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                }
                else
                {
                    print("success deleting food!")
                }
            }
            task.resume()
        }
        
        func deleteGuest(authUser: AuthUser, host: Host, guest: Guest)
        {
            let authorizedUser = authorizeCall(authUser: authUser)
            
            let queryItems = [URLQueryItem(name: "cognito_username", value: guest.cognito_username.uuidString), URLQueryItem(name: "party_code", value: host.party_code),URLQueryItem(name: "guest_name", value: guest.guest_name)]

            // Todo: store url somewhere?
            var urlComps = URLComponents(string: "https://sl83ejal53.execute-api.us-east-1.amazonaws.com/Prod")!
            urlComps.queryItems = queryItems
            
            // Todo: don't use force unwrap
            var request = URLRequest(url: urlComps.url!)
            request.httpMethod = "DELETE"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
                        
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                }
                else
                {
                    print("success deleting guest!")
                }
            }
            task.resume()
        } // End of function
        
//        func addFood(authUser: AuthUser, itemName: String, partyCode: String, status: String, completion: @escaping (String) -> Void)
//        {
//            let authorizedUser = authorizeCall(authUser: authUser)
//            
//            // Todo: store url somewhere?
//            let path = "https://nm1c3v9jc9.execute-api.us-east-1.amazonaws.com/Prod"
//            
//            // Todo: don't use force unwrap
//            var request = URLRequest(url: URL(string: path)!)
//            request.httpMethod = "POST"
//            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
//            
//            let foodToAdd = Food(
//                item_name: itemName,
//                party_code: partyCode,
//                status: status,
//                username: "cmvallattest",
//                cognito_username: authorizedUser.cognito_username)
//            
//            if let foodData = try? JSONEncoder().encode(foodToAdd){
//                request.httpBody = foodData
//            }
//            
//            // Todo: standardize error handling here and in other API calls
//            let task = URLSession.shared.dataTask(with: request){
//                if $2 != nil
//                {
//                    completion("Uh oh! Something went wrong")
//                }
//                else if let data = $0
//                {
//                    // decode to string because it won't return the added object, just a success or failure message
//                    if let decoded = try? JSONDecoder().decode(APIResponse<EmptyCodable>.self, from: data) {
//                        completion(decoded.message)
//                    } else {
//                        completion("Uh oh! Something went wrong")
//                    }
//                    
//                    // For debugging:
////                    print("---> data: \n \((String(data: data, encoding: .utf8) ?? "nil") as String) \n")
//                }
//                else
//                {
//                    completion("Uh oh! Something went wrong")
//                }
//            }
//            task.resume()
//        } //End of function
        
        func reportFood(authUser: AuthUser, itemName: String, partyCode: String, status: String)
        {
            let authorizedUser = authorizeCall(authUser: authUser)
            
            // Todo: store url somewhere?
            let path = "https://bj0fdfpzjb.execute-api.us-east-1.amazonaws.com/Prod"
            
            // Todo: don't use force unwrap
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = "PUT"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
            
            let foodToReport = Food(
                item_name: itemName,
                party_code: partyCode,
                status: status,
                username: authUser.username,
                cognito_username: authorizedUser.cognito_username)
            
            if let foodData = try? JSONEncoder().encode(foodToReport){
                request.httpBody = foodData
            }
            
            // Todo: standardize error handling here and in other API calls
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                }
                else if let data = $0
                {
                    let apiResponse = try? JSONDecoder().decode(ApiResponseFormat.self, from: data)
                    
                    print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                    
                    DispatchQueue.main.async{ [weak self] in
                        self?.reportFoodResponse = apiResponse?.body ?? "failed to decode"
                    }
                }
                else
                {
                    self.reportFoodResponse = "Something went wrong in addUser call"
                }
                print("response: " + self.reportFoodResponse)
            }
            task.resume()
        } //End of function
    }
}

#Preview {
//    HostManagementPage(host: hosts[0], demoFoodListFromApi: food, demoGuestListFromApi: guests, authUser: AuthUser())
//    HostManagementPage(host: hosts[0], authUser: AuthUser())
}
