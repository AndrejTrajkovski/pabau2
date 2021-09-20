import Foundation

public struct PhotoUpload {
	let fileData: Data
	let fileName: String
    let photoParams: [String: String]
    
    public init(fileData: Data,
                params: [String: String]) {
		self.fileData = fileData
		self.fileName = "photo_" + UUID().description + ".jpg"
        self.photoParams = params
	}
}
