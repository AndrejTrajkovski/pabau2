import Foundation

public struct AppointmentBody {
    public let isAllDay: Bool?
    public let clientID: Int?
    public let employeeID: String?
    public let serviceID: String?

    public let startTime: Date?
    public let duration: TimeInterval?

    public let smsNotification: Bool?
    public let emailNotification: Bool?
    public let surveyNotification: Bool?
    public let reminderNotification: Bool?

    public let note: String?

    public init(isAllDay: Bool? = nil,
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
