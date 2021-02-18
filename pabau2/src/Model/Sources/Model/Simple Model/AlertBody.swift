import Foundation

public struct AlertBody: Equatable {
    public static func == (lhs: AlertBody, rhs: AlertBody) -> Bool {
        lhs.id == rhs.id
    }
    private let id = UUID()
    
    public var title: String
    public var subtitle: String
    public var primaryButtonTitle: String
    public var secondaryButtonTitle: String
    public var isShow: BooleanLiteralType
    
    public init(
        title: String = "",
        subtitle: String = "",
        primaryButtonTitle: String = "Ok",
        secondaryButtonTitle: String = "Cancel",
        isShow: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.isShow = isShow
    }
}
