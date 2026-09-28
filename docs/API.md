# API Integration Notes

## Status

The shipped app currently runs on `Product.sampleProducts` and simulates refresh, pagination, and order placement. No HTTP request is made by the active UI.

`Ecommerce/Services/NetworkManager.swift` is a backend-ready `URLSession` client. Its placeholder base URL is `https://api.example.com/v1`; replace it and connect the view-model/checkout call sites before treating the following routes as an active API.

## Client behavior

`NetworkManager.fetch<T: Decodable>`:

- builds URLs with `URLComponents` and optional query parameters;
- sends JSON `Accept` and `Content-Type` headers;
- accepts only HTTP 2xx responses;
- decodes snake_case keys and ISO-8601 dates; and
- throws typed `NetworkError` values for invalid URLs/responses, non-2xx status codes, and decoding errors.

## Expected product endpoint

```http
GET /products?page=1&limit=20&category=Electronics&min_price=50&max_price=250&in_stock=true&search=headphones&sort=price_asc
```

The client can send these query parameters:

| Parameter | Source |
| --- | --- |
| `page`, `limit` | Pagination arguments |
| `category`, `min_price`, `max_price`, `in_stock`, `search` | `ProductFilters` |
| `sort` | `SortOption` |

The endpoint must decode into the codebase's `ProductListResponse`:

```json
{
  "products": [
    {
      "id": 1,
      "name": "Premium Wireless Headphones",
      "description": "...",
      "price": 199.99,
      "original_price": 299.99,
      "image_url": "https://example.com/headphones.jpg",
      "category": "Electronics",
      "rating": 4.8,
      "review_count": 2459,
      "in_stock": true,
      "colors": ["Black"],
      "sizes": null
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 1,
    "total_items": 1,
    "items_per_page": 20
  },
  "filters": null
}
```

## Expected order endpoint

```http
POST /orders
Content-Type: application/json
```

`NetworkManager.createOrder(items:shippingAddress:paymentMethod:)` encodes the existing `OrderRequest` type and expects an `Order` response. The present checkout screen does not invoke this method and does not collect card details.

## Integration checklist

1. Configure a real base URL outside source control for each environment.
2. Confirm server response keys match the Codable models, or add explicit `CodingKeys`.
3. Inject the networking dependency into `ProductStore`; replace sample-data and simulated-pagination paths.
4. Call `createOrder` from checkout and show loading/error/success states.
5. Add authentication, secure token storage, retries, and tests only when the backend requirements are defined.
