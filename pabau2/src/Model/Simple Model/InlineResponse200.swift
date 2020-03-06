//
// InlineResponse200.swift

import Foundation


public struct InlineResponse200: Codable {

    public let rota: [Shift]?

    public let termins: [Termin]?
    public init(rota: [Shift]? = nil, termins: [Termin]? = nil) { 
        self.rota = rota
        self.termins = termins
    }

}
