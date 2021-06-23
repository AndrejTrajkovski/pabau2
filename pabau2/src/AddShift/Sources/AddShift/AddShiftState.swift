import Model
import ChooseLocationAndEmployee
import Foundation
import ToastAlert

public struct AddShiftState: Equatable {
	
	public init(shiftRotaID: Int? = nil, isPublished: Bool = false, chooseLocAndEmp: ChooseLocationAndEmployeeState, startDate: Date? = nil, startTime: Date? = nil, endTime: Date? = nil, note: String, showsLoadingSpinner: Bool = false, employeeValidator: String? = nil, startTimeValidator: String? = nil, endTimeValidator: String? = nil) {
		self.shiftRotaID = shiftRotaID
		self.isPublished = isPublished
		self.chooseLocAndEmp = chooseLocAndEmp
		self.startDate = startDate
		self.startTime = startTime
		self.endTime = endTime
		self.note = note
		self.showsLoadingSpinner = showsLoadingSpinner
		self.startTimeValidator = startTimeValidator
		self.endTimeValidator = endTimeValidator
	}
	
	var shiftRotaID: Int?
	var isPublished: Bool = false
	var chooseLocAndEmp: ChooseLocationAndEmployeeState
	var startDate: Date?
	var startTime: Date?
	var endTime: Date?
	var note: String
	
	var showsLoadingSpinner: Bool = false
	var startTimeValidator: String?
	var endTimeValidator: String?
    var toast: ToastState<AddShiftAction>?
	
	var shiftSchema: ShiftSchema {
		let rotaUID = chooseLocAndEmp.chosenEmployeeId
		let locationID = chooseLocAndEmp.chosenLocationId
		
		return ShiftSchema(
			rotaID: shiftRotaID,
            date: startDate?.getFormattedDate(format: "MM-dd-yyyy"),
			startTime: startTime?.getFormattedDate(format: "HH:mm"),
			endTime: endTime?.getFormattedDate(format: "HH:mm"),
            locationID: "\(String(describing: locationID!))",
			notes: note,
			published: isPublished,
			rotaUID: rotaUID!.rawValue
		)
	}
}
