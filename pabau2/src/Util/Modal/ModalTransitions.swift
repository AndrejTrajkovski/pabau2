//
//  ModalTransitions.swift
//  CustomNavigations
//
//  Created by Fernando Moya de Rivas on 10/01/2020.
//  Copyright © 2020 Fernando Moya de Rivas. All rights reserved.
//

import SwiftUI

public enum ModalTransition: TransitionLinkType {
    case circleReveal
    case fullScreenModal
    case scale

    public var transition: AnyTransition {
        switch self {
        case .circleReveal:
            return AnyTransition.reveal(shape: ScalableCircle.self)
							.combined(with: AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
        case .fullScreenModal:
            return .move(edge: .bottom)
        case .scale:
            return .scale(scale: 0)
        }
    }
}
