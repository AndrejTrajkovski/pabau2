import ComposableArchitecture
import Combine
//FormAPI
public extension APIClient {
    
    func saveAftercareForm(_ bookingId: Appointment.ID,
                           _ pathwayIdStepId: PathwayIdStepId,
                           _ clientId: Client.ID,
                           _ selectedAftercareIds: [AftercareTemplate.ID],
                           _ selectedRecallIds: [AftercareTemplate.ID],
                           _ profilePicId: SavedPhoto.ID?,
                           _ sharePicId: SavedPhoto.ID?) -> Effect<StepStatus, RequestError> {

        struct AftercareResponse: Decodable {
            let status: StepStatus
        }

        let queryParams: [String : Any] = [
            "pathway_taken_id": pathwayIdStepId.path_taken_id.description,
            "step_id": pathwayIdStepId.step_id.description,
            "contact_id": clientId.description,
            "aftercare_ids": selectedAftercareIds.map(\.rawValue),
            "recall_ids": selectedRecallIds.map(\.rawValue)
        ]

        let requestBuilder: RequestBuilder<AftercareResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .POST,
                                   baseUrl: baseUrl,
                                   path: .saveAftercareAndRecall,
                                   queryParams: commonAnd(other: queryParams)
        )
        .effect()
        .map(\.status)
        .eraseToEffect()
    }
    
    func getAftercareAndRecall(appointmentId: Appointment.ID) -> Effect<AftercareAndRecalls, RequestError> {
        
        let getAft = getAftercare(appointmentId: appointmentId)
        let getrecalls = getRecalls(appointmentId: appointmentId)
        let parallel = getAft.combineLatest(getrecalls)
            .map { AftercareAndRecalls.init(aftercare: $0.0, recalls: $0.1)}
            .eraseToAnyPublisher()
        
        return parallel.eraseToEffect()
    }
    
    func getAftercare(appointmentId: Appointment.ID) -> Effect<[AftercareTemplate], RequestError> {
        struct AftercareResponse: Decodable {
            let employees: [AftercareTemplate]
        }
        
        let requestBuilder: RequestBuilder<AftercareResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getAftercare,
                                   queryParams: commonAnd(other: ["appointment_id" : appointmentId.description])
        )
        .effect()
        .map(\.employees)
        .eraseToEffect()
    }
    
    func getRecalls(appointmentId: Appointment.ID) -> Effect<[AftercareTemplate], RequestError> {
        
        struct AftercareResponse: Decodable {
            let employees: [AftercareTemplate]
        }
        
        let requestBuilder: RequestBuilder<AftercareResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getRecalls,
                                   queryParams: commonAnd(other: ["appointment_id" : appointmentId.description])
        )
        .effect()
        .map(\.employees)
        .eraseToEffect()
    }
    
    func updateStepStatus(_ stepStatus: StepStatus, _ pathwayStep: PathwayIdStepId, _ clientId: Client.ID, _ appointmentId: Appointment.ID) -> Effect<StepStatus, RequestError> {
        
        struct Response: Decodable {
            let status: StepStatus
        }
        
        let queryParams: [String : Any] = [
            "status" : stepStatus.rawValue,
            "pathway_taken_id": pathwayStep.path_taken_id.description,
            "step_id": pathwayStep.step_id.description,
            "contact_id": clientId.description,
            "booking_id": appointmentId.description
        ]
        
        let requestBuilder: RequestBuilder<Response>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .POST,
                                   baseUrl: baseUrl,
                                   path: .updateStepStatus,
                                   queryParams: commonAnd(other: queryParams)
        )
        .effect()
        .map(\.status)
        .eraseToEffect()
    }
    
    func skipStep(_ pathwayStep: PathwayIdStepId, _ clientId: Client.ID, _ appointmentId: Appointment.ID) -> Effect<StepStatus, RequestError> {
        return updateStepStatus(.skipped, pathwayStep, clientId, appointmentId)
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
        let params = ["contact_id": clientId.description,
                      "counter": "1",
                      "mode": "upload_photo",
                      "profile_picture": "1",
                      "uid": String(loggedInUser!.userID.rawValue)
                     ]
        let photo = PhotoUpload(fileData: image, params: params)
        return uploadPhoto(photo, 0, [:], VoidAPIResponse.self)
	}

}

//MARK: - Photos
extension APIClient {
//    func uploadPhotos(_ photos: PhotosUpload, _ deletePreviousPhotosInStep: Bool = false) -> Effect<VoidAPIResponse, RequestError> {
//		return Effect.concatenate (
//			zip(photos.photos, photos.photos.indices).map {
//				uploadPhoto($0.0, $0.1, photos.params)
//			}
//		)
//	}

    func uploadPhoto<T: Decodable>(_ photo: PhotoUpload,
					 _ index: Int,
                     _ queryParams: [String: String],
                     _ returnType: T.Type) -> Effect<T, RequestError> {

		let requestBuilder: RequestBuilder<T>.Type = requestBuilderFactory.getBuilder()
		let boundary = "Boundary-\(UUID().uuidString)"
		let httpBody = NSMutableData()
        for (key, value) in photo.photoParams {
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
								   queryParams: commonAnd(other: queryParams),
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
                self.uploadEpaperImage(image: imageData, queryParams: params)
            }
            .eraseToEffect()
    }
    
    public func uploadEpaperImage(image: Data, queryParams: [String: String]) -> Effect<VoidAPIResponse, RequestError> {
        let multipartParams: [String: String] = [
            "counter": "1",
            "mode": "upload_photo",
            "photo_type": "consent",
            "uid": String(loggedInUser!.userID.rawValue)
        ]
        let photo = PhotoUpload(fileData: image, params: multipartParams)


        return uploadPhoto(photo,
                           0,
                           queryParams,
                           VoidAPIResponse.self)
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

    public func uploadImage(upload: PhotoUpload,
                            pathwayIdStepId: PathwayIdStepId) -> Effect<SavedPhoto, RequestError> {
        var queryParams = commonParams()
        merge(&queryParams, with: pathwayIdStepId)
        return uploadPhoto(upload, 0, queryParams as! [String: String], [SavedPhoto].self)
            .map(\.first!)
    }

    public func getPhotos(pathwayId: Pathway.ID, stepId: Step.ID) -> Effect<[SavedPhoto], RequestError> {
        struct PhotosResponse: Decodable {
            let step_attachments: [SavedPhoto]
        }
        let requestBuilder: RequestBuilder<PhotosResponse>.Type = requestBuilderFactory.getBuilder()

        return requestBuilder.init(
            method: .GET,
            baseUrl: baseUrl,
            path: .getPathwayStepPhotos,
            queryParams: commonAnd(other: ["path_taken_id": pathwayId,
                                           "step_id": stepId.description])
        )
        .effect()
        .map(\.step_attachments)
        .eraseToEffect()
    }
}

extension NSMutableData {
	func appendString(_ string: String) {
		if let data = string.data(using: .utf8) {
			self.append(data)
		}
	}
}
