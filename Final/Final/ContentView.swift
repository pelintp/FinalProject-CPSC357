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

struct CategoryManagementView: View {
    @Binding var categories: [ExpenseCategory]
    @State private var newCategoryName: String = ""
    @State private var newCategoryColor: String = ""
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
                    .onDelete(perform: deleteCategory)
                }

                Section(header: Text("Add New Category")) {
                    TextField("Name", text: $newCategoryName)
                    TextField("Color", text: $newCategoryColor)
                    Button("Add Category") {
                        let colorName = Color.fromString(newCategoryColor)
                        addCategoryClosure(newCategoryName, colorName)
                        newCategoryName = ""
                        newCategoryColor = ""
                    }
                }
            }
            .navigationTitle("Category Management")
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }
}

extension Color {
    static func fromString(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "Red": return .red
        case "green": return .green
        case "Green": return .green
        case "blue": return .blue
        case "Blue": return .blue
        case "yellow": return .yellow
        case "Yellow": return .yellow
        case "orange": return .orange
        case "Orange": return .orange
        case "pink": return .pink
        case "Pink": return .pink
        case "purple": return .purple
        case "Purple": return .purple
        case "brown": return .brown
        case "Brown": return .brown
        case "gray": return .gray
        case "Gray": return .gray
        case "black": return .black
        case "Black": return .black
        case "white": return .white
        case "White": return .white
        default: return .clear
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
                        set: { isDarkMode in
                            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                                windowScene.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                            }
                        }
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


