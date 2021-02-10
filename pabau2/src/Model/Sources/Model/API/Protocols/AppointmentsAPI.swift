
import ComposableArchitecture

public protocol AppointmentsAPI {
    func getBookoutReasons() -> Effect<[BookoutReason], RequestError>
}
