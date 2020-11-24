import Model
import NonEmpty
import SwiftDate
import Util
import SwiftUI
import Form
import ComposableArchitecture

struct JourneyMocks {

	static let checkIn = CheckInContainerState(
		journey:
		Journey.init(id: 1,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeId: 1, employeeInitials: "PO", locationId: 1, locationName: "Skopje", status: AppointmentStatus.mock.randomElement()!, service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
								 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil", locationId: Location.randomId()), forms: [], photos: [], postCare: [], paid: "Not Paid"),
		pathway:
		Pathway.init(id: 1,
								 title: "Standard",
								 steps: [Step(id: 1, stepType: .patientdetails),
												 Step(id: 2, stepType: .medicalhistory),
												 Step(id: 3, stepType: .consents),
												 Step(id: 4, stepType: .treatmentnotes),
												 Step(id: 5, stepType: .checkpatient),
												 Step(id: 6, stepType: .aftercares),
												 Step(id: 7, stepType: .photos)
		]),
		patientDetails: PatientDetails.mock,
		medHistory: FormTemplate.getMedHistory(),
		consents: [],
		allConsents: IdentifiedArray(FormTemplate.mockConsents),
		photosState: PhotosState.init(SavedPhoto.mock())
	)
}

extension JourneyMocks {

	static let aftercare = Aftercare(
		profile: SingleSelectImages(
			images: [ImageUrl("emily"),
							 ImageUrl("dummy1"),
							 ImageUrl("dummy2"),
							 ImageUrl("dummy3")],
			selectedIdx: nil),
		share: SingleSelectImages(
			images: [
				ImageUrl("dummy1"),
				ImageUrl("dummy2"),
				ImageUrl("dummy3"),
				ImageUrl("dummy4"),
				ImageUrl("dummy5"),
				ImageUrl("dummy6"),
				ImageUrl("dummy7"),
				ImageUrl("emily")
			],
			selectedIdx: nil),
		aftercares: [
			AftercareOption("Aftercare", .sms),
			AftercareOption("Botox Aftercare", .email),
			AftercareOption("Hyalase Aftercare", .email),
			AftercareOption("PRP Aftercare Advice", .email),
			AftercareOption("Chemical Peel Aftercare", .email),
			AftercareOption("Aftercare Template", .email)
		],
		recalls: [
			AftercareOption("Appointment Rescheduled", .email),
			AftercareOption("Birthday Wishes SMS", .email),
			AftercareOption("Sorry you were unable to attend.", .email)
		]
	)
}
