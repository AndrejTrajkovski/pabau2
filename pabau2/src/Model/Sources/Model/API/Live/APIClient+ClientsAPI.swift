//
//  APIClient+ClientsAPI.swift
//  
//
//  Created by Yuriy Berdnikov on 29.01.2021.
//

import Foundation
import ComposableArchitecture
import Combine

//MARK: - LoginAPI: ClientApi
extension APIClient: ClientsAPI {
    public func getClients(search: String? = nil, offset: Int) -> Effect<[Client], RequestError> {
        var queryItems: [String: Any] = ["limit": 20, "offset": offset]

        if let search = search {
            queryItems["search"] = search
        }

        let requestBuilder: RequestBuilder<[Client]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: commonAnd(other: queryItems),
                                   isBody: false)
            .effect()
    }

    public func getItemsCount(clientId: Int) -> Effect<ClientItemsCount, RequestError> {
        let requestBuilder: RequestBuilder<ClientItemsCount>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getAppointments(clientId: Int) -> Effect<[Appointment], RequestError> {
        let requestBuilder: RequestBuilder<[Appointment]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getPhotos(clientId: Int) -> Effect<[SavedPhoto], RequestError> {
        let requestBuilder: RequestBuilder<[SavedPhoto]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getFinancials(clientId: Int) -> Effect<[Financial], RequestError> {
        let requestBuilder: RequestBuilder<[Financial]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getForms(type: FormType, clientId: Int) -> Effect<[FormData], RequestError> {
        let requestBuilder: RequestBuilder<[FormData]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getDocuments(clientId: Int) -> Effect<[Document], RequestError> {
        let requestBuilder: RequestBuilder<[Document]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getCommunications(clientId: Int) -> Effect<[Communication], RequestError> {
        let requestBuilder: RequestBuilder<[Communication]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getAlerts(clientId: Int) -> Effect<[Alert], RequestError> {
        let requestBuilder: RequestBuilder<[Alert]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getNotes(clientId: Int) -> Effect<[Note], RequestError> {
        let requestBuilder: RequestBuilder<[Note]>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func getPatientDetails(clientId: Int) -> Effect<PatientDetails, RequestError> {
        let requestBuilder: RequestBuilder<PatientDetails>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }

    public func post(patDetails: PatientDetails) -> Effect<PatientDetails, RequestError> {
        let requestBuilder: RequestBuilder<PatientDetails>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .POST,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: nil,
                                   isBody: false)
            .effect()
    }
}
