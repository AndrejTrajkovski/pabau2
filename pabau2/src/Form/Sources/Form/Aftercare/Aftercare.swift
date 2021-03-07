import Foundation

public struct Aftercare: Equatable, Identifiable {
	public var id: UUID = UUID()
	public init (
		profile: SingleSelectImages,
		share: SingleSelectImages,
		aftercares: [AftercareOption],
		recalls: [AftercareOption]
	) {
		self.profile = profile
		self.share = share
		self.aftercares = aftercares
		self.recalls = recalls
	}

	var profile: SingleSelectImages
	var share: SingleSelectImages
	var aftercares: [AftercareOption]
	var recalls: [AftercareOption]
}

extension Aftercare {

	public static let mock = Aftercare(
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
