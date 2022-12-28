import Foundation

struct Post: Decodable {
    let title: String
}

struct Service {
    @available(*, deprecated, message: "Replace for async/await `request` method")
    func request(completion: @escaping (Result<[Post], Error>) -> Void) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let _ = error {
                let error = NSError(domain: "any_domain", code: 0)
                completion(.failure(error))
            }
            
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode([Post].self, from: data!)
                completion(.success(decoded))
            } catch {
                let error = NSError(domain: "any_domain", code: 0)
                completion(.failure(error))
            }
        }.resume()
    }
    
    func request() async throws -> [Post] {
        return try await withCheckedThrowingContinuation { continuation in
            request { result in
                switch result {
                case .success(let posts):
                    continuation.resume(returning: posts)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

let service = Service()
service.request { print($0) }

Task {
    do {
        print(try await service.request())
    }
}
