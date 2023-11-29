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
                ExpenseCategory(name: "Food", color: .yellow, emoji: "🍔"),
                ExpenseCategory(name: "Transport", color: .blue, emoji: "🚗"),
                ExpenseCategory(name: "Entertainment", color: .red, emoji: "🎬"),
                ExpenseCategory(name: "Utilities", color: .green, emoji: "💡"),
                ExpenseCategory(name: "Shopping", color: .pink.opacity(0.3), emoji: "🛍️"),
                ExpenseCategory(name: "Health", color: .brown, emoji: "💊")
                // Add other categories as needed
            ])
        }
    }
}
