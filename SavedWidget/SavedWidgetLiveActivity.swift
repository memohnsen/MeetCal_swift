//
//  SavedWidgetLiveActivity.swift
//  SavedWidget
//
//  Created by Maddisen Mohnsen on 10/5/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SavedWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SavedWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SavedWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SavedWidgetAttributes {
    fileprivate static var preview: SavedWidgetAttributes {
        SavedWidgetAttributes(name: "World")
    }
}

extension SavedWidgetAttributes.ContentState {
    fileprivate static var smiley: SavedWidgetAttributes.ContentState {
        SavedWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SavedWidgetAttributes.ContentState {
         SavedWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SavedWidgetAttributes.preview) {
   SavedWidgetLiveActivity()
} contentStates: {
    SavedWidgetAttributes.ContentState.smiley
    SavedWidgetAttributes.ContentState.starEyes
}
