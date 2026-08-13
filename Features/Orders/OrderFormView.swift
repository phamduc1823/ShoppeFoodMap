import SwiftUI

public struct OrderFormView: View {
    @Bindable var viewModel: OrderListViewModel
    public let onOrderCreated: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var orderNumber = "ORD-\(Int.random(in: 1000...9999))"
    @State private var restaurantName = "Restaurant A"
    @State private var restaurantAddress = "54 Hoan Kiem, Hanoi"
    @State private var customerName = "Customer A"
    @State private var customerAddress = "12 Ba Dinh, Hanoi"
    
    @State private var pickupReadyAt = Date().addingTimeInterval(300)
    @State private var deliveryWindowStart = Date().addingTimeInterval(1800)
    @State private var deliveryWindowEnd = Date().addingTimeInterval(2400)
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    public init(viewModel: OrderListViewModel, onOrderCreated: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onOrderCreated = onOrderCreated
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                Form {
                    Section("Order Information") {
                        TextField("Order Number", text: $orderNumber)
                    }
                    
                    Section("Pickup (Restaurant)") {
                        TextField("Restaurant Name", text: $restaurantName)
                        TextField("Restaurant Address", text: $restaurantAddress)
                        DatePicker("Food Ready At", selection: $pickupReadyAt, displayedComponents: [.hourAndMinute])
                    }
                    
                    Section("Delivery (Customer)") {
                        TextField("Customer Name", text: $customerName)
                        TextField("Customer Address", text: $customerAddress)
                        DatePicker("Window Start", selection: $deliveryWindowStart, displayedComponents: [.hourAndMinute])
                        DatePicker("Window End (Deadline)", selection: $deliveryWindowEnd, displayedComponents: [.hourAndMinute])
                    }
                    
                    if let err = errorMessage {
                        Section {
                            Text(err)
                                .foregroundColor(AppTheme.statusRed)
                                .font(.caption)
                        }
                    }
                    
                    Section {
                        Button(action: submitOrder) {
                            if isSubmitting {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Create Food Order")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .listRowBackground(AppTheme.primaryOrange)
                        .disabled(isSubmitting)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Delivery Order")
            .inlineNavigationBarTitle()
            .toolbar {
                ToolbarItem(placement: .platformTopBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func submitOrder() {
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                try await viewModel.createOrder(
                    orderNumber: orderNumber,
                    restaurantName: restaurantName,
                    restaurantAddress: restaurantAddress,
                    customerName: customerName,
                    customerAddress: customerAddress,
                    deliveryWindowStart: deliveryWindowStart,
                    deliveryWindowEnd: deliveryWindowEnd,
                    pickupReadyAt: pickupReadyAt,
                    estimatedPreparationTime: 600
                )
                onOrderCreated()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
