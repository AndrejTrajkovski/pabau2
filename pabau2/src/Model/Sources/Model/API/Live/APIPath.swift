public enum APIPath: String {
	//Login
	case sendConfirmation = "sendc"
	case login = "OAuth2/staff/login-check.php"
	case resetPass = "reset"
	//Journey
	case getJourneys
	//Calendar
	
	//Contacts/ Clients
	case getClients = "OAuth2/clients/get_clients.php"

    //Services
    case getServices

    //Employee
    case getEmployees

    //Appointments
    case getBookoutReasons = "OAuth2/appointments/get_bookout_reasons.php"
}
