import Model
import Util
import NonEmpty
import SwiftDate
import Foundation
import ComposableArchitecture
import EmployeesFilter

public struct JourneyState: Equatable {
	public init (selectedDate: Date,
							 employeesState: EmployeesFilterState) {
		self.selectedDate = selectedDate
		self.employeesState = employeesState
	}
	
	public var selectedDate: Date
	public var employeesState: EmployeesFilterState
	
	var loadingState: LoadingState = .initial
	var journeys: Set<Journey> = Set()
	var selectedFilter: CompleteFilter = .all
	var selectedLocation: Location = Location.init(id: 1)
	var searchText: String = ""
	var selectedJourney: Journey?
	var selectedPathway: Pathway?

	var selectedConsentsIds: [Int] = []
	var allConsents: IdentifiedArrayOf<FormTemplate> = []
	public var checkIn: CheckInContainerState?
//		= JourneyMocks.checkIn

	public var addAppointment: AddAppointmentState = AddAppointmentState.init(
		isShowingAddAppointment: false,
		reminder: false,
		email: false,
		sms: false,
		feedback: false,
		isAllDay: false,
		clients: JourneyMocks.clientState,
		termins: JourneyMocks.terminState,
		services: ChooseServiceState(isChooseServiceActive: false, chosenServiceId: 1, filterChosen: .allStaff),
		durations: JourneyMocks.durationState,
		with: JourneyMocks.withState,
		participants: JourneyMocks.participantsState)
}

extension JourneyState {

	var choosePathway: ChoosePathwayState {
		get {
			ChoosePathwayState(selectedJourney: selectedJourney,
												 selectedPathway: selectedPathway,
												 selectedConsentsIds: selectedConsentsIds,
												 allConsents: allConsents)
		}
		set {
			self.selectedJourney = newValue.selectedJourney
			self.selectedPathway = newValue.selectedPathway
			self.selectedConsentsIds = newValue.selectedConsentsIds
			self.allConsents = newValue.allConsents
		}
	}

	var filteredJourneys: [Journey] {
		return self.journeys
			.filter { $0.appointments.first.start_time.isInside(date: selectedDate, granularity: .day) }
			.filter { employeesState.selectedEmployeesIds.contains($0.employee.id) }
			.sorted(by: { $0.appointments.first.start_time > $1.appointments.first.start_time })
	}
}
