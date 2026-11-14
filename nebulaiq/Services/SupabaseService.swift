import Foundation

enum SupabaseError: LocalizedError {
    case invalidURL
    case notAuthenticated
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Supabase URL configuration."
        case .notAuthenticated:
            return "User is not authenticated. Please log in again."
        case .httpError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .decodingError(let error):
            return "Data decoding failed: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network connection error: \(error.localizedDescription)"
        }
    }
}

actor SupabaseService {
    static let shared = SupabaseService()
    
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    init(session: URLSession = .shared) {
        self.session = session
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateStr)")
        }
        self.jsonDecoder = decoder
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder = encoder
    }
    
    func makeRequest(
        endpoint: String,
        method: String = "GET",
        accessToken: String? = nil,
        body: Data? = nil,
        headers: [String: String] = [:]
    ) throws -> URLRequest {
        guard let url = URL(string: endpoint, relativeTo: AppConfig.supabaseURL) else {
            throw SupabaseError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(AppConfig.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        for (key, val) in headers {
            request.setValue(val, forHTTPHeaderField: key)
        }
        
        request.httpBody = body
        return request
    }
    
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw SupabaseError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.httpError(statusCode: -1, message: "Invalid server response.")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMsg)
        }
        
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw SupabaseError.decodingError(error)
        }
    }
    
    func executeWithoutReturn(_ request: URLRequest) async throws {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw SupabaseError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.httpError(statusCode: -1, message: "Invalid server response.")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMsg)
        }
    }
}
