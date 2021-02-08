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
    case getFinancials = "/OAuth2/financials/get_financials.php"
    case getPatientDetails = "/OAuth2/clients/get_clients.php/"
    case getForms = "/OAuth2/clients/client_treatment_history.php"
    case getDocuments = "/OAuth2/clients/get_documents.php"
    case getCommunications = "/OAuth2/communication/get_communications.php"
    case getClientsAppointmens = "/OAuth2/clients/get_client_appointments.php"
    case getClientsPhotos = "/OAuth2/clients/get_photos.php"
    case getClientAlerts = "/OAuth2/clients/medical_alerts.php"
    case getClientsNotes = "/OAuth2/clients/get_notes.php"
}