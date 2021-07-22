import CoreStore
import Model
import Util
import ComposableArchitecture

public class PathwayTemplateScheme: CoreStoreObject {
    @Field.Stored("id")
    public var id: String = ""
    
    @Field.Stored("title")
    public var title: String = ""
    
    @Field.Relationship("steps", inverse: \StepScheme.$master)
    var steps: Set<StepScheme>
    
    @Field.Stored("descript")
    public var descript: String = ""
}

extension PathwayTemplate {
    public static func convert(
        from schemes: [PathwayTemplateScheme]
    ) -> IdentifiedArrayOf<PathwayTemplate> {
        
        let array: [PathwayTemplate] = schemes.compactMap { sheme in
            PathwayTemplate(
                id: PathwayTemplate.ID(rawValue: EitherStringOrInt.left(sheme.id)),
                title: sheme.title,
                steps: sheme.steps.compactMap { stepSheme in
                    Step(
						id: Step.Id(rawValue: .left(stepSheme.id)),
                        stepType: StepType(rawValue: stepSheme.stepType) ?? .photos,
                        preselectedTemplate: stepSheme.formTemplateID == "0" ?
                            .definedbyservice :
                            .template(HTMLForm.ID(rawValue: .left(stepSheme.formTemplateID))),
                        canSkip: stepSheme.canSkip)
                },
                _description: sheme.descript
            )
        }
        
        return IdentifiedArrayOf(array)
    }
    public func save(to store: CoreDataModel) {
        store.dataStack.perform { (transaction) -> PathwayTemplateScheme? in
            let pathwayTemplateScheme = transaction.create(Into<PathwayTemplateScheme>())
            pathwayTemplateScheme.id = self.id.description
            pathwayTemplateScheme.title = self.title
            let stepsShemes: [StepScheme] = self.steps.compactMap {
                let scheme = transaction.create(Into<StepScheme>())
                scheme.id = $0.id.description
                scheme.stepType = $0.stepType.rawValue
                scheme.master = pathwayTemplateScheme
                switch $0.preselectedTemplate {
                case .template(let id):
                    scheme.formTemplateID = id.description
                default:
                    scheme.formTemplateID = "0"
                }
                return scheme
            }
            pathwayTemplateScheme.steps = Set(stepsShemes)
            pathwayTemplateScheme.descript = self._description ?? ""
            return pathwayTemplateScheme
        } completion: { (result) in
            log(result, text: "LocationScheme created")
        }
    }
}
