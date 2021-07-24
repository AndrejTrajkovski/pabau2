import ComposableArchitecture
import Combine
//FormAPI
public extension APIClient {
	
    func skipStep(_ pathwayStep: PathwayIdStepId, _ clientId: Client.ID, _ appointmentId: Appointment.ID) -> Effect<StepStatus, RequestError> {
        
        struct Response: Decodable {
            let status: StepStatus
        }
        
        let queryParams: [String : Any] = [
            "pathway_taken_id": pathwayStep.path_taken_id.description,
            "step_id": pathwayStep.step_id.description,
            "contact_id": clientId.description,
            "booking_id": appointmentId.description
        ]
        
        let requestBuilder: RequestBuilder<Response>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .POST,
                                   baseUrl: baseUrl,
                                   path: .skipStep,
                                   queryParams: commonAnd(other: queryParams)
        )
        .effect()
        .map(\.status)
        .eraseToEffect()
    }
    
	func save(form: HTMLForm, clientId: Client.ID, pathwayStep: PathwayIdStepId?) -> Effect<FilledFormData.ID, RequestError> {
		struct Response: Codable {
			let medical_form_contact_id: FilledFormData.ID
		}
		var body: [String : Any] = [
			"mode": "save",
			"contact_id": clientId.description,
			"form_id": form.id.rawValue,
			"form_data": form.getJSONPOSTValues()
        ]
        merge(&body, with: pathwayStep)
		let requestBuilder: RequestBuilder<Response>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .POST,
								   baseUrl: baseUrl,
								   path: .medicalForms,
								   queryParams: commonParams(),
								   body: bodyData(parameters: body)
		)
		.effect()
		.map(\.medical_form_contact_id)
//		return Effect.init(error: RequestError.apiError("SOME API ERROR"))
//			.debounce(id: UUID(), for: 5.0, scheduler: DispatchQueue.main)
	}
	
	func getForm(templateId: FormTemplateInfo.ID,
				 entryId: FilledFormData.ID?) -> Effect<HTMLForm, RequestError> {
		if let entryId = entryId {
			return getForm(templateId: templateId, entryId: entryId)
		} else {
			return getForm(templateId: templateId)
		}
	}
	
	func getForm(templateId: FormTemplateInfo.ID,
				 entryId: FilledFormData.ID) -> Effect<HTMLForm, RequestError> {
		
		let params = commonAnd(other: ["form_template_id": templateId.rawValue,
									   "form_id": entryId.rawValue])
		
		let requestBuilder: RequestBuilder<_FilledForm>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getFormTemplateData,
								   queryParams: params
		)
			.effect()
			.tryMap(HTMLFormBuilder.init(formEntry:))
			.eraseToEffect()
			.map(HTMLForm.init(builder:))
			.mapError { error in
				print("form error \(error)")
				if let formError = error as? HTMLFormBuilderError {
					return RequestError.jsonDecoding(formError.description)
				} else {
					return error as? RequestError ?? .unknown(error)
				}
			}
			.eraseToEffect()
	}
	
	func getForm(templateId: FormTemplateInfo.ID) -> Effect<HTMLForm, RequestError> {
		struct GetTemplate: Codable {
			let form_template: [_FormTemplate]
		}
		let requestBuilder: RequestBuilder<GetTemplate>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getFormTemplateData,
								   queryParams: commonAnd(other: ["form_template_id": templateId.rawValue])
		)
			.effect()
			.compactMap(\.form_template.first)
			.tryMap(HTMLFormBuilder.init(template:))
			.eraseToEffect()
			.map(HTMLForm.init(builder:))
			.mapError { error in
				if let formError = error as? HTMLFormBuilderError {
					return RequestError.jsonDecoding(formError.description)
				} else {
					return error as? RequestError ?? .unknown(error)
				}
			}
			.eraseToEffect()
	}
	
	func getTemplates(_ type: FormType) -> Effect<[FormTemplateInfo], RequestError> {
		struct GetTemplates: Decodable {
			let templateList: [FormTemplateInfo]
		}
		let requestBuilder: RequestBuilder<GetTemplates>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getFormTemplates,
								   queryParams: commonAnd(other: ["form_template_type": type.rawValue])
		)
			.effect()
			.map(\.templateList)
	}
	
	func updateProfilePic(image: Data, clientId: Client.ID) -> Effect<VoidAPIResponse, RequestError> {
		let photo = PhotoUpload(fileData: image)
		return uploadPhoto(photo,
						   0,
						   ["contact_id": clientId.description,
							"counter": "1",
							"mode": "upload_photo",
							"profile_picture": "1",
							"uid": String(loggedInUser!.userID.rawValue)
						   ])
	}

}

//MARK: - Photos
extension APIClient {
	func uploadPhotos(_ photos: PhotosUpload) -> Effect<VoidAPIResponse, RequestError> {
		return Effect.concatenate (
			zip(photos.photos, photos.photos.indices).map {
				uploadPhoto($0.0, $0.1, photos.params)
			}
		)
	}
	
	func uploadPhoto(_ photo: PhotoUpload,
					 _ index: Int,
					 _ params: [String: String]) -> Effect<VoidAPIResponse, RequestError> {
		let requestBuilder: RequestBuilder<VoidAPIResponse>.Type = requestBuilderFactory.getBuilder()
		
		//USED WHEN UPLOADING FORMS
//		let delete: Bool = (bookingId != nil) && (index == 0)
//		let bookingId = bookingId != nil ? bookingId!.rawValue : 0
//		let queryParams = commonAnd(other: ["booking_id": String(bookingId),
//											"delete": String(delete)])
		
		let boundary = "Boundary-\(UUID().uuidString)"
		let httpBody = NSMutableData()
		for (key, value) in params {
		  httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
		}

		httpBody.append(convertFileData(name: "photos" + String(index),
										fileName: photo.fileName,
										mimeType: "image/jpg",
										fileData: photo.fileData,
										using: boundary))
		httpBody.appendString("--\(boundary)--")
		
		return requestBuilder.init(method: .POST,
								   baseUrl: baseUrl,
								   path: .uploadPhotos,
								   queryParams: commonAnd(other: params),
								   headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"],
								   body: httpBody as Data
		)
			.effect()
	}
	
	func convertFormField(named name: String, value: String, using boundary: String) -> String {
	  var fieldString = "--\(boundary)\r\n"
	  fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
	  fieldString += "\r\n"
	  fieldString += "\(value)\r\n"

	  return fieldString
	}

	func convertFileData(name: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
		let data = NSMutableData()
		
		data.appendString("--\(boundary)\r\n")
		data.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
		data.appendString("Content-Type: \(mimeType)\r\n\r\n")
		data.append(fileData)
		data.appendString("\r\n")
		
		return data as Data
	}
}

//MARK: - Epaper
extension APIClient {
    
    public func uploadEpaperImages(images: [Data], params: [String: String]) -> Effect<VoidAPIResponse, RequestError> {
        return images.publisher
            .flatMap { imageData in
                self.uploadEpaperImage(image: imageData, params: params)
            }
            .eraseToEffect()
    }
    
    public func uploadEpaperImage(image: Data, params: [String: String]) -> Effect<VoidAPIResponse, RequestError> {
        let photo = PhotoUpload(fileData: image)
        var commonParams: [String: String] = [
            "counter": "1",
            "mode": "upload_photo",
            "photo_type": "consent",
            "uid": String(loggedInUser!.userID.rawValue)
        ]
        commonParams.merge(params) { (_, new) in new }
        return uploadPhoto(photo,
                           0,
                           commonParams)
    }
    
	public func getPatientDetails(clientId: Client.Id) -> Effect<Client, RequestError> {
		struct PatientDetailsResponse: Decodable {
			let details: [Client]
			enum CodingKeys: String, CodingKey {
				case details = "appointments"
			}
		}
		let requestBuilder: RequestBuilder<PatientDetailsResponse>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getPatientDetails,
								   queryParams: commonAnd(other: ["contact_id": "\(clientId)"])
		)
			.effect()
			.map(\.details)
			.tryMap {
				if let first = $0.first {
					return first
				} else {
					throw RequestError.apiError("No Patient Details found")
				}
			}
			.mapError { $0 as? RequestError ?? .unknown($0) }
			.eraseToEffect()
	}
}

// MARK - ClientCard
extension APIClient {
    public func uploadClientEditedImage(image: Data, params: [String: String]) -> Effect<VoidAPIResponse, RequestError> {
        let photo = PhotoUpload(fileData: image)
        var commonParams: [String: String] = [
            "counter": "1",
            "mode": "upload_photo",
            "photo_type": "contact",
            "uid": String(loggedInUser!.userID.rawValue)
        ]
        commonParams.merge(params) { (_, new) in new }

        return uploadPhoto(photo,
                           0,
                           commonParams)
    }
}

extension NSMutableData {
	func appendString(_ string: String) {
		if let data = string.data(using: .utf8) {
			self.append(data)
		}
	}
}
