public struct AftercareAndRecalls: Decodable, Equatable {
    public let aftercare: [AftercareTemplate]
    public let recalls: [AftercareTemplate]
}
