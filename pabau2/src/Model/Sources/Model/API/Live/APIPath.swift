public enum APIPath: String {
	//Login
	case sendConfirmation = "sendc"
	case login = "/OAuth2/staff/login-check.php"
	case resetPass = "reset"
	//Journey
	case getJourneys
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
}
