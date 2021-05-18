//
//  AppointmentsAPI.swift
//  
//
//  Created by Yuriy Berdnikov on 02.02.2021.
//

import ComposableArchitecture

public protocol AppointmentsAPI {
    func getBookoutReasons() -> Effect<[BookoutReason], RequestError>
    func getAppointmentStatus() -> Effect<[AppointmentStatus], RequestError>
}
