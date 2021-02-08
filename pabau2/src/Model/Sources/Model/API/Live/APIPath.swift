public enum APIPath: String {
	//Login
	case sendConfirmation = "sendc"
	case login = "/OAuth2/staff/login-check.php"
	case resetPass = "reset"
	//Journey
	case getEmployees = "/OAuth2/employees/get_employees.php"
	case getAppointments = "/OAuth2/appointments/get_appointments_v1.php"
	case getLocations = "/OAuth2/locations/get_locations_v1.php"
	//Calendar
	
	//Contacts/ Clients
	case getClients = "/OAuth2/clients/get_clients.php"
    case getClientsNotes = "/OAuth2/clients/get_notes.php"
}
