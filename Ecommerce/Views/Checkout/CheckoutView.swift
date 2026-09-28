//
//  CheckoutView.swift
//  Ecommerce
//

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var shippingAddress = ShippingAddress.empty
    @State private var selectedPaymentMethod: PaymentMethod = .creditCard
    @State private var isProcessing = false
    @State private var showOrderConfirmation = false
    @State private var orderId = ""
    @State private var currentStep = 0
    
    private let steps = ["Shipping", "Payment", "Review"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Steps
            progressIndicator
                .padding()
            
            // Content
            TabView(selection: $currentStep) {
                shippingStep
                    .tag(0)
                
                paymentStep
                    .tag(1)
                
                reviewStep
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)
            
            // Bottom Button
            bottomButton
                .padding()
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isProcessing)
        .navigationDestination(isPresented: $showOrderConfirmation) {
            OrderConfirmationView(orderId: orderId)
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 0) {
            ForEach(0..<steps.count, id: \.self) { index in
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                index <= currentStep ?
                                LinearGradient(
                                    colors: [.gradientStart, .gradientEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        if index < currentStep {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundColor(index <= currentStep ? .white : .secondary)
                        }
                    }
                    
                    Text(steps[index])
                        .font(.caption.weight(.medium))
                        .foregroundColor(index <= currentStep ? .primary : .secondary)
                }
                
                if index < steps.count - 1 {
                    Rectangle()
                        .fill(index < currentStep ? Color.gradientStart : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .padding(.horizontal, 4)
                }
            }
        }
    }
    
    // MARK: - Shipping Step
    private var shippingStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Shipping Address")
                        .font(.headline)
                    
                    CustomTextField(
                        title: "Full Name",
                        text: $shippingAddress.fullName,
                        icon: "person"
                    )
                    
                    CustomTextField(
                        title: "Street Address",
                        text: $shippingAddress.streetAddress,
                        icon: "location"
                    )
                    
                    HStack(spacing: 12) {
                        CustomTextField(
                            title: "City",
                            text: $shippingAddress.city,
                            icon: "building.2"
                        )
                        
                        CustomTextField(
                            title: "State",
                            text: $shippingAddress.state,
                            icon: "map"
                        )
                        .frame(width: 100)
                    }
                    
                    HStack(spacing: 12) {
                        CustomTextField(
                            title: "ZIP Code",
                            text: $shippingAddress.zipCode,
                            icon: "number"
                        )
                        .keyboardType(.numberPad)
                        
                        CustomTextField(
                            title: "Country",
                            text: $shippingAddress.country,
                            icon: "globe"
                        )
                    }
                    
                    CustomTextField(
                        title: "Phone Number",
                        text: $shippingAddress.phoneNumber,
                        icon: "phone"
                    )
                    .keyboardType(.phonePad)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Payment Step
    private var paymentStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Payment Method")
                    .font(.headline)
                
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    Button(action: { selectedPaymentMethod = method }) {
                        HStack(spacing: 16) {
                            Image(systemName: method.icon)
                                .font(.title2)
                                .foregroundColor(.gradientStart)
                                .frame(width: 44, height: 44)
                                .background(Color.gradientStart.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Text(method.rawValue)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: selectedPaymentMethod == method ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(selectedPaymentMethod == method ? .gradientStart : .secondary)
                        }
                        .padding()
                        .background(Color.appSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedPaymentMethod == method ? Color.gradientStart : Color.clear, lineWidth: 2)
                        )
                    }
                }
                
                // Secure Payment Note
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                    Text("Your payment information is secure and encrypted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
    
    // MARK: - Review Step
    private var reviewStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Order Items
                VStack(alignment: .leading, spacing: 12) {
                    Text("Order Items")
                        .font(.headline)
                    
                    ForEach(cartManager.items) { item in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.appSecondaryBackground)
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: "bag")
                                        .foregroundColor(.secondary)
                                }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.product.name)
                                    .font(.subheadline.weight(.medium))
                                    .lineLimit(1)
                                Text("Qty: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(item.formattedTotalPrice)
                                .font(.subheadline.weight(.medium))
                        }
                    }
                }
                .padding()
                .background(Color.appSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Shipping Address Summary
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Shipping Address")
                            .font(.headline)
                        Spacer()
                        Button("Edit") { currentStep = 0 }
                            .font(.subheadline)
                    }
                    
                    Text(shippingAddress.fullName)
                        .font(.subheadline)
                    Text(shippingAddress.formattedAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Payment Method Summary
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Payment Method")
                            .font(.headline)
                        Spacer()
                        Button("Edit") { currentStep = 1 }
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: selectedPaymentMethod.icon)
                            .foregroundColor(.gradientStart)
                        Text(selectedPaymentMethod.rawValue)
                            .font(.subheadline)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Order Total
                VStack(spacing: 12) {
                    HStack {
                        Text("Subtotal")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(cartManager.formattedSubtotal)
                    }
                    HStack {
                        Text("Shipping")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(cartManager.formattedShipping)
                            .foregroundColor(cartManager.shippingCost == 0 ? .green : .primary)
                    }
                    HStack {
                        Text("Tax")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(cartManager.formattedTax)
                    }
                    Divider()
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(cartManager.formattedTotal)
                            .font(.title2.weight(.bold))
                            .foregroundColor(.gradientStart)
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color.appSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        Button(action: handleButtonTap) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                    if currentStep < 2 {
                        Image(systemName: "arrow.right")
                    }
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: canProceed ? [.gradientStart, .gradientEnd] : [.gray, .gray],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canProceed || isProcessing)
    }
    
    private var buttonTitle: String {
        switch currentStep {
        case 0: return "Continue to Payment"
        case 1: return "Review Order"
        default: return "Place Order"
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !shippingAddress.fullName.isEmpty &&
                   !shippingAddress.streetAddress.isEmpty &&
                   !shippingAddress.city.isEmpty &&
                   !shippingAddress.zipCode.isEmpty
        default:
            return true
        }
    }
    
    private func handleButtonTap() {
        if currentStep < 2 {
            withAnimation(.easeInOut) {
                currentStep += 1
            }
        } else {
            placeOrder()
        }
    }
    
    private func placeOrder() {
        isProcessing = true
        
        // Demo-only order completion. No payment is charged or order submitted.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            orderId = "ORD-\(Int.random(in: 100000...999999))"
            cartManager.clearCart()
            isProcessing = false
            showOrderConfirmation = true
        }
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField(title, text: $text)
                    .font(.subheadline)
            }
            .padding()
            .background(Color.appSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
    }
    .environmentObject(CartManager())
}
