import ComposableArchitecture
import SwiftDate

public struct ClientsMockAPI: MockAPI, ClientsAPI {
	public func getClients() -> Effect<Result<[Client], RequestError>, Never> {
		mockSuccess(Self.mockClients, delay: 0.2)
	}
	
	public init () {}
}

extension ClientsMockAPI {
	static let mockClients =
		[
			Client(id:1, firstName: "Jessica", lastName:"Avery", dOB: Date(), email: "ninenine@me.com", avatar: "dummy1"),
			Client(id:2, firstName: "Joan", lastName:"Bailey", dOB: Date(), email: "bmcmahon@outlook.com", avatar: nil),
			Client(id:3, firstName: "Joanne", lastName:"Baker", dOB: Date(), email: "redingtn@yahoo.ca", avatar: nil),
			Client(id:4, firstName: "Julia", lastName:"Ball", dOB: Date(), email: "bolow@mac.com", avatar: "dummy2"),
			Client(id:5, firstName: "Karen", lastName:"Bell", dOB: Date(), email: "microfab@msn.com", avatar: nil),
			Client(id:6, firstName: "Katherine", lastName:"Berry", dOB: Date(), avatar: nil),
			Client(id:7, firstName: "Kimberly", lastName:"Black", dOB: Date(), email: "msloan@msn.com", avatar: nil),
			Client(id:8, firstName: "Kylie", lastName:"Blake", dOB: Date(), email: "seano@yahoo.com", avatar: "dummy3"),
			Client(id:9, firstName: "Lauren", lastName:"Bond", dOB: Date(), email: "jorgb@aol.com", avatar: "dummy4"),
			Client(id:10, firstName: "Leah", lastName:"Bower", dOB: Date(), avatar: "dummy5"),
			Client(id:11, firstName: "Lillian", lastName:"Brown", dOB: Date(), email: "nogin@gmail.com", avatar: "dummy6"),
			Client(id:12, firstName: "Lily", lastName:"Buckland", dOB: Date(), email: "redingtn@hotmail.com", avatar: "dummy7"),
			Client(id:13, firstName: "Lisa", lastName:"Burgess", dOB: Date(), avatar: nil),
			Client(id:14, firstName: "Madeleine", lastName:"Butler", dOB: Date(), avatar: nil),
			Client(id:15, firstName: "Maria", lastName:"Cameron", dOB: Date(), email: "gilmoure@verizon.net", avatar: nil),
			Client(id:16, firstName: "Mary", lastName:"Campbell", dOB: Date(), avatar: nil),
			Client(id:17, firstName: "Megan", lastName:"Carr", dOB: Date(), avatar: "dummy8"),
			Client(id:18, firstName: "Melanie", lastName:"Chapman", dOB: Date(), email: "dpitts@att.net", avatar: "dummy9"),
			Client(id:19, firstName: "Michelle", lastName:"Churchill", dOB: Date(), avatar: nil),
			Client(id:20, firstName: "Molly", lastName:"Clark", dOB: Date(), avatar: nil),
			Client(id:21, firstName: "Natalie", lastName:"Clarkson", dOB: Date(), email: "bmcmahon@outlook.com", avatar: nil),
			Client(id:22, firstName: "Nicola", lastName:"Avery", dOB: Date(), avatar: nil),
			Client(id:23, firstName: "Olivia", lastName:"Bailey", dOB: Date(), avatar: nil),
			Client(id:24, firstName: "Penelope", lastName:"Baker", dOB: Date(), avatar: "dummy10"),
			Client(id:25, firstName: "Pippa", lastName:"Ball", dOB: Date(), avatar: nil),
	]
}












