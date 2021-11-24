import Foundation

struct URLLoadingError: Error {
    var request: URLRequest
    var status: Int?
}
extension URLLoadingError: LocalizedError {
    var errorDescription: String? {
        "\(request) failed: \(status ?? "bogus response" as Any)"
    }
}

// with macOS 12 we could use async/await and URLSession.data(for:).
// Alas, GitHub Actions only has macOS 11.
func perform(request: URLRequest) throws -> Data {
    var result: Result<Data, Error>!
    let semaphore = DispatchSemaphore(value: 0)
    
    URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        .dataTask(with: request) { data, response, error in
            result = Result {
                if let error = error {
                    throw error
                }
                let status = (response as? HTTPURLResponse)?.statusCode
                guard let data = data, status.map((200...299).contains(_:)) != false else {
                    throw URLLoadingError(request: request, status: status)
                }
                return data
            }
            semaphore.signal()
        }
        .resume()
    
    semaphore.wait()
    return try result.get()
}

func get(url: URL) throws -> Data {
    return try perform(request: URLRequest(url: url))
}
