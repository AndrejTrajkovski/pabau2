import SwiftUI

extension Font {
//	static let headline1 = Font.system(size: 36.0,
//																		 weight: .bold,
//																		 design: .default)
	static let headline2 = Font.system(size: 24.0,
																		 weight: .semibold)
//	static let headline3 = Font.system(size: 18.0,
//																		 weight: .semibold,
//																		 design: .default)
	static let paragraph = Font.system(size: 16.0,
																		 weight: .medium)

	static let bigMediumFont = Font.system(size: 45,
																				 weight: .medium)

	static let bigSemibolFont = Font.system(size: 45,
																				 weight: .semibold)

	static let validation = Font.system(size: 12,
																			weight: .semibold)

	static let largeTitle = Font.init(UIFont.largeTitle)

	static let textStyle = Font.init(UIFont.textStyle)

	static let body17CenterSemibold = Font.init(UIFont.body17CenterSemibold)

	static let headlineBlack = Font.init(UIFont.headlineBlack)

	static let body17CenterRegular = Font.init(UIFont.body17CenterRegular)

	static let bodyBlack = Font.init(UIFont.bodyBlack)

	static let resetCodeWasSentStyle = Font.init(UIFont.resetCodeWasSentStyle)

	static let body15CenterRegular = Font.init(UIFont.body15CenterRegular)

	static let subheadBlack = Font.init(UIFont.subheadBlack)

	static let calendarMOnthNumber = Font.init(UIFont.calendarMOnthNumber)

	static let formFieldHeader = Font.init(UIFont.formFieldHeader)

	static let time = Font.init(UIFont.time)

	static let textFieldInTextAndTextField = Font.system(size: 15,
																											 weight: .medium)
	static let textInTextAndTextField = Font.system(size: 10, weight: .bold)

	static let thirteenBold = Font.system(size: 13, weight: .bold)
}

import UIKit

extension UIFont {

  class var largeTitle: UIFont {
    return UIFont.systemFont(ofSize: 34.0, weight: .bold)
  }

  class var textStyle: UIFont {
    return UIFont.systemFont(ofSize: 34.0, weight: .semibold)
  }

  class var body17CenterSemibold: UIFont {
    return UIFont.systemFont(ofSize: 17.0, weight: .semibold)
  }

  class var headlineBlack: UIFont {
    return UIFont.systemFont(ofSize: 17.0, weight: .semibold)
  }

  class var body17CenterRegular: UIFont {
    return UIFont.systemFont(ofSize: 17.0, weight: .regular)
  }

  class var bodyBlack: UIFont {
    return UIFont.systemFont(ofSize: 17.0, weight: .regular)
  }

  class var resetCodeWasSentStyle: UIFont {
    return UIFont.systemFont(ofSize: 16.0, weight: .medium)
  }

  class var body15CenterRegular: UIFont {
    return UIFont.systemFont(ofSize: 15.0, weight: .regular)
  }

  class var subheadBlack: UIFont {
    return UIFont.systemFont(ofSize: 15.0, weight: .regular)
  }

  class var calendarMOnthNumber: UIFont {
    return UIFont.systemFont(ofSize: 14.0, weight: .bold)
  }

  class var formFieldHeader: UIFont {
    return UIFont.systemFont(ofSize: 12.0, weight: .bold)
  }

  class var time: UIFont {
    return UIFont.systemFont(ofSize: 10.0, weight: .semibold)
  }

}
