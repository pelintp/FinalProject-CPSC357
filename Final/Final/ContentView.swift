//
//  ContentView.swift
//  Final
//
//  Created by pelin on 11/29/23.
//

import SwiftUI

// Expense Category Structure
struct ExpenseCategory: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: Color
    var emoji: String
}

// Expense Entry Structure
struct ExpenseEntry: Identifiable {
    let id = UUID()
    var category: ExpenseCategory
    var amount: Double
    var detail: String?
}

// Pie Slice View
struct PieSliceView: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width: CGFloat = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: width / 2, y: width / 2)
                let radius = width / 2

                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

// Pie Chart View
struct PieChartView: View {
    var expenses: [ExpenseEntry]

    private var slices: [PieSliceView] {
        var slices = [PieSliceView]()
        let total = expenses.reduce(0) { $0 + $1.amount }
        var startAngle = Angle(degrees: 0)

        for expense in expenses {
            let normalized = expense.amount / total
            let endAngle = startAngle + Angle(degrees: normalized * 360)
            slices.append(PieSliceView(startAngle: startAngle, endAngle: endAngle, color: expense.category.color))
            startAngle = endAngle
        }
        
        return slices
    }

    var body: some View {
        ZStack {
            ForEach(slices.indices, id: \.self) { index in
                slices[index]
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// Main View
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var categories: [ExpenseCategory]
    @State private var expenses: [ExpenseEntry] = []
    @State private var newAmount: String = ""
    @State private var newDetail: String = ""
    @State private var selectedIndex: Int = 0
    @State private var showSettings = false

    public init(categories: [ExpenseCategory]) {
        self._categories = State(initialValue: categories)
    }

    var body: some View {
        NavigationView {
            VStack {
                PieChartView(expenses: expenses)
                    .padding()

                Form {
                    Picker("Category", selection: $selectedIndex) {
                        ForEach(categories.indices, id: \.self) { index in
                            Text("\(categories[index].emoji) \(categories[index].name)")
                        }
                    }
                    TextField("Amount", text: $newAmount)
                        .keyboardType(.decimalPad)
                    TextField("Detail", text: $newDetail)
                    Button("Add Expense") { addExpense() }
                }

                List(expenses) { expense in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(expense.category.emoji) \(expense.category.name)")
                                .foregroundColor(expense.category.color)
                            Spacer()
                            Text("$\(expense.amount, specifier: "%.2f")")
                        }
                        if let detail = expense.detail {
                            Text(detail).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(expense.category.color.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private func addExpense() {
        let category = categories[selectedIndex]
        if let amount = Double(newAmount) {
            let newExpense = ExpenseEntry(category: category, amount: amount, detail: newDetail.isEmpty ? nil : newDetail)
            expenses.append(newExpense)
            newAmount = ""
            newDetail = ""
        }
    }
}

// Settings View
struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: Binding(
                        get: { colorScheme == .dark },
                        set: { _ in /* Toggle Dark Mode Here */ }
                    ))
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


