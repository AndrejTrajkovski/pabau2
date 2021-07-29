import Tagged

public struct AftercareTemplate: Identifiable, Decodable, Equatable {
    public let id: Tagged<AftercareTemplate, String>
    public let template_type: AftercareType
    public let template_name: String
    public let image: String
}

public enum AftercareType: String, Decodable {
    case email
    case sms
}
