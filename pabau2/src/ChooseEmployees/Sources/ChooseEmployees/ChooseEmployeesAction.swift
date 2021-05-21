import Model

public enum ChooseEmployeesAction: Equatable {
	case onAppear
	case gotEmployeeResponse(Result<SuccessState<[Employee]>, RequestError>)
	case didSelectEmployee(Employee)
	case onSearch(String)
	case didTapBackBtn
}
