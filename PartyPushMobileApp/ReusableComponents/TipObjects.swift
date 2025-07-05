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
        Text("Tap here to add a new host to your party.")
    }
    var rules: [Rule] {[
        #Rule(Self.$alreadyDiscovered) { $0 == false }
    ]}
}

struct JoinPartyTip: Tip {
    var title: Text {
        Text("Join a Party")
    }
    var message: Text? {
        Text("Tap here to join an existing party using a code.")
    }
}

struct ReportFoodLowTip: Tip {
    var title: Text {
        Text("Report Food Status")
    }
    var message: Text? {
        Text("Swipe left on an item to report it as low or out of stock.")
    }
}
