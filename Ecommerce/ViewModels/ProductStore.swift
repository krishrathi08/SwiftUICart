//
//  ProductStore.swift
//  Ecommerce
//
//  Manages product fetching, caching, pagination, filtering, and sorting
//

import Foundation
import SwiftUI

@MainActor
class ProductStore: ObservableObject {
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var featuredProducts: [Product] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var error: String?
    @Published var searchText: String = ""
    @Published var selectedCategory: String?
    @Published var selectedSort: SortOption = .popular
    @Published var filters: ProductFilters = ProductFilters()
    
    // MARK: - Pagination
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private let itemsPerPage: Int = 20
    
    var hasMorePages: Bool {
        currentPage < totalPages
    }
    
    // MARK: - Categories
    let categories: [String] = [
        "All",
        "Electronics",
        "Fashion",
        "Sports",
        "Home"
    ]
    
    // MARK: - Filtered Products
    var filteredProducts: [Product] {
        var result = products
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Category filter
        if let category = selectedCategory, category != "All" {
            result = result.filter { $0.category == category }
        }
        
        // Price range filter
        if let minPrice = filters.minPrice {
            result = result.filter { $0.price >= minPrice }
        }
        if let maxPrice = filters.maxPrice {
            result = result.filter { $0.price <= maxPrice }
        }
        
        // In stock filter
        if filters.inStockOnly {
            result = result.filter { $0.inStock }
        }
        
        // Sorting
        switch selectedSort {
        case .newest:
            // For demo, reverse order simulates newest
            result = result.reversed()
        case .priceAsc:
            result = result.sorted { $0.price < $1.price }
        case .priceDesc:
            result = result.sorted { $0.price > $1.price }
        case .rating:
            result = result.sorted { $0.rating > $1.rating }
        case .popular:
            result = result.sorted { $0.reviewCount > $1.reviewCount }
        }
        
        return result
    }
    
    // MARK: - Initialization
    init() {
        loadInitialData()
    }
    
    // MARK: - Data Loading
    // The demo deliberately publishes local sample data. Replace this path with
    // NetworkManager calls only after a real API contract is available.
    func loadInitialData() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Load sample products
            self.products = Product.sampleProducts
            
            // Set featured products (items with discounts)
            self.featuredProducts = Product.sampleProducts.filter { $0.originalPrice != nil }
            
            // Set pagination info
            self.totalPages = 3 // Simulated
            self.currentPage = 1
            
            self.isLoading = false
        }
    }
    
    func refresh() async {
        isLoading = true
        error = nil
        currentPage = 1
        
        // Simulate network request
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        products = Product.sampleProducts
        featuredProducts = Product.sampleProducts.filter { $0.originalPrice != nil }
        isLoading = false
    }
    
    func loadMoreProducts() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        
        // Simulate network request
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // This models pagination for the UI; it does not fetch a remote page.
        currentPage += 1
        
        // Simulate adding more products (duplicate with new IDs)
        let moreProducts = Product.sampleProducts.map { product in
            Product(
                id: product.id + (currentPage * 100),
                name: product.name,
                description: product.description,
                price: product.price,
                originalPrice: product.originalPrice,
                imageURL: product.imageURL,
                category: product.category,
                rating: product.rating,
                reviewCount: product.reviewCount,
                inStock: product.inStock,
                colors: product.colors,
                sizes: product.sizes
            )
        }
        
        products.append(contentsOf: moreProducts)
        isLoadingMore = false
    }
    
    // MARK: - Search
    func search(query: String) {
        searchText = query
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    // MARK: - Filtering
    func setCategory(_ category: String?) {
        selectedCategory = category == "All" ? nil : category
    }
    
    func applyFilters(_ newFilters: ProductFilters) {
        filters = newFilters
    }
    
    func resetFilters() {
        filters.reset()
        selectedCategory = nil
        selectedSort = .popular
    }
    
    // MARK: - Sorting
    func setSort(_ option: SortOption) {
        selectedSort = option
    }
    
    // MARK: - Product Details
    func product(withId id: Int) -> Product? {
        products.first { $0.id == id }
    }
    
    func relatedProducts(for product: Product, limit: Int = 4) -> [Product] {
        products
            .filter { $0.id != product.id && $0.category == product.category }
            .prefix(limit)
            .map { $0 }
    }
}
