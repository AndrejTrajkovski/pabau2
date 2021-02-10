//
//  File.swift
//  
//
//  Created by Yuriy Berdnikov on 10.02.2021.
//

import Foundation
import ComposableArchitecture

extension APIClient {
    public func createAppointment(appointment: AppointmentBody) -> Effect<PlaceholdeResponse, RequestError> {
        let requestBuilder: RequestBuilder<PlaceholdeResponse>.Type = requestBuilderFactory.getBuilder()
        let dateFormatter = DateFormatter.shortDateTime

        var params: [String : Any] = [
            "all_day": appointment.isAllDay ?? false,

            "instant_sms": appointment.smsNotification ?? false,
            "sent_sms": appointment.smsNotification ?? false,
            "sent_email": appointment.emailNotification ?? false,
            "sent_survey": appointment.surveyNotification ?? false,
            "status" : "Waiting",
            "start_time": dateFormatter.string(from: appointment.startTime ?? Date()),
        ]

        if (appointment.isAllDay ?? false) {
            params["end_date"] = dateFormatter.string(from: (appointment.startTime ?? Date()).addingTimeInterval((appointment.duration ?? 0) * 60))
        } else {
            params["end_date"] = dateFormatter.string(from: (appointment.startTime ?? Date()).addingTimeInterval((appointment.duration ?? 0) * 60))
        }

        if let clientID = appointment.clientID {
            params["contact_id"] = clientID
        }

        if let serviceID = appointment.serviceID {
            params["service_id"] = serviceID
        }

        if let note = appointment.note {
            params["note"] = note
        }

        if let employeeID = appointment.employeeID {
            params["uid"] = employeeID
        }

        return requestBuilder.init(method: .POST,
                                   baseUrl: baseUrl,
                                   path: .createAppointment,
                                   queryParams: commonAnd(other: params),
                                   isBody: true)
            .effect()
    }
}
