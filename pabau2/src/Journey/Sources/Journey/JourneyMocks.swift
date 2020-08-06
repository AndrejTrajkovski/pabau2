import Model
import NonEmpty
import SwiftDate
import Util
import SwiftUI

struct JourneyMocks {
	static let clientState: PickerContainerState<Client> =
		PickerContainerState.init(
			dataSource: [
				Client.init(id: 1, firstName: "Wayne", lastName: "Rooney", dOB: Date()),
				Client.init(id: 2, firstName: "Adam", lastName: "Smith", dOB: Date())
			],
			chosenItemId: 1,
			isActive: false)

	static let terminState: PickerContainerState<MyTermin> = PickerContainerState.init(
		dataSource: [
			MyTermin.init(name: "12:30", id: 1, date: Date()),
			MyTermin.init(name: "13:30", id: 2, date: Date()),
			MyTermin.init(name: "14:30", id: 3, date: Date())
		],
		chosenItemId: 1,
		isActive: false)

	static let serviceState: PickerContainerState<Service> =
		PickerContainerState.init(
			dataSource: [
				Service.init(id: 1, name: "Botox", color: "", categoryId: 1, categoryName: "Injectables"),
				Service.init(id: 2, name: "Fillers", color: "", categoryId: 2, categoryName: "Urethra"),
				Service.init(id: 3, name: "Facial", color: "", categoryId: 3, categoryName: "Mosaic")
			],
			chosenItemId: 1,
			isActive: false)

	static let durationState: PickerContainerState<Duration> =
		PickerContainerState.init(
			dataSource: [
				Duration.init(name: "00:30", id: 1, duration: 30),
				Duration.init(name: "01:00", id: 2, duration: 60),
				Duration.init(name: "01:30", id: 3, duration: 90)
			],
			chosenItemId: 1,
			isActive: false)

	static let withState: PickerContainerState<Employee> =
		PickerContainerState.init(
			dataSource: [
				Employee.init(id: 1, name: "Andrej Trajkovski"),
				Employee.init(id: 2, name: "Mark Ronson")
			],
			chosenItemId: 1,
			isActive: false)

	static let participantsState: PickerContainerState<Employee> =
		PickerContainerState.init(
			dataSource: [
				Employee.init(id: 1, name: "Participant 1"),
				Employee.init(id: 2, name: "Participant 2")
			],
			chosenItemId: 1,
			isActive: false)

	static let checkIn = CheckInContainerState(
		journey:
		Journey.init(id: 1,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeId: 1, employeeInitials: "PO", locationId: 1, locationName: "Skopje", status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
								 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
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
		consents: FormsCollection(ids: [], fromAll: []),
		allConsents: flatten(FormTemplate.mockConsents),
		photosState: PhotosState.init(JourneyMockAPI.photos())
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

extension JourneyMocks {
	public static func injectables() -> [Injectable] {
		return [
			Injectable(id: 0, color: Color(hex: "0168DA"), title: "Artefill", increment: 0.25),
			Injectable(id: 4, color: Color(hex: "B4B5C8"), title: "Mupirocin (Bactroban Ointment)", increment: 0.25),
			Injectable(id: 5, color: Color(hex: "B4B5C8"), title: "Maxalt (Rizatriptan Benzoate)", increment: 0.25),
			Injectable(id: 6, color: Color(hex: "B4B5C8"), title: "MenHibrix", increment: 0.25),
			Injectable(id: 7, color: Color(hex: "A1A1FF"), title: "Methyldopa (Aldomet)", increment: 0.25),
			Injectable(id: 8, color: Color(hex: "A1A1FF"), title: "Botox", increment: 0.25),
			Injectable(id: 9, color: Color(hex: "006400"), title: "Morphone sulfate (Morphine Sulfate Tablets)", increment: 0.25),
			Injectable(id: 10, color: Color(hex: "006400"), title: "Morphine Sulfate Extended-Release ", increment: 0.25),
			Injectable(id: 11, color: Color(hex: "006400"), title: "Metronidazole (Noritate)", increment: 0.25)
		]
	}
}
