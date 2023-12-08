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
    @Binding var showSettings: Bool
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
        .onTapGesture {
            withAnimation {
                showSettings.toggle()
            }
        }
    }
}

// Main View
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var expenses: [ExpenseEntry] = []
    @State private var newAmount: String = ""
    @State private var newDetail: String = ""
    @State private var selectedIndex: Int = 0
    @State private var showSettings = false
    @State private var isAddCategoryActive = false
    @State private var isAddExpenseActive = false
    @State private var categories: [ExpenseCategory] = []
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    public init(categories: [ExpenseCategory]) {
        self._categories = State(initialValue: categories)
    }

    var body: some View {
        TabView {
            // Category Tab
            NavigationView {
                VStack {
                    CategoryManagementView(categories: $categories, addCategoryClosure: addCategory)
                }
                .navigationTitle("Categories")
            }
            .tabItem {
                Label("Categories", systemImage: "list.bullet.rectangle")
            }

            // Expense Tab
            NavigationView {
                VStack {
                    Form {
                        Section(header: Text("Expense")) {
                            Picker("Category", selection: $selectedIndex) {
                                ForEach(categories.indices, id: \.self) { index in
                                    Text("\(categories[index].name)")
                                        .foregroundColor(categories[index].color)
                                }
                            }
                            TextField("Amount", text: $newAmount)
                                .keyboardType(.decimalPad)
                            TextField("Detail", text: $newDetail)
                            Button("Add Expense") { addExpense() }
                        }

                        Section(header: Text("Expenses")) {
                            ForEach(expenses) { expense in
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(expense.category.name)")
                                                .foregroundColor(expense.category.color)
                                            Text("$\(expense.amount, specifier: "%.2f")")
                                                .foregroundColor(.secondary)
                                                .font(.headline)
                                        }

                                        Spacer()

                                        HStack {
                                            Button("Delete") {
                                                deleteExpense(expense)
                                            }
                                            .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(expense.category.color.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Expenses")
            }
            .tabItem {
                Label("Expenses", systemImage: "dollarsign.circle")
            }

            // Pie Chart Tab
            VStack {
                PieChartView(showSettings: $showSettings, expenses: expenses)
                    .padding()
            }
            .tabItem {
                Label("Pie Chart", systemImage: "chart.pie.fill")
            }

            // Settings Tab
            NavigationView {
                SettingsView(isDarkMode: $isDarkMode)
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func addCategory(name: String, color: Color) {
        let newCategory = ExpenseCategory(name: name, color: color)
        categories.append(newCategory)
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

    private func deleteExpense(_ expense: ExpenseEntry) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses.remove(at: index)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(categories: [ExpenseCategory(name: "Food", color: .blue), ExpenseCategory(name: "Entertainment", color: .green)])
    }
}

struct CategoryManagementView: View {
    @Binding var categories: [ExpenseCategory]
    @State private var newCategoryName: String = ""
    @State private var redValue: Double = 0.5
    @State private var greenValue: Double = 0.5
    @State private var blueValue: Double = 0.5

    var addCategoryClosure: (String, Color) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Categories")) {
                    ForEach(categories) { category in
                        VStack(alignment: .leading) {
                            Text("\(category.name)")
                                .foregroundColor(category.color)
                        }
                    }
                }

                Section(header: Text("Add New Category")) {
                    TextField("Name", text: $newCategoryName)
                    HStack {
                        Text("Red")
                        Slider(value: $redValue, in: 0...1, step: 0.01)
                    }
                    HStack {
                        Text("Green")
                        Slider(value: $greenValue, in: 0...1, step: 0.01)
                    }
                    HStack {
                        Text("Blue")
                        Slider(value: $blueValue, in: 0...1, step: 0.01)
                    }
                    Text("Color Preview")
                        .foregroundColor(Color(red: redValue, green: greenValue, blue: blueValue))
                    Button("Add Category") {
                        let newColor = Color(red: redValue, green: greenValue, blue: blueValue)
                        addCategoryClosure(newCategoryName, newColor)
                        newCategoryName = ""
                    }
                }
            }
        }
    }
}

// Settings View
struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
            }
        }
        .navigationTitle("Settings")
    }
}
