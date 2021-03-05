import Foundation

struct PhotoUpload {
	let fileData: Data
	let fileName: String
	
	init(fileData: Data) {
		self.fileData = fileData
		self.fileName = "photo_" + UUID().description + ".jpg"
	}
}

struct PhotosUpload {	
	let photos: [PhotoUpload]
	let params: [String: String]
	let bookingId: Appointment.ID?
}
