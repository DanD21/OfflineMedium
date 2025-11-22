//
//  PostsListView.swift
//  Offline Medium
//
//  Modern SwiftUI view replacing HomeTableViewController
//

import SwiftUI

struct PostsListView: View {

    // MARK: - Properties

    @StateObject private var viewModel: PostsViewModel
    @State private var selectedPost: PostData?

    // MARK: - Constants

    private let mediumGreen = Color(red: 0.125490196078431, green: 0.701960784313725, blue: 0.576470588235294)

    // MARK: - Initialization

    init(databaseActor: DatabaseActor) {
        _viewModel = StateObject(wrappedValue: PostsViewModel(databaseActor: databaseActor))
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.posts.isEmpty {
                    emptyStateView
                } else {
                    postsList
                }

                if viewModel.isLoading {
                    ProgressView("Loading posts...")
                }
            }
            .navigationTitle("Offline Medium")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Search posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    refreshButton
                }
            }
            .task {
                await viewModel.loadPosts()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
        .accentColor(mediumGreen)
    }

    // MARK: - Subviews

    private var postsList: some View {
        List(viewModel.posts) { post in
            NavigationLink(destination: PostDetailView(post: post)) {
                PostRowView(post: post)
            }
            .listRowSeparator(.visible)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshPosts()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("You have no posts")
                .font(.headline)
                .foregroundColor(.gray)

            Text("Tap Login to sync your bookmarks")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var refreshButton: some View {
        Button(action: {
            Task {
                await viewModel.refreshPosts()
            }
        }) {
            Text(viewModel.posts.isEmpty ? "Login" : "Refresh")
        }
    }
}

// MARK: - Post Row View

struct PostRowView: View {

    let post: PostData

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            PostThumbnailView(imagePath: post.mainImage)
                .frame(width: 80, height: 80)
                .cornerRadius(8)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.headline)
                    .lineLimit(2)

                Text("By: \(post.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Post Thumbnail View

struct PostThumbnailView: View {

    let imagePath: String

    var body: some View {
        if let image = loadImage() {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
        }
    }

    private func loadImage() -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let fileName = (imagePath as NSString).lastPathComponent
        let imageURL = documentsDirectory.appendingPathComponent(fileName)

        return UIImage(contentsOfFile: imageURL.path)
    }
}

// MARK: - Preview

#Preview {
    let databaseActor = try! DatabaseActor()
    return PostsListView(databaseActor: databaseActor)
}
