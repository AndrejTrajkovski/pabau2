//
//  APIClient+JourneyAPI.swift
//  
//
//  Created by Yuriy Berdnikov on 29.01.2021.
//

import Foundation
import ComposableArchitecture
import Combine

//MARK: - JourneyAPI
extension APIClient: JourneyAPI, MockAPI {

    public func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError> {
        switch type {
        case .consent:
            return mockSuccess(FormTemplate.mockConsents, delay: 0.1)
        case .treatment:
            return mockSuccess(FormTemplate.mockTreatmentN, delay: 0.1)
        default:
            fatalError("TODO")
        }
    }

    public func getJourneys(date: Date, searchTerm: String?) -> Effect<[Journey], RequestError> {
        var queryItems: [String: Any] = [
            "date": DateFormatter.yearMonthDay.string(from: date)
        ]

        if let searchTerm = searchTerm {
            queryItems["searchTerm"] = searchTerm
        }

        let requestBuilder: RequestBuilder<[Journey]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getJourneys,
                                   queryParams: commonAnd(other: queryItems),
                                   isBody: false)
            .effect()
    }

    public func getServices() -> Effect<[Service], RequestError> {
        let queryItems: [String: Any] = [
            "company_id": 1,
            "employee_id": 1
        ]

        let requestBuilder: RequestBuilder<[Service]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getServices,
                                   queryParams: commonAnd(other: queryItems),
                                   isBody: false)
            .effect()
    }

    public func getEmployees() -> Effect<[Employee], RequestError> {
        let queryItems: [String: Any] = [
            "company_id": 1
        ]

        let requestBuilder: RequestBuilder<[Employee]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getEmployees,
                                   queryParams: commonAnd(other: queryItems),
                                   isBody: false)
            .effect()
    }
}

