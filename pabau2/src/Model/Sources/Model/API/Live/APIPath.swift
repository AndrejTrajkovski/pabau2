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
}
