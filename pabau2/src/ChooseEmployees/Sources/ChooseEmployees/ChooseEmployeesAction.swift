import Model

public enum ChooseEmployeesAction: Equatable {
	case reload
	case gotEmployeeResponse(Result<SuccessState<[Employee]>, RequestError>)
	case didSelectEmployee(Employee.Id)
	case onSearch(String)
	case didTapBackBtn
}
