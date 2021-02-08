import Foundation

public struct AppointmentResponse: Codable, Equatable, ResponseStatus {
    public var success: Bool
    public var message: String?
    
    public var appointments: [Appointment] = []

}
