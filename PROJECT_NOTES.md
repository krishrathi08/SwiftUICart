# SwiftCart Project Notes

This is a study companion for the current codebase. It intentionally distinguishes implemented behavior from backend-ready scaffolding.

## Architecture in one minute

SwiftCart follows an MVVM-inspired SwiftUI structure:

- **Models** describe product, cart, order, filter, pagination, and API data.
- **Views** render screens and send user actions to observable state objects.
- **View models** own presentation state and business rules: `ProductStore` handles the catalogue; `CartManager` handles cart mutations and totals.
- **Services** isolate HTTP request/response work in `NetworkManager`.

The app root owns both observable objects with `@StateObject`. It injects them using `.environmentObject(...)`, so child screens observe a single shared instance. Adding an item on a product-detail screen therefore updates the cart badge, cart screen, and checkout summary without passing the cart through every initializer.

The current app is not backend-driven: `ProductStore` loads `Product.sampleProducts`, and checkout creates a local order number after a delay. `NetworkManager` and the Codable response types show how a real integration can be added.

## Screen-by-screen flow

| Screen | File | What it does | State it uses |
| --- | --- | --- | --- |
| App root | `EcommerceApp.swift` | Creates and injects shared stores. | `@StateObject` |
| Tabs | `ContentView.swift` | Hosts Shop, Cart, and Profile stacks; shows cart badge. | `CartManager` |
| Product discovery | `Views/Products/ProductListView.swift` | Featured content, category chips, search, filters, sorting, layout toggle, and load-more. | `ProductStore`, local `@State` |
| Product details | `Views/Products/ProductDetailView.swift` | Selects options/quantity, adds to cart, shows related products. | Both stores, local `@State` |
| Cart | `Views/Cart/CartView.swift` | Displays lines, free-shipping progress, totals, and checkout navigation. | `CartManager` |
| Checkout | `Views/Checkout/CheckoutView.swift` | Pages through shipping, payment selection, review, and simulated placement. | `CartManager`, local `@State` |
| Confirmation | `Views/Checkout/OrderConfirmationView.swift` | Shows a generated order ID and animated success UI. | Local animation state |
| Profile | `Views/Profile/ProfileView.swift` | Displays a static sample profile and placeholder menu actions. | Local `@State` |

## Important types to know

| Type | Responsibility | Talking point |
| --- | --- | --- |
| `Product` | Product domain model and sample catalogue. | `Codable`, `Identifiable`, and `Hashable` support API decoding and SwiftUI navigation. |
| `ProductFilters` / `SortOption` | UI filter and sort inputs. | The sheet edits a local value copy and applies it when finished. |
| `ProductStore` | Catalogue state and derived display list. | `filteredProducts` is a computed projection, not another source of truth. |
| `CartItem` | Product plus selected variant and quantity. | The same product in different colours/sizes can be separate lines. |
| `CartManager` | Cart business rules and totals. | Derived totals eliminate synchronization bugs. |
| `ShippingAddress`, `OrderItem`, `Order` | Checkout/order data contracts. | They are encode/decode-ready though checkout is local today. |
| `NetworkManager` | Generic HTTP client. | One `fetch<T: Decodable>` shares request, validation, and decode logic. |
| `FlowLayout` | Wrapping filter-chip layout. | It demonstrates the SwiftUI `Layout` protocol. |

## Networking flow: current versus intended

### Current running flow

```text
ProductStore.init
  -> loadInitialData()
  -> short simulated delay
  -> Product.sampleProducts
  -> @Published products updates ProductListView

CheckoutView.placeOrder()
  -> 2-second simulated delay
  -> locally generated order ID
  -> CartManager.clearCart()
  -> OrderConfirmationView
```

### Backend-ready path (not currently invoked)

```text
View model
  -> NetworkManager.fetchProducts(...) / createOrder(...)
  -> URLComponents + URLRequest
  -> URLSession.data(for:)
  -> HTTP 2xx validation
  -> JSONDecoder (snake_case and ISO-8601 dates)
  -> typed Codable model or NetworkError
```

To make it real, inject a service into `ProductStore`, make its loading methods `async`, replace sample-product assignment with decoded products/pagination, and call `createOrder` from checkout. Error handling should drive the existing error/empty UI states.

## State management approach

- `@StateObject` gives the app root ownership of long-lived reference-type stores.
- `@EnvironmentObject` exposes shared stores to deeply nested views.
- `@Published` sends changes from `CartManager` and `ProductStore`.
- `@State` keeps screen-local concerns local: selected product options, form values, sheet visibility, and animations.
- `@Binding` lets `FilterSheet` receive and apply filters without owning `ProductStore`.
- Computed properties derive UI output from canonical state: `filteredProducts`, `itemCount`, `subtotal`, `shippingCost`, and `total`.

There is no persistence, remote synchronization, authentication state, or Combine pipeline in the active app.

## SwiftUI concepts demonstrated

- `NavigationStack`, value-based `NavigationLink`, and `navigationDestination(for:)`.
- `TabView` with a dynamic `.badge(...)`.
- `LazyVGrid`, `LazyVStack`, `List`, `ScrollView`, `sheet`, `confirmationDialog`, `refreshable`, and `safeAreaInset`.
- `@ViewBuilder` and extracted `some View` subviews for organization.
- `#Preview` with injected environment objects.
- Animations with `withAnimation`, transitions, spring/ease curves.
- A custom `Layout` that measures and wraps filter chips.
- A conditional UIKit import for haptic feedback.

## Interview-ready explanations

**Why use `@StateObject` at the app root?**  
It establishes one owner for each observable store. SwiftUI retains these objects across body recomputations, and all child views observe the same cart and catalogue state.

**Why is `filteredProducts` computed instead of stored?**  
The canonical state is the products plus filter inputs. Calculating the display list avoids keeping a duplicate list synchronized when search, filters, or sorting changes.

**How does the cart avoid duplicate variants?**  
`addToCart` compares product ID and selected colour/size. A match increases quantity; a different variant becomes a new line.

**How are totals kept correct?**  
They are computed from `items` each time. The app never mutates a stored subtotal separately, preventing stale totals after removal or quantity changes.

**How would you transition to real networking?**  
Inject a protocol-backed product/order service into the view models, call it with `async`/`await`, publish loading/error state on the main actor, and replace the sample and simulated-order paths.

**What are the project’s current limitations?**  
Products and profile data are samples; pagination and checkout are simulated; images are SF Symbols; profile actions are placeholders; cart data is not persisted; payment/order tracking are not real integrations.

## Likely codebase-specific interview questions

1. Trace what happens after tapping "Add to Cart" in `ProductDetailView`.
2. Explain `@StateObject` versus `@ObservedObject` versus `@EnvironmentObject` here.
3. Why is `ProductStore` annotated `@MainActor`?
4. How does `NavigationLink(value:)` work with `Product: Hashable`?
5. Why does `FilterSheet` use a local copy of `ProductFilters`?
6. How would you prevent concurrent or duplicate pagination requests?
7. Walk through `NetworkManager` error handling; what UI work remains?
8. How would you unit-test cart totals and variant merging?
9. What must change before accepting a real payment method or storing an auth token?
10. How would you make prices, taxes, and shipping rules production-ready for multiple locales?

## Suggested study order

1. Read `EcommerceApp.swift` and `ContentView.swift` for dependency flow.
2. Read `Product.swift`, `CartItem.swift`, and `Order.swift`.
3. Follow `ProductStore` into `ProductListView` and `ProductDetailView`.
4. Follow `CartManager` into `CartView` and `CheckoutView`.
5. Finish with `NetworkManager` and explain how to replace the demo paths safely.

Be ready to describe both what works now and what you would build next; that distinction is more credible than presenting the API scaffold as an active backend.
