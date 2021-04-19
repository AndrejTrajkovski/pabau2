import Foundation

public struct AppointmentBuilder {
    public var appointmentID: Appointment.ID?

    public var isAllDay: Bool?
    public var isPrivate: Bool?
	public var clientID: Client.Id?
    public var locationID: Location.Id?
    public var employeeID: String?
    public var serviceID: String?

    public var startTime: Date?
    public var duration: TimeInterval? //in minutes

    public var smsNotification: Bool?
    public var emailNotification: Bool?
    public var surveyNotification: Bool?
    public var reminderNotification: Bool?

    public var note: String?
    public var description: String?
    public var participantUserIDS: [Int]?
    

    public init(
        isAllDay: Bool? = nil,
        isPrivate: Bool? = nil,
        clientID: Client.Id? = nil,
        locationID: Location.Id? = nil,
        employeeID: String? = nil,
        serviceID: String? = nil,
        startTime: Date? = nil,
        duration: TimeInterval? = nil,
        smsNotification: Bool? = nil,
        emailNotification: Bool? = nil,
        surveyNotification: Bool? = nil,
        reminderNotification: Bool? = nil,
        note: String? = nil,
        participantUserIDS: [Int]? = nil,
        description: String? = nil
    ) {
        self.isAllDay = isAllDay
        self.isPrivate = isPrivate
        self.locationID = locationID
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
        self.participantUserIDS = participantUserIDS
        self.description = description
    }

    public init(appointment: Appointment) {
        #warning("Fix all day value")
        self.appointmentID = appointment.id
        self.isAllDay = appointment.all_day
        self.isPrivate = appointment._private
        self.employeeID = appointment.employeeId.rawValue
        self.locationID = appointment.locationId
        self.serviceID = appointment.serviceId.rawValue
        self.clientID = appointment.customerId
		self.serviceID = String(appointment.service)
        self.startTime = appointment.start_date
        self.duration = appointment.end_date.timeIntervalSince(appointment.start_date) / 60
    }
    
    public init(bookout: Bookout) {
        self.appointmentID = bookout.id
        self.isAllDay = bookout.all_day
        self.isPrivate = bookout._private
        self.employeeID = bookout.employeeId.rawValue
        self.locationID = bookout.locationId
        self.startTime = bookout.start_date
        self.duration = bookout.end_date.timeIntervalSince(bookout.start_date) / 60
    }
}
