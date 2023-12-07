//
//  FinalApp.swift
//  Final
//
//  Created by pelin on 11/29/23.
//

import SwiftUI

@main
struct FinalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(categories: [
                ExpenseCategory(name: "Food", color: .yellow),
                ExpenseCategory(name: "Transport", color: .blue),
                ExpenseCategory(name: "Entertainment", color: .red),
                ExpenseCategory(name: "Utilities", color: .green),
                ExpenseCategory(name: "Shopping", color: .pink.opacity(0.3)),
                ExpenseCategory(name: "Health", color: .brown)
                // Add other categories as needed
            ])
        }
    }
}
