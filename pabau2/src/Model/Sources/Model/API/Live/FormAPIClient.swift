import ComposableArchitecture
//FormAPI
extension APIClient {
	
	public func save(form: HTMLForm, clientId: Client.ID) -> Effect<FilledFormData.ID, RequestError> {
		struct Response: Codable {
			let medical_form_contact_id: FilledFormData.ID
		}
		let body: [String : Any] = [
			"mode": "save",
			//									"uid": "",
			"booking_id": "",
			"contact_id": clientId.description,
			"form_id": form.templateInfo.id.rawValue,
			"form_data": form.getJSONPOSTValues()]
		let requestBuilder: RequestBuilder<Response>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .POST,
								   baseUrl: baseUrl,
								   path: .medicalForms,
								   queryParams: commonParams(),
								   body: body)
		.effect()
		.map(\.medical_form_contact_id)
	}
	
	public func getForm(templateId: FormTemplateInfo.ID, entryId: FilledFormData.ID) -> Effect<HTMLForm, RequestError> {
		
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
//			.print()
			.mapError { error in
				print("form error \(error)")
				if let formError = error as? HTMLFormBuilderError {
					return RequestError.jsonDecoding(formError.description)
				} else {
					return error as? RequestError ?? .unknown
				}
			}
			.eraseToEffect()
	}
	
	public func getForm(templateId: FormTemplateInfo.ID) -> Effect<HTMLForm, RequestError> {
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
//			.print()
			.mapError { error in
				if let formError = error as? HTMLFormBuilderError {
					return RequestError.jsonDecoding(formError.description)
				} else {
					return error as? RequestError ?? .unknown
				}
			}
			.eraseToEffect()
	}
	
	public func post(form: HTMLForm, appointments: [CalendarEvent.Id]) -> Effect<HTMLForm, RequestError> {
		fatalError()
	}
	
	public func getTemplates(_ type: FormType) -> Effect<[FormTemplateInfo], RequestError> {
		struct GetTemplates: Codable {
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

}
