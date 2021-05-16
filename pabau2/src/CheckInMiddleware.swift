//let checkInMiddleware = Reducer<ListState, CheckInContainerAction, JourneyEnvironment> { state, action, _ in
//	switch action {
//	case .patient(.stepsView(.onXTap)):
//		state.checkIn = nil
//		return .none
////	case .patient(.topView(.onXButtonTap)),
////			 .doctorSummary(.xOnDoctorCheckIn):
////		state.selectedJourney = nil
////		state.selectedPathway = nil
////		state.checkIn?.didGoBackToPatientMode = false
////		state.checkIn = nil
////	case .doctor(.checkInBody(.completeJourney(.onCompleteJourney))),
////		.doctor(.checkInBody(.footer(.completeJourney(.onCompleteJourney)))):
////		state.selectedJourney = nil
////		state.selectedPathway = nil
////		state.checkIn?.didGoBackToPatientMode = false
////		state.checkIn = nil
//	default:
//		return .none
//	}
//}

//	checkInReducer.optional().pullback(
//		state: \ListState.checkIn,
//		action: /ListAction.checkIn,
//		environment: { $0 }),
//	checkInMiddleware.pullback(
//		state: \ListState.self,
//		action: /ListAction.checkIn,
//		environment: { $0 }
//	)
//
//choosePathwayContainerReducer.optional().pullback(
//			 state: \ListState.choosePathway,
//			 action: /ListAction.choosePathway,
//			 environment: { $0 }),

//
//case .selectedAppointment(let appointment):
//	if let pathwayId = appointment.pathwayId,
//	   let pathwayTemplateId = appointment.pathwayTemplateId {
//		print(pathwayId, pathwayTemplateId)
//		let getTemplate = environment.repository.getPathwayTemplates()
//			.map { $0.first(where: { $0.id.description == pathwayTemplateId.description }) }
//			.tryMap { optionalPwT -> PathwayTemplate in
//				if let pathwayTemplate = optionalPwT {
//					return pathwayTemplate
//				} else {
//					throw RequestError.emptyDataResponse
//				}
//			}
//			.mapError { $0 as? RequestError ?? .unknown }
//			.eraseToEffect()
//		
//		let getPathway = environment.journeyAPI.getPathway(id: pathwayId)
//		
//		let zipped = Publishers.Zip.init(getTemplate, getPathway)
//			.receive(on: DispatchQueue.main)
//			.eraseToEffect()
//			.catchToEffect()
//			.map {
//				$0.map { CombinedPathwayResponse.init(pathwayTemplate: $0.0,
//													  pathway: $0.1,
//													  appointment: appointment)}
//			}
//			.map(JourneyAction.combinedPathwaysResponse)
//		
//		return zipped
//		
//	} else {
//		state.choosePathway = ChoosePathwayState(selectedAppointment: appointment)
//		return environment.journeyAPI.getPathwayTemplates()
//			.receive(on: DispatchQueue.main)
//			.catchToEffect()
//			.map { .choosePathway(.gotPathwayTemplates($0))  }
//	}
//	
//case .choosePathwayBackTap:
//	state.choosePathway = nil
//	
//case .choosePathway(.matchResponse(let pathwayResult)):
//	print(pathwayResult)
//	switch pathwayResult {
//	case .success(let pathway):
//		
//		state.checkIn = CheckInContainerState(appointment: state.choosePathway!.selectedAppointment,
//											  pathway: pathway,
//											  pathwayTemplate: state.choosePathway!.selectedPathway!,
//											  patientDetails: ClientBuilder.empty,
//											  medicalHistories: [],
//											  consents: [],
//											  allConsents: [],
//											  photosState: PhotosState.init(SavedPhoto.mock()
//											  )
//		)
//		
//		return Just(JourneyAction.checkIn(CheckInContainerAction.showPatientMode))
//			.delay(for: .seconds(checkInAnimationDuration), scheduler: DispatchQueue.main)
//			.eraseToEffect()
//		
//	case .failure(let error):
//		break// handled in choosePathwayContainerReducer
//	}
//	
//case .combinedPathwaysResponse(let pathwaysResult):
//	switch pathwaysResult {
//	case .success(let pwys):
//		
//		state.checkIn = CheckInContainerState(appointment: pwys.appointment,
//											  pathway: pwys.pathway,
//											  pathwayTemplate: pwys.pathwayTemplate,
//											  patientDetails: ClientBuilder.empty,
//											  medicalHistories: [],
//											  consents: [],
//											  allConsents: [],
//											  photosState: PhotosState.init(SavedPhoto.mock()
//											  )
//		)
//		
//		return Just(JourneyAction.checkIn(CheckInContainerAction.showPatientMode))
//			.delay(for: .seconds(checkInAnimationDuration), scheduler: DispatchQueue.main)
//			.eraseToEffect()
//		
//	case .failure(let error):
//		state.getPathwaysAlertState = AlertState(
//			title: TextState("Pathway Error"),
//			message: TextState(error.description),
//			dismissButton: .default(TextState("OK"), send: .dismissGetPathwaysErrorAlert)
//		)
//	}
//	
//case .dismissGetPathwaysErrorAlert:
//	state.getPathwaysAlertState = nil

//case combinedPathwaysResponse(Result<CombinedPathwayResponse, RequestError>)
//case dismissGetPathwaysErrorAlert

//public struct CombinedPathwayResponse: Equatable {
//	let pathwayTemplate: PathwayTemplate
//	let pathway: Pathway
//	let appointment: Appointment
//}

//	var choosePathwayLink: some View {
//		NavigationLink.emptyHidden(
//			viewStore.state.isChoosePathwayShown,
//			IfLetStore(
//				store.scope(state: { $0.journey.choosePathway },
//							action: { .choosePathway($0) }),
//				then: { choosePathwayStore in
//					ChoosePathway.init(store: choosePathwayStore)
//						.navigationBarTitle("Choose Pathway")
//						.customBackButton {
//							viewStore.send(.choosePathwayBackTap)
//						}
//				}
//			)
//		)
//	}

//.alert(store.scope(state: { $0.journey.getPathwaysAlertState },
//				   action: { $0 }),
//	   dismiss: ListAction.dismissGetPathwaysErrorAlert)

//self.isChoosePathwayShown = state.journey.choosePathway != nil
