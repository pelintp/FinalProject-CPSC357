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

// Pie Slice View for Pie Chart
struct PieSliceView: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width: CGFloat = min(geometry.size.width, geometry.size.height)
                let height = width

                let center = CGPoint(x: width * 0.5, y: height * 0.5)
                let radius = width * 0.5

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
        let totalAmount = expenses.reduce(0) { $0 + $1.amount }
        var startAngle = Angle(degrees: 0)

        for expense in expenses {
            let normalizedAmount = (expense.amount / totalAmount)
            let endAngle = startAngle + Angle(degrees: normalizedAmount * 360)
            slices.append(PieSliceView(startAngle: startAngle, endAngle: endAngle, color: expense.category.color))
            startAngle = endAngle
        }
        
        return slices
    }

    var body: some View {
        ZStack {
            ForEach(0..<slices.count, id: \.self) { index in
                self.slices[index]
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// Main ContentView
struct ContentView: View {
    @State private var categories = [
        ExpenseCategory(name: "Food", color: .yellow, emoji: "🍔"),
        ExpenseCategory(name: "Transport", color: .blue, emoji: "🚗"),
        ExpenseCategory(name: "Entertainment", color: .red, emoji: "🎬"),
        ExpenseCategory(name: "Utilities", color: .green, emoji: "💡"),
        ExpenseCategory(name: "Shopping", color: Color.pink.opacity(0.3), emoji: "🛍️"),
        ExpenseCategory(name: "Health", color: .brown, emoji: "💊")
    ]
    
    @State private var expenses: [ExpenseEntry] = []
    @State private var newExpenseAmount: String = ""
    @State private var newExpenseDetail: String = ""
    @State private var selectedCategoryIndex: Int = 0

    var body: some View {
        NavigationView {
            VStack {
                // Pie Chart
                PieChartView(expenses: expenses)
                    .padding()
                
                // Expense Input Form
                Form {
                    Picker("Category", selection: $selectedCategoryIndex) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            Text("\(self.categories[index].emoji) \(self.categories[index].name)").tag(index)
                        }
                    }
                    TextField("Amount", text: $newExpenseAmount)
                        .keyboardType(.decimalPad)
                    TextField("Detail (Optional)", text: $newExpenseDetail)
                    Button("Add Expense") {
                        addExpense()
                    }
                }

                // Scrollable List of Expenses
                List {
                    ForEach(expenses) { expense in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(expense.category.emoji) \(expense.category.name)")
                                    .foregroundColor(expense.category.color)
                                Spacer()
                                Text("$\(expense.amount, specifier: "%.2f")")
                            }
                            if let detail = expense.detail, !detail.isEmpty {
                                Text(detail)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(expense.category.color.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Expenses")
        }
    }
    
    // Function to Add a New Expense
    private func addExpense() {
        let category = categories[selectedCategoryIndex]
        if let amount = Double(newExpenseAmount) {
            let newExpense = ExpenseEntry(category: category, amount: amount, detail: newExpenseDetail.isEmpty ? nil : newExpenseDetail)
            expenses.append(newExpense)
            newExpenseAmount = ""
            newExpenseDetail = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
