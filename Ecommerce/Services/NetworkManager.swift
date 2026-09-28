//
//  NetworkManager.swift
//  Ecommerce
//
//  Backend-ready HTTP client for API requests with async/await.
//  The current UI uses local sample data and does not invoke this service yet.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case noData
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .noData:
            return "No data received"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.example.com/v1"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        
        session = URLSession(configuration: config)
        
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Generic Fetch
    
    func fetch<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        queryParams: [String: String]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        // Build URL with query parameters
        var urlComponents = URLComponents(string: baseURL + endpoint)
        
        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map { 
                URLQueryItem(name: $0.key, value: $0.value) 
            }
        }
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add custom headers
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Add body
        request.httpBody = body
        
        // Execute request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Check status code
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        // Decode response
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Product API
    
    func fetchProducts(
        page: Int = 1,
        limit: Int = 20,
        filters: ProductFilters? = nil,
        sort: SortOption? = nil
    ) async throws -> ProductListResponse {
        var params: [String: String] = [
            "page": String(page),
            "limit": String(limit)
        ]
        
        // Add filter params
        if let filters = filters {
            if let category = filters.category {
                params["category"] = category
            }
            if let minPrice = filters.minPrice {
                params["min_price"] = String(minPrice)
            }
            if let maxPrice = filters.maxPrice {
                params["max_price"] = String(maxPrice)
            }
            if filters.inStockOnly {
                params["in_stock"] = "true"
            }
            if !filters.searchQuery.isEmpty {
                params["search"] = filters.searchQuery
            }
        }
        
        // Add sort param
        if let sort = sort {
            params["sort"] = sort.rawValue
        }
        
        return try await fetch(endpoint: "/products", queryParams: params)
    }
    
    func fetchProduct(id: Int) async throws -> Product {
        return try await fetch(endpoint: "/products/\(id)")
    }
    
    // MARK: - Order API
    
    func createOrder(
        items: [OrderItem],
        shippingAddress: ShippingAddress,
        paymentMethod: PaymentMethod
    ) async throws -> Order {
        let orderRequest = OrderRequest(
            items: items,
            shippingAddress: shippingAddress,
            paymentMethod: paymentMethod
        )
        
        let body = try JSONEncoder().encode(orderRequest)
        
        return try await fetch(
            endpoint: "/orders",
            method: .post,
            body: body
        )
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Order Request
struct OrderRequest: Encodable {
    let items: [OrderItem]
    let shippingAddress: ShippingAddress
    let paymentMethod: PaymentMethod
}
