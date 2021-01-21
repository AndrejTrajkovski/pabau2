import SwiftUI
#if !os(macOS)
public extension Font {
	static let semibold24 = Font.system(size: 24.0, weight: .semibold)
	static let semibold11 = Font.system(size: 11, weight: .semibold)
	static let semibold14 = Font.system(size: 14, weight: .semibold)
	static let semibold45 = Font.system(size: 45, weight: .semibold)
	static let semibold12 = Font.system(size: 12, weight: .semibold)
	static let semibold10 = Font.system(size: 10, weight: .semibold)
	static let semibold20 = Font.system(size: 20, weight: .semibold)
	static let semibold15 = Font.system(size: 15, weight: .semibold)
    static let semibold16 = Font.system(size: 16, weight: .semibold)
	static let semibold17 = Font.system(size: 17, weight: .semibold)
    static let semibold18 = Font.system(size: 18, weight: .semibold)
	static let semibold22 = Font.system(size: 22, weight: .semibold)

	static let medium10 = Font.system(size: 10, weight: .medium)
	static let medium9 = Font.system(size: 9, weight: .medium)
    static let medium12 = Font.system(size: 12.0, weight: .medium)
	static let medium14 = Font.system(size: 14.0, weight: .medium)
	static let medium15 = Font.system(size: 15.0, weight: .medium)
	static let medium16 = Font.system(size: 16.0, weight: .medium)
	static let medium17 = Font.system(size: 17.0, weight: .medium)
	static let medium18 = Font.system(size: 18.0, weight: .medium)
	static let medium45 = Font.system(size: 45, weight: .medium)
	static let medium24 = Font.system(size: 24.0, weight: .medium)
	static let medium38 = Font.system(size: 38.0, weight: .medium)
	static let medium25 = Font.system(size: 25.0, weight: .medium)

	static let bold34 = Font.system(size: 34, weight: .bold)
	static let bold14 = Font.system(size: 14, weight: .bold)
	static let bold12 = Font.system(size: 12, weight: .bold)
	static let bold10 = Font.system(size: 10, weight: .bold)
	static let bold8 = Font.system(size: 8, weight: .bold)
	static let bold13 = Font.system(size: 13, weight: .bold)
	static let bold16 = Font.system(size: 16, weight: .bold)
	static let bold17 = Font.system(size: 17, weight: .bold)
	static let bold18 = Font.system(size: 18, weight: .bold)
	static let bold24 = Font.system(size: 24, weight: .bold)

	static let regular13 = Font.system(size: 13, weight: .regular)
	static let regular14 = Font.system(size: 14, weight: .regular)
	static let regular12 = Font.system(size: 12, weight: .regular)
	static let regular15 = Font.system(size: 15, weight: .regular)
	static let regular16 = Font.system(size: 16, weight: .regular)
	static let regular17 = Font.system(size: 17, weight: .regular)
	static let regular30 = Font.system(size: 30, weight: .regular)
    static let regular32 = Font.system(size: 30, weight: .regular)
	static let regular18 = Font.system(size: 18, weight: .regular)
	static let regular20 = Font.system(size: 20, weight: .regular)
	static let regular45 = Font.system(size: 45, weight: .regular)
	static let regular90 = Font.system(size: 90, weight: .regular)
	static let regular24 = Font.system(size: 24, weight: .regular)
	static let regular100 = Font.system(size: 100, weight: .regular)
	static let regular36 = Font.system(size: 36, weight: .regular)

	static let light30 = Font.system(size: 30, weight: .light)
}
#endif

public extension Font {
    static func proSemibold(size: CGFloat) -> Font {
        return Font.custom("SFProText-Semibold", size: size)
    }

    static func proMediumItalic(size: CGFloat) -> Font {
        return Font.custom("SFProText-MediumItalic", size: size)
    }

    static func proMedium(size: CGFloat) -> Font {
        return Font.custom("SFProText-Medium", size: size)
    }

    static func proRegular(size: CGFloat) -> Font {
        return Font.custom("SFProText-Regular", size: size)
    }
}
