import Foundation
import JavaScriptCore

enum StyleParser {
    static func parse(text: String) -> [String: Any]? {
        let context = JSContext()
        let jsResult = context?.evaluateScript("""
var result = \(text);
result;
""")
        let rawResult = jsResult.flatMap {
            $0.isObject ? $0.toDictionary() : nil
        }
        let resultWithStringKeys = rawResult?.map { (key, value) in
            (String(describing: key), value)
        }
        return resultWithStringKeys.map {
            .init($0, uniquingKeysWith: { (first, _) in first })
        }
    }
}
