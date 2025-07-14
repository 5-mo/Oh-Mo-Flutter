//
//  TodayWidgetExtensionBundle.swift
//  TodayWidgetExtension
//
//  Created by 이유진 on 7/13/25.
//

import WidgetKit
import SwiftUI

@main
struct TodayWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        TodayWidgetExtension()
        TodayWidgetExtensionControl()
        TodayWidgetExtensionLiveActivity()
    }
}
