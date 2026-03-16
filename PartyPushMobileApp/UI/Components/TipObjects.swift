//
//  TipObjects.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/4/25.
//

import SwiftUI
import TipKit

struct AddHostTip: Tip {
    @Parameter
    static var alreadyDiscovered : Bool = false
    
    var title: Text {
        Text("Add a New Host")
    }
    var message: Text? {
        Text("Tap here to create a new party for you to host.")
    }
    var image: Image? {
        Image(systemName: "plus.circle.fill")
    }
}

struct JoinPartyTip: Tip {
    var title: Text {
        Text("Join a Party")
    }
    var message: Text? {
        Text("Tap here to join an existing party as a guest using the code your host provided.")
    }
    var image: Image? {
        Image(systemName: "magnifyingglass.circle.fill")
    }
}

struct HelpTip: Tip {
    var title: Text {
        Text("Help walkthrough")
    }
    var message: Text? {
        Text("Tap here to bring up the help walkthrough at any time.")
    }
    var image: Image? {
        Image(systemName: "questionmark.circle.fill")
//            .foregroundStyle(.green)
    }
}

struct ReportFoodFromGuestTip: Tip {
    var title: Text {
        Text("Report Food Status")
    }
    var message: Text? {
        Text("Swipe left on an item to report it as low or out of stock. This will alert the party host.")
    }
}

struct ReportFoodFromHostTip: Tip {
    var title: Text {
        Text("Report Food Status")
    }
    var message: Text? {
        Text("Swipe left on an item to change it's status. This will alert all party guests.")
    }
}
