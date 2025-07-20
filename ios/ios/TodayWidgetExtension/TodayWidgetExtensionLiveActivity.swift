//
//  TodayWidgetExtensionLiveActivity.swift
//  TodayWidgetExtension
//
//  Created by 이유진 on 7/20/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TodayWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TodayWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TodayWidgetExtensionAttributes.self) { context in
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

extension TodayWidgetExtensionAttributes {
    fileprivate static var preview: TodayWidgetExtensionAttributes {
        TodayWidgetExtensionAttributes(name: "World")
    }
}

extension TodayWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: TodayWidgetExtensionAttributes.ContentState {
        TodayWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TodayWidgetExtensionAttributes.ContentState {
         TodayWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TodayWidgetExtensionAttributes.preview) {
   TodayWidgetExtensionLiveActivity()
} contentStates: {
    TodayWidgetExtensionAttributes.ContentState.smiley
    TodayWidgetExtensionAttributes.ContentState.starEyes
}
