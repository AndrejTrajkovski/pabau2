import Foundation

public struct AppointmentBuilder {
    public var appointmentID: Appointment.Id?

    public var isAllDay: Bool?
    public var clientID: Int?
    public var employeeID: String?
    public var serviceID: String?

    public var startTime: Date?
    public var duration: TimeInterval? //in minutes

    public var smsNotification: Bool?
    public var emailNotification: Bool?
    public var surveyNotification: Bool?
    public var reminderNotification: Bool?

    public var note: String?

    public init(
        isAllDay: Bool? = nil,
        clientID: Int? = nil,
        employeeID: String? = nil,
        serviceID: String? = nil,
        startTime: Date? = nil,
        duration: TimeInterval? = nil,
        smsNotification: Bool? = nil,
        emailNotification: Bool? = nil,
        surveyNotification: Bool? = nil,
        reminderNotification: Bool? = nil,
        note: String? = nil
    ) {
        self.isAllDay = isAllDay
        self.clientID = clientID
        self.employeeID = employeeID
        self.serviceID = serviceID
        self.startTime = startTime
        self.duration = duration
        self.smsNotification = smsNotification
        self.emailNotification = emailNotification
        self.surveyNotification = surveyNotification
        self.reminderNotification = reminderNotification
        self.note = note
    }

    public init(appointment: Appointment) {

        self.appointmentID = appointment.id
        #warning("Fix all day value")
        self.isAllDay = false

        self.employeeID = appointment.employeeId.rawValue

        if let id = appointment.service?.id {
            self.serviceID = String(id)
        }

        self.startTime = appointment.start_time
        self.duration = appointment.end_time.timeIntervalSince(appointment.start_time) / 60
    }
}


//all_day    0
//contact_id    12148213
//end_time    10-02-2021 14:45
//equipment_id
//instant_sms    1
//insurance_company_id    11509
//insurance_contract_id
//location_id    2668
//membership_number
//room_id    5578
//sent_email    0
//sent_sms    1
//sent_survey    1
//service_id    2407704
//start_time    10-02-2021 14:00
//status    Waiting
//uid    76101
