
import Foundation

public func log<T>(
    _ object: T?,
    filename: String = #file,
    line: Int = #line,
    funcname: String = #function,
    text: String = "<-"
) {
    #if DEBUG
    guard let object = object else { return }
    print("***** \(Date()) \(filename.components(separatedBy: "/").last ?? "") (line: \(line)) :: \(funcname) :: \(object) :: \(text)")
    #endif
}
