//
//  File.swift
//  
//
//  Created by Yuriy Berdnikov on 10.02.2021.
//

import Foundation
import ComposableArchitecture

extension APIClient {
    public func createAppointment(appointment: AppointmentBuilder) -> Effect<PlaceholdeResponse, RequestError> {
        let requestBuilder: RequestBuilder<PlaceholdeResponse>.Type = requestBuilderFactory.getBuilder()

        var params: [String : Any] = [
            "all_day": appointment.isAllDay ?? false,
            "private": appointment.isPrivate ?? false,
            "instant_sms": appointment.smsNotification ?? false,
            "sent_sms": appointment.smsNotification ?? false,
            "sent_email": appointment.emailNotification ?? false,
            "sent_survey": appointment.surveyNotification ?? false,
            "status" : "Waiting",
        ]

        if let startTime = appointment.startTime {
            if (appointment.isAllDay ?? false) {
                params["start_time"] = startTime.getFormattedDate(format: "dd-MM-yyyy")
                params["end_time"] = startTime.getFormattedDate(format: "dd-MM-yyyy")
            } else {
                params["start_time"] = startTime.getFormattedDate(format: "dd-MM-yyyy HH:mm")
                let duration = (appointment.duration ?? 0) * 60 //seconds
                var endTime = startTime
                endTime.addTimeInterval(duration)
                params["end_time"] = endTime.getFormattedDate(format: "dd-MM-yyyy HH:mm")
            }
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
        
        if let description = appointment.description {
            params["description"] = description
        }

        if let employeeID = appointment.employeeID {
            params["uid"] = employeeID
        }
        
        if let appointmentID = appointment.appointmentID {
            params["appointment_id"] = appointmentID
        }
        
        if let participantUserIDS = appointment.participantUserIDS {
            params["participant_user_ids"] = participantUserIDS
        }
    
        return requestBuilder.init(
            method: .POST,
            baseUrl: baseUrl,
            path: .createAppointment,
            queryParams: commonAnd(other: params),
            isBody: true
        )
            .effect()
    }
}
