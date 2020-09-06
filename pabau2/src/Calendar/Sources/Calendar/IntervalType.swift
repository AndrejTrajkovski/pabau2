import Model

enum IntervalType {
	case appointment(Appointment.Id)
	case bookout(Bookout.Id)
	case shift
	case noShift
}
