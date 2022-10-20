import Foundation
import JavaScriptCore

enum StyleParser {
    
    static var lastException: String? = nil
    
    static func parse(text: String) -> [String: Any]? {
        lastException = nil
        let context = JSContext()
        let jsString = """
            var result = \(text);
            result;
        """
        print("jsEvaluation of: \(jsString)")
        let jsResult = context?.evaluateScript(jsString)
        
        //Tell the user about the error - it must be a JSON!
        if let exception = context?.exception, let string = exception.toString(), !string.isEmpty {
            lastException = string
            return nil
        }
        
        let rawResult = jsResult.flatMap {
            $0.isObject ? $0.toDictionary() : nil
        }
        if rawResult == nil {
            lastException = "Style must be a JSON object"
            return nil
        }
        let resultWithStringKeys = rawResult?.map { (key, value) in
            (String(describing: key), value)
        }
        return resultWithStringKeys.map {
            .init($0, uniquingKeysWith: { (first, _) in first })
        }
    }
}
