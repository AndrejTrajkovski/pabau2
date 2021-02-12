//
//  File.swift
//  
//
//  Created by Yuriy Berdnikov on 02.02.2021.
//

import Foundation
import ComposableArchitecture
import Combine

//MARK: - LoginAPI: Appointments
extension APIClient: AppointmentsAPI {
    public func getBookoutReasons() -> Effect<[BookoutReason], RequestError> {
        let requestBuilder: RequestBuilder<[BookoutReason]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getBookoutReasons,
                                   queryParams: commonParams(),
                                   isBody: false)
            .effect()
    }
}
