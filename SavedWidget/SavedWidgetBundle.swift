//
//  SavedWidgetBundle.swift
//  SavedWidget
//
//  Created by Maddisen Mohnsen on 10/5/25.
//

import WidgetKit
import SwiftUI

@main
struct SavedWidgetBundle: WidgetBundle {
    var body: some Widget {
        SavedWidget()
        SavedWidgetLiveActivity()
    }
}
