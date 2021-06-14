import UIKit

public struct Constants {
    public static let screenHeight = UIScreen.main.bounds.height
    public static let screenWidth = UIScreen.main.bounds.width


    public static var isPad: Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return true
        default:
            return false
        }
    }

      public static var statusBarHeight: CGFloat = {
        var heightToReturn: CGFloat = 0.0
        for window in UIApplication.shared.windows {
            if let height = window.windowScene?.statusBarManager?.statusBarFrame.height, height > heightToReturn {
                heightToReturn = height
            }
        }
        return heightToReturn
    }()
}
