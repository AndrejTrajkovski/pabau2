public struct AftercareAndRecalls: Decodable, Equatable {
    let aftercare: [AftercareTemplate]
    let recalls: [AftercareTemplate]
}
