import Model
import SwiftDate
import Util
import SwiftUI
import Form
import ComposableArchitecture

struct JourneyMocks {
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

