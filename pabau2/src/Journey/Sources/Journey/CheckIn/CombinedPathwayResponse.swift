import Model
import Combine
import ComposableArchitecture

public struct CombinedPathwayResponse: Equatable {
	let pathwayTemplate: PathwayTemplate
	let pathway: Pathway
	let appointment: Appointment
}

public func getCombinedPathwayResponse(journeyAPI: JourneyAPI,
									   checkInState: CheckInLoadingState) -> Effect<Result<CombinedPathwayResponse, RequestError>, Never> {
	let getTemplate = journeyAPI.getPathwayTemplate(id: checkInState.pathwayTemplateId)
	let getPathway = journeyAPI.getPathway(id: checkInState.pathwayId)
	return Publishers.Zip.init(getTemplate, getPathway)
		.receive(on: DispatchQueue.main)
		.eraseToEffect()
		.catchToEffect()
		.map {
			$0.map { CombinedPathwayResponse.init(pathwayTemplate: $0.0,
												  pathway: $0.1,
												  appointment: checkInState.appointment)}
		}
		.eraseToEffect()
}
