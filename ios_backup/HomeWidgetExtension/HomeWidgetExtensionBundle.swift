//
//  HomeWidgetExtensionBundle.swift
//  HomeWidgetExtension
//
//  Created by 이유진 on 7/3/25.
//

import WidgetKit
import SwiftUI

@main
struct HomeWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        HomeWidgetExtension()
        HomeWidgetExtensionControl()
        HomeWidgetExtensionLiveActivity()
    }
}
