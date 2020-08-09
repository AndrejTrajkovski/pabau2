import Foundation

public struct PatientComplete: Hashable, Identifiable {
	public var id: UUID = UUID()
	public var isPatientComplete: Bool
	
	public init (isPatientComplete: Bool) {
		self.isPatientComplete = isPatientComplete
	}
}
