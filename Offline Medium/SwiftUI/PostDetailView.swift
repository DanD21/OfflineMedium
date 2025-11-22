//
//  PostDetailView.swift
//  Offline Medium
//
//  Modern SwiftUI view replacing PostViewController
//

import SwiftUI
import WebKit

struct PostDetailView: View {

    // MARK: - Properties

    @StateObject private var viewModel: PostDetailViewModel

    // MARK: - Initialization

    init(post: PostData) {
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }

    // MARK: - Body

    var body: some View {
        WebView(htmlURL: viewModel.saveHTMLToFile())
            .navigationTitle(viewModel.post.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - WebView (WKWebView wrapper)

struct WebView: UIViewRepresentable {

    let htmlURL: URL?

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = htmlURL,
              let documentsDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
              ).first else {
            return
        }

        webView.loadFileURL(url, allowingReadAccessTo: documentsDirectory)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        PostDetailView(post: PostData(
            id: "1",
            title: "Sample Post",
            author: "Test Author",
            mainImage: "",
            html: "<html><body><h1>Sample Content</h1></body></html>"
        ))
    }
}
