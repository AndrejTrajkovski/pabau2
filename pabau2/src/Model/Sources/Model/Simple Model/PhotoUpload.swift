import Foundation

struct PhotoUpload {
	let fileData: Data
	let fileName: String
}

struct PhotosUpload {	
	let photos: [PhotoUpload]
	let params: [String: Any]
	let bookingId: Appointment.ID?
}
