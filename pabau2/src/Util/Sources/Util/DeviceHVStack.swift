//
//  DeviceHVStack.swift
//  
//
//  Created by Perpetio on 22.06.2021.
//

import SwiftUI
import Combine

public struct DeviceHVStack<Content: View>: View {
    let content: Content
    
    let vspacing: CGFloat
    let hspacing: CGFloat
    
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment

    public init(
        vspacing: CGFloat = Constants.isPad ? 24 : 5.0,
        hspacing: CGFloat = Constants.isPad ? 24 : 5.0,
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.vspacing = vspacing
        self.hspacing = hspacing
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
    }

    public var body: some View {
        if Constants.isPad {
            HStack(alignment: verticalAlignment, spacing: hspacing) {
                content
            }
        } else {
            VStack(alignment: horizontalAlignment, spacing: vspacing) {
                content
            }
        }
    }
}
