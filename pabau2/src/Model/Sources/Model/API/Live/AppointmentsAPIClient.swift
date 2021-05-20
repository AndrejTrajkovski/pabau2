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
            "all_day": (appointment.isAllDay ?? false) ? 1 : 0,
            "private": (appointment.isPrivate ?? false) ? 1 : 0,
            "instant_sms": (appointment.smsNotification ?? false) ? 1 : 0,
            "sent_sms": (appointment.smsNotification ?? false) ? 1 : 0,
            "sent_email": (appointment.emailNotification ?? false) ? 1 : 0,
            "sent_survey": (appointment.surveyNotification ?? false) ? 1 : 0,
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
        
        if let locationID = appointment.locationID {
            params["location_id"] = locationID
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
    
        print(params as NSDictionary)
        return requestBuilder.init(
            method: .POST,
            baseUrl: baseUrl,
            path: .createAppointment,
            queryParams: commonAnd(other: params)
        )
            .effect()
    }
    
    public func updateAppointment(appointment: AppointmentBuilder) -> Effect<PlaceholdeResponse, RequestError> {
        let requestBuilder: RequestBuilder<PlaceholdeResponse>.Type = requestBuilderFactory.getBuilder()
        
        var params: [String : Any] = [:]
        
        if let appointmentID = appointment.appointmentID {
            params["appointment_id"] = appointmentID
        }
        
        if let employeeID = appointment.employeeID {
            params["uid"] = employeeID
        }
        
        if let startTime = appointment.startTime {
            params["start_time"] = startTime.getFormattedDate(format: "dd-MM-yyyy HH:mm")
            let duration = (appointment.duration ?? 0) * 60 //seconds
            var endTime = startTime
            endTime.addTimeInterval(duration)
            params["end_time"] = endTime.getFormattedDate(format: "dd-MM-yyyy HH:mm")
        }
        
        print(params as NSDictionary)
        return requestBuilder.init(
            method: .POST,
            baseUrl: baseUrl,
            path: .createAppointment,
            queryParams: commonAnd(other: params)
        )
        .effect()
    }
    
    public func appointmentChangeStatus(appointmentId: Appointment.ID, status: String) -> Effect<Bool, RequestError> {
        struct AppointmentChangeStatusResponse: Decodable {
            let success: Bool
        }
        var params: [String: Any] = [:]
        params["data"] = status
        params["change_by_id"] = self.loggedInUser?.userID
        params["appointment_id"] = appointmentId
        
        let requestBuilder: RequestBuilder<AppointmentChangeStatusResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .appointmentChangeStatus,
            queryParams: commonAnd(other: params)
        )
        .effect()
        .map(\.success)
    }
    
    public func appointmentChangeCancelReason(appointmentId: Appointment.ID, reason: String) -> Effect<Bool, RequestError> {
        struct AppointmentChangeStatusResponse: Decodable {
            let success: Bool
        }
        var params: [String: Any] = [:]
        params["data"] = "Cancelled"
        params["cancelReason"] = reason
        params["change_by_id"] = self.loggedInUser?.userID
        params["appointment_id"] = appointmentId
        
        let requestBuilder: RequestBuilder<AppointmentChangeStatusResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .appointmentChangeStatus,
            queryParams: commonAnd(other: params)
        )
        .effect()
        .map(\.success)
    }
    
    public func getAppointmentCancelReasons() -> Effect<[CancelReason], RequestError> {
        struct CancelReasonResponse: Decodable {
            let employees: [CancelReason]
        }
        
        let requestBuilder: RequestBuilder<CancelReasonResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getAppointmentCancelReason,
            queryParams: commonParams()
        )
        .effect()
        .map(\.employees)
    }
    
    public func createRecurringAppointment(appointmentId: Appointment.ID, repeatRange: Int, repeatNumber: Int, repeatUntil: Date) -> Effect<Bool, RequestError> {
        struct AppointmentRecurringResponse: Decodable {
            let success: Bool
        }
        var params: [String: Any] = [:]
        params["appointment_id"] = appointmentId
        params["repeat_range"] = "month"
        params["repeat_number"] = 1
        params["repeat_until"] = "24-05-2021"
        
        let requestBuilder: RequestBuilder<AppointmentRecurringResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .createRecurringAppointment,
            queryParams: commonAnd(other: params)
        )
        .effect()
        .map(\.success)
    }
    
    
}
