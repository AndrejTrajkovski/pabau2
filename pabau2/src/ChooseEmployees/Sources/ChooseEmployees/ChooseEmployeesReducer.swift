import ComposableArchitecture

public let chooseEmployeesParentReducer: Reducer<
	ChooseEmployeesState?,
	ChooseEmployeesAction,
	ChooseEmployeesEnvironment
> = .combine(
	
	chooseEmployeesReducer.optional().pullback(
		state: \.self,
		action: /.self,
		environment: { $0 }
	),
	
	.init { state, action, env in
		
		switch action {
		
		case .didSelectEmployee(let employee):
			
			state = nil
			
		case .didTapBackBtn:
			
			state = nil
			
		case .reload:
			
			break
			
		case .gotEmployeeResponse(_):
			
			break
			
		case .onSearch(_):
			
			break
		}
		
		return .none
	}
)


public let chooseEmployeesReducer = Reducer<
	ChooseEmployeesState,
	ChooseEmployeesAction,
	ChooseEmployeesEnvironment
> { state, action, env in
	switch action {
	
	case .reload:
		
		state.searchText = ""
		return env.repository.getEmployees()
			.catchToEffect()
			.receive(on: DispatchQueue.main)
			.map(ChooseEmployeesAction.gotEmployeeResponse)
			.eraseToEffect()
		
	case .onSearch(let text):
		
		state.searchText = text
		if state.searchText.isEmpty {
			state.filteredEmployees = state.employees
		} else {
			state.filteredEmployees = state.employees.filter {$0.name.lowercased().contains(text.lowercased())}
		}
		
	case .gotEmployeeResponse(let result):
		
		switch result {
		case .success(let response):
			state.employees = .init(response.state)
			state.filteredEmployees = state.employees
		case .failure:
			break
		}
		
	case .didSelectEmployee(let employeeId):
		
		state.chosenEmployeeId = employeeId
		
	case .didTapBackBtn:
		
		break
		
	}
	
	return .none
}
