//
//  OfflineMediumApp.swift
//  Offline Medium
//
//  Modern SwiftUI App structure with Dependency Injection
//  Replaces AppDelegate-based UIKit architecture
//

import SwiftUI

@main
struct OfflineMediumApp: App {

    // MARK: - Dependencies

    @StateObject private var appState = AppState()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    await appState.initialize()
                }
        }
    }
}

// MARK: - App State (Dependency Container)

@MainActor
class AppState: ObservableObject {

    // MARK: - Published Properties

    @Published var databaseActor: DatabaseActor?
    @Published var isInitialized = false
    @Published var initializationError: String?

    // MARK: - Initialization

    func initialize() async {
        do {
            // Initialize database actor
            let actor = try DatabaseActor()
            self.databaseActor = actor
            self.isInitialized = true
        } catch {
            self.initializationError = "Failed to initialize database: \(error.localizedDescription)"
        }
    }
}

// MARK: - Content View (Root View)

struct ContentView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            if appState.isInitialized, let databaseActor = appState.databaseActor {
                // Main app interface with dependency injection
                PostsListView(databaseActor: databaseActor)
            } else if let error = appState.initializationError {
                // Error state
                ErrorView(message: error)
            } else {
                // Loading state
                SplashView()
            }
        }
    }
}

// MARK: - Splash View

struct SplashView: View {

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading Offline Medium")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Error View

struct ErrorView: View {

    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Initialization Error")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState())
}
