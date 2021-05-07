import CoreStore
import Model
import Util


public class StepScheme: CoreStoreObject {
    @Field.Relationship("master")
    var master: PathwayTemplateScheme?
    
    @Field.Stored("id")
    public var id: String = ""
    
    @Field.Stored("stepType")
    public var stepType: String = ""
    
    @Field.Stored("form_template_id")
    public var formTemplateID: String = ""
}
