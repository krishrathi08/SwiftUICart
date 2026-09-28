# SwiftCart

SwiftCart is a native iOS e-commerce demo built with SwiftUI. It is a study project for exploring a practical shopping flow: browse a local product catalogue, search and filter it, configure a product, manage a shared cart, and complete a simulated checkout.

> **Current data mode:** the running app uses bundled sample data and simulated delays. `NetworkManager` is an async/await API-client scaffold for a future backend, but it is not wired into the active product or order flows.

## Features

- Browse featured products in grid or list layouts.
- Search locally by product name, description, or category.
- Filter by category, price range, and availability; sort by popularity, rating, price, or demo "newest" order.
- View product details, choose available colour/size variants, adjust quantity, share a product name, and add items to the cart.
- Maintain a shared in-memory cart with variant-aware lines, quantity controls, swipe-to-delete, totals, tax, and a free-shipping threshold.
- Complete a three-step simulated checkout: shipping address, payment-method selection, review, and confirmation.
- Reuse loading, empty, error, filter-chip, and custom-layout components.

## Tech stack

| Area | Implementation |
| --- | --- |
| Language and UI | Swift 5, SwiftUI |
| Architecture | MVVM-inspired views, observable state, models, and services |
| Concurrency | Swift `async`/`await`, `Task`, and `@MainActor` |
| State | `@StateObject`, `@EnvironmentObject`, `@Published`, `@State`, `@Binding` |
| Networking scaffold | `URLSession`, `URLComponents`, `Codable`, `JSONDecoder` |
| Tooling | Xcode / XcodeGen (`project.yml`) |
| Dependencies | None; native Apple frameworks only |

The project configuration targets iOS 18. Use an Xcode version that supports that SDK.

## Architecture

```text
SwiftUI Views
    |  observe / send intents
    v
ProductStore, CartManager
    |  work with
    v
Product, CartItem, Order models     NetworkManager (backend-ready scaffold)
```

`EcommerceApp` creates one `CartManager` and one `ProductStore` with `@StateObject`, then injects them at the root. Descendant views read the same instances with `@EnvironmentObject`, so a cart update immediately refreshes the tab badge, product cards, cart, and checkout summary.

## Project structure

```text
Ecommerce/
├── EcommerceApp.swift             App entry point and shared-state injection
├── ContentView.swift              Root tab navigation
├── Models/                        Codable domain and API-contract types
├── ViewModels/
│   ├── ProductStore.swift         Catalogue, local search/filter/sort, demo pagination
│   └── CartManager.swift          Cart mutations and derived totals
├── Services/
│   └── NetworkManager.swift       Generic async HTTP client and endpoint helpers
├── Views/
│   ├── Products/                  Discovery, cards, and detail screen
│   ├── Cart/                      Cart list and quantity controls
│   ├── Checkout/                  Simulated checkout and confirmation
│   └── Profile/                   Static profile presentation
├── Components/                    Reusable loading, empty-state, and filter UI
└── Utils/Constants.swift          Theme, reusable modifiers, and helpers
```

## Important implementation details

- `ProductStore.filteredProducts` derives the displayed catalogue from products, search text, category, filters, and sort selection.
- `CartManager.addToCart` treats product ID plus selected colour and size as a cart-line identity. Matching selections increase quantity rather than duplicate a line.
- Cart subtotal, tax (8%), shipping ($9.99 below $100), and total are computed from `items`; they are never independently stored.
- `ProductStore` is `@MainActor`. Its loading and pagination are deliberately simulated with delays and sample products using new IDs.
- Checkout validates required shipping fields, then generates a local order number after a simulated processing delay. It does not submit payment details or create a remote order.
- `FlowLayout` demonstrates a custom SwiftUI `Layout` for wrapping filter chips.

## Networking and state management

`NetworkManager` centralizes URL construction, request configuration, HTTP status validation, and `Codable` decoding. It supports generic requests, query parameters, a snake-case decoder, ISO-8601 dates, and typed errors. Its base URL is a placeholder (`https://api.example.com/v1`), so it will not provide a working backend unchanged.

The active app uses `Product.sampleProducts`. To connect a backend, replace sample-data paths in `ProductStore` and simulated order creation in `CheckoutView` with `NetworkManager` calls, then surface loading and error states in the UI.

Cart state is session-only: it is shared for the app process and is not saved to disk.

## Main user flow

1. Launch into **Shop**; `ProductStore` loads sample products.
2. Browse products; search, filter, sort, or switch grid/list presentation.
3. Open a product, select its available options and quantity, then add it to the cart.
4. Adjust or remove cart lines and review calculated totals.
5. Enter a shipping address, choose a payment method, review, and place the simulated order.
6. See a generated order number and return to shopping.

## Run locally

1. Open `Ecommerce.xcodeproj` in Xcode.
2. Select an iOS simulator or device.
3. Build and run (`Cmd + R`).

`project.yml` is included for regenerating the project with XcodeGen. There is currently no test target; exercise the flow manually after changes.

## Future improvements

- Connect a real products/orders backend and map its response contract.
- Add dependency injection and protocol-based service mocking for unit tests.
- Persist cart and profile state safely; add authentication only with a real backend and Keychain storage.
- Add real product images, accessibility labels, localization, and currency/locale formatting.
- Implement profile menu destinations, order tracking, favorites, and production-grade form/payment validation.

## Study guide

See [PROJECT_NOTES.md](PROJECT_NOTES.md) for a codebase-specific architecture walkthrough, data-flow guide, and interview-practice questions.

## Attribution and license

This repository is derived from the original [yxshee/swiftcart](https://github.com/yxshee/swiftcart) project. The original MIT license and copyright notice are preserved in [LICENSE](LICENSE). Review the code and make substantive, truthful contributions before presenting it as part of your portfolio.
