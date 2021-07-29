import Tagged

struct AftercareTemplate: Decodable {
    let id: Tagged<AftercareTemplate, String>
    let template_type: AftercareType
    let template_name: String
    let image: String
//    let
}

enum AftercareType: String, Decodable {
    case email
    case sms
}
