//
//  File.swift
//  
//
//  Created by Yuriy Berdnikov on 02.02.2021.
//

import Foundation
import ComposableArchitecture
import Combine

////MARK: - APIClient: Appointments
extension APIClient: AppointmentsAPI {
    public func getBookoutReasons() -> Effect<[BookoutReason], RequestError> {
        struct BookoutReasonResponse: Decodable {
            let employees: [BookoutReason]
        }
        let requestBuilder: RequestBuilder<BookoutReasonResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getBookoutReasons,
            queryParams: commonParams()
        )
        .effect()
        .map(\.employees)
    }
    
}
