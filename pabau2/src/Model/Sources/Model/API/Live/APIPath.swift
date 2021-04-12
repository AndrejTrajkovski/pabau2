public enum APIPath: String {
	//Login
	case sendConfirmation = "sendc"
	case login = "/OAuth2/staff/login-check.php"
	case resetPass = "/modules/t/secure/password/reset.php"
	//Journey
	case getEmployees = "/OAuth2/employees/get_employees.php"
	case getAppointments = "/OAuth2/appointments/get_appointments_v1.php"
	case getLocations = "/OAuth2/locations/get_locations_v1.php"
	case getPathwaysTemplates = "/OAuth2/pathway/list_pathways.php"

    case getShifts = "/OAuth2/staff/get_rota_shifts.php"
	case pathwaysMatch = "/OAuth2/pathway/match.php"
	
	//Calendar
    case createShift = "/OAuth2/staff/create_shift.php"
    //Services
    case getServices = "/OAuth2/services/get_services.php"

    case createAppointment = "/OAuth2/appointments/create_appointment_v1.php"
	
	//Form
	case getFormTemplates = "/OAuth2/medical_forms/medical_forms_templates_list.php"
	case getFormTemplateData = "/OAuth2/medical_forms/form_template_data.php"
	case medicalForms = "/OAuth2/medical_forms/medical_forms.php"
	
    //Appointments
    case getBookoutReasons = "OAuth2/appointments/get_bookout_reasons.php"
    
	case updateClient = "/OAuth2/clients/client_update.php"
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
    case getUsers = "/OAuth2/employees/get_users.php"
	
	case uploadPhotos = "/OAuth2/clients/upload_photos.php"
}
