import ComposableArchitecture

public struct JourneyLiveAPI: JourneyAPI, LiveAPI {
	public let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
	public var basePath: String = ""
	public let route: String = "journeys"

	public func getJourneys(date: Date) -> Effect<Result<[Journey], RequestError>> {
		getJourneys(date: date).effect()
	}

	//    open class func journeyAppointmentPost(body: AppointmentBody? = nil, completion: @escaping ((_ data: Journey?,_ error: Error?) -> Void)) {
	//        journeyAppointmentPostWithRequestBuilder(body: body).execute { (response, error) -> Void in
	//            completion(response?.body, error)
	//        }
	//    }

	//    open class func journeyAppointmentPostWithRequestBuilder(body: AppointmentBody? = nil) -> RequestBuilder<Journey> {
	//        let path = "/journey/appointment"
	//        let URLString = SwaggerClientAPI.basePath + path
	//        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
	//
	//        let url = URLComponents(string: URLString)
	//
	//        let requestBuilder: RequestBuilder<Journey>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
	//
	//        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
	//    }

	/**
	Update an existing Appointment in a Journey.
	- parameter body: (body)  (optional)
	- parameter completion: completion handler to receive the data and the error objects
	*/
	//    open class func journeyAppointmentPut(body: Body3? = nil, completion: @escaping ((_ data: Journey?,_ error: Error?) -> Void)) {
	//        journeyAppointmentPutWithRequestBuilder(body: body).execute { (response, error) -> Void in
	//            completion(response?.body, error)
	//        }
	//    }
	//
	//    open class func journeyAppointmentPutWithRequestBuilder(body: Body3? = nil) -> RequestBuilder<Journey> {
	//        let path = "/journey/appointment"
	//        let URLString = SwaggerClientAPI.basePath + path
	//        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
	//
	//        let url = URLComponents(string: URLString)
	//
	//        let requestBuilder: RequestBuilder<Journey>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
	//
	//        return requestBuilder.init(method: "PUT", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
	//    }
	//
	//    /**
	//     Unlink a form template object from a journey.
	//     - parameter formTemplateId: (path) The id of the form that needs to be deleted
	//     - parameter completion: completion handler to receive the data and the error objects
	//     */
	//    open class func journeyFormTemplatesDelete(formTemplateId: String, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
	//        journeyFormTemplatesDeleteWithRequestBuilder(formTemplateId: formTemplateId).execute { (response, error) -> Void in
	//            if error == nil {
	//                completion((), error)
	//            } else {
	//                completion(nil, error)
	//            }
	//        }
	//    }
	//
	//    open class func journeyFormTemplatesDeleteWithRequestBuilder(formTemplateId: String) -> RequestBuilder<Void> {
	//        var path = "/journey/form_templates"
	//        let formTemplateIdPreEscape = "\(formTemplateId)"
	//        let formTemplateIdPostEscape = formTemplateIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
	//        path = path.replacingOccurrences(of: "{form_template_id}", with: formTemplateIdPostEscape, options: .literal, range: nil)
	//        let URLString = SwaggerClientAPI.basePath + path
	//        let parameters: [String:Any]? = nil
	//
	//        let url = URLComponents(string: URLString)
	//
	//        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()
	//
	//        return requestBuilder.init(method: "DELETE", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	//    }
	//
	//    /**
	//     In this request sent are an array of form_template_ids that were chosen for a step in the journey.
	//     - parameter body: (body)  (optional)
	//     - parameter completion: completion handler to receive the data and the error objects
	//     */
	//    open class func journeyFormTemplatesPost(body: Body1? = nil, completion: @escaping ((_ data: Journey?,_ error: Error?) -> Void)) {
	//        journeyFormTemplatesPostWithRequestBuilder(body: body).execute { (response, error) -> Void in
	//            completion(response?.body, error)
	//        }
	//    }
	//
	//    open class func journeyFormTemplatesPostWithRequestBuilder(body: Body1? = nil) -> RequestBuilder<Journey> {
	//        let path = "/journey/form_templates"
	//        let URLString = SwaggerClientAPI.basePath + path
	//        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
	//
	//        let url = URLComponents(string: URLString)
	//
	//        let requestBuilder: RequestBuilder<Journey>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
	//
	//        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
	//    }
	//
	//    /**
	//     Get a journey by ID.
	//     - parameter _id: (query) ID of the journey.
	//     - parameter completion: completion handler to receive the data and the error objects
	//     */
	//    open class func journeyGet(_id: Int, completion: @escaping ((_ data: Journey?,_ error: Error?) -> Void)) {
	//        journeyGetWithRequestBuilder(_id: _id).execute { (response, error) -> Void in
	//            completion(response?.body, error)
	//        }
	//    }
	//
	//    open class func journeyGetWithRequestBuilder(_id: Int) -> RequestBuilder<Journey> {
	//        let path = "/journey"
	//        let URLString = SwaggerClientAPI.basePath + path
	//        let parameters: [String:Any]? = nil
	//        var url = URLComponents(string: URLString)
	//        url?.queryItems = APIHelper.mapValuesToQueryItems([
	//                        "id": _id.encodeToJSON()
	//        ])
	//
	//        let requestBuilder: RequestBuilder<Journey>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
	//
	//        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	//    }
	//
	//    /**
	//     Link journey to a pathway.
	//     - parameter body: (body)  (optional)
	//     - parameter completion: completion handler to receive the data and the error objects
	//     */
	//    open class func journeyPathwayPost(body: Body2? = nil, completion: @escaping ((_ data: Journey?,_ error: Error?) -> Void)) {
	//        journeyPathwayPostWithRequestBuilder(body: body).execute { (response, error) -> Void in
	//            completion(response?.body, error)
	//        }
	//    }
	//
	//    open class func journeyPathwayPostWithRequestBuilder(body: Body2? = nil) -> RequestBuilder<Journey> {
	//        let path = "/journey/pathway"
	//        let URLString = SwaggerClientAPI.basePath + path
	//        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
	//
	//        let url = URLComponents(string: URLString)
	//
	//        let requestBuilder: RequestBuilder<Journey>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
	//
	//        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
	//    }
	//
	//    /**
	//     Update a Journey's patient_checked value.
	//     - parameter body: (body)  (optional)
	//     - parameter completion: completion handler to receive the data and the error objects
	//     */
	//    open class func journeyPatientCheckedPost(body: Body? = nil, completion: @escaping ((_ data: Journey?,_ error: Error?) -> Void)) {
	//        journeyPatientCheckedPostWithRequestBuilder(body: body).execute { (response, error) -> Void in
	//            completion(response?.body, error)
	//        }
	//    }
	//
	//    open class func journeyPatientCheckedPostWithRequestBuilder(body: Body? = nil) -> RequestBuilder<Journey> {
	//        let path = "/journey/patient_checked"
	//        let URLString = SwaggerClientAPI.basePath + path
	//        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
	//
	//        let url = URLComponents(string: URLString)
	//
	//        let requestBuilder: RequestBuilder<Journey>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()
	//
	//        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
	//    }
	//
	//    /**
	//     Get all journeys for a specific date.
	//     - parameter date: (query) Date to query journeys by.
	//     - parameter completion: completion handler to receive the data and the error objects
	//     */
	//    open class func journeysGet(date: Date, completion: @escaping ((_ data: [Journey]?,_ error: Error?) -> Void)) {
	//        journeysGetWithRequestBuilder(date: date).execute { (response, error) -> Void in
	//            completion(response?.body, error)
	//        }
	//    }
	//

	/**
	Get all journeys for a specific date.
	- GET /journeys
	- parameter date: (query) Date to query journeys by.
	
	- returns: RequestBuilder<[Journey]>
	*/

	private func getJourneys(date: Date) -> RequestBuilder<[Journey]> {
		let URLString = basePath + route + "journeys"
		let parameters: [String: Any]? = nil
		var url = URLComponents(string: URLString)
		url?.queryItems = APIHelper.mapValuesToQueryItems([
			"date": try? newJSONEncoder().encode(date)
		])

		let requestBuilder: RequestBuilder<[Journey]>.Type = requestBuilderFactory.getBuilder()

		return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	}
}
