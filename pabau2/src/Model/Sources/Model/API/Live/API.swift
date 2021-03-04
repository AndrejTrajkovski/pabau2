import ComposableArchitecture
import Combine

public class APIClient: LoginAPI, JourneyAPI, ClientsAPI, FormAPI {
	
    public init(baseUrl: String, loggedInUser: User?) {
        self.baseUrl = baseUrl
        self.loggedInUser = loggedInUser
    }

    var baseUrl: String = "https://crm.pabau.com"
    var loggedInUser: User? = nil
	let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
	
	func uploadPhoto(_ photo: PhotoUpload, _ index: Int, _ params: [String: String]) -> Effect<VoidAPIResponse, RequestError> {
		let boundary = "Boundary-\(UUID().uuidString)"

		var request = URLRequest(url: URL(string: "https://some-page-on-a-server")!)
		request.httpMethod = "POST"
		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		
		let httpBody = NSMutableData()

		for (key, value) in params {
		  httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
		}

		httpBody.append(convertFileData(name: "photos" + String(index),
										fileName: photo.fileName,
										mimeType: "image/jpg",
										fileData: photo.fileData,
										using: boundary))

		httpBody.appendString("--\(boundary)--")

		request.httpBody = httpBody as Data

		print(String(data: httpBody as Data, encoding: .utf8)!)
		
		return publisher(request: request, dateDecoding: .formatted(.rfc3339)).eraseToEffect()
	}
	
	func convertFormField(named name: String, value: String, using boundary: String) -> String {
	  var fieldString = "--\(boundary)\r\n"
	  fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
	  fieldString += "\r\n"
	  fieldString += "\(value)\r\n"

	  return fieldString
	}

	func convertFileData(name: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
		let data = NSMutableData()
		
		data.appendString("--\(boundary)\r\n")
		data.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
		data.appendString("Content-Type: \(mimeType)\r\n\r\n")
		data.append(fileData)
		data.appendString("\r\n")
		
		return data as Data
	}
}

extension NSMutableData {
	func appendString(_ string: String) {
		if let data = string.data(using: .utf8) {
			self.append(data)
		}
	}
}
