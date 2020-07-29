import Foundation

public struct PatientComplete: Hashable, Identifiable {
	public var id: UUID = UUID()
	var isPatientComplete: Bool
}
