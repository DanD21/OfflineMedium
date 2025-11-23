//
//  SampleDataGenerator.swift
//  Offline Medium
//
//  Generates realistic sample data for portfolio demonstration
//  Shows: Data modeling, Swift features, functional programming
//

import Foundation

/// Generates realistic sample data for demonstration purposes
/// This showcases the app's functionality without requiring actual Medium content
actor SampleDataGenerator {

    // MARK: - Sample Content

    private let sampleTitles = [
        "Building a Modern iOS App with SwiftUI and Combine",
        "Understanding Actors in Swift 6: A Deep Dive",
        "From Callbacks to async/await: The Evolution of Async Programming",
        "MVVM Architecture in SwiftUI: Best Practices",
        "Dependency Injection Patterns for iOS Apps",
        "Type-Safe Programming in Swift: Beyond the Basics",
        "Mastering Combine: Reactive Programming in iOS",
        "SwiftUI Performance Optimization Techniques",
        "Building Accessible iOS Apps: A Comprehensive Guide",
        "The Art of Unit Testing in Swift",
        "Migrating Legacy Code to Swift 6",
        "Advanced Swift Concurrency Patterns",
        "Clean Architecture for iOS: A Practical Approach",
        "Understanding Memory Management in Modern Swift",
        "Building Offline-First iOS Applications"
    ]

    private let sampleAuthors = [
        "Sarah Chen", "Marcus Johnson", "Aisha Patel",
        "David Kim", "Emma Rodriguez", "James O'Brien",
        "Priya Sharma", "Alex Turner", "Maria Santos",
        "Ryan Mitchell"
    ]

    private let sampleIntros = [
        "In this article, we'll explore the fundamental concepts and practical applications...",
        "After years of building iOS apps, I've learned that the key to success lies in...",
        "Let me share a journey that transformed how I think about software architecture...",
        "The iOS development landscape has evolved dramatically, and with it...",
        "One of the most common challenges developers face is understanding how to..."
    ]

    private let sampleBodies = [
        """
        <article>
            <h1>{title}</h1>
            <p class="subtitle">A comprehensive guide to modern iOS development</p>

            <img src="sample-image-{index}.jpg" alt="Article header" />

            <p>{intro}</p>

            <h2>Understanding the Fundamentals</h2>
            <p>When approaching this topic, it's essential to understand the core concepts that underpin everything we'll discuss. These foundations will serve as building blocks for more advanced techniques.</p>

            <h2>Key Concepts</h2>
            <ul>
                <li>Modern Swift language features</li>
                <li>Architectural patterns and best practices</li>
                <li>Performance optimization strategies</li>
                <li>Testing and quality assurance</li>
            </ul>

            <h2>Practical Implementation</h2>
            <p>Let's dive into a practical example that demonstrates these concepts in action. This approach has been battle-tested in production apps serving millions of users.</p>

            <pre><code>
// Example code showcasing the concept
struct ExampleView: View {
    @StateObject private var viewModel: ViewModel

    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
        .task {
            await viewModel.loadData()
        }
    }
}
            </code></pre>

            <h2>Best Practices</h2>
            <p>Throughout my experience, I've found that following these principles leads to more maintainable and scalable code:</p>

            <blockquote>
            "Code is read more often than it is written. Optimize for readability and clarity above all else."
            </blockquote>

            <h2>Common Pitfalls</h2>
            <p>Avoid these common mistakes that can lead to technical debt and maintainability issues down the line.</p>

            <h2>Conclusion</h2>
            <p>By applying these techniques and principles, you'll be well-equipped to build robust, scalable iOS applications. Remember that learning is a continuous journey, and there's always more to discover.</p>

            <p><em>Thanks for reading! If you found this helpful, feel free to share it with others.</em></p>
        </article>
        """
    ]

    // MARK: - Generation Methods

    /// Generates a collection of sample posts
    func generateSamplePosts(count: Int = 15) -> [Post] {
        (0..<count).map { index in
            generatePost(index: index)
        }
    }

    /// Generates a single sample post
    private func generatePost(index: Int) -> Post {
        let title = sampleTitles[index % sampleTitles.count]
        let author = sampleAuthors[index % sampleAuthors.count]
        let intro = sampleIntros[index % sampleIntros.count]

        var html = sampleBodies[0]
            .replacingOccurrences(of: "{title}", with: title)
            .replacingOccurrences(of: "{intro}", with: intro)
            .replacingOccurrences(of: "{index}", with: "\(index)")

        var post = Post(postHtml: html)
        post.title = title
        post.postAuthor = author

        // Generate sample images
        post.postImages = generateSampleImages(count: 3, postIndex: index)
        if let firstImage = post.postImages.first {
            post.mainImage = firstImage
        }

        return post
    }

    /// Generates sample image references
    private func generateSampleImages(count: Int, postIndex: Int) -> [Image] {
        (0..<count).map { imageIndex in
            // Use SF Symbols or placeholder service
            let imageName = "sample-image-\(postIndex)-\(imageIndex).jpg"
            let documentsURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!
            let imageURL = documentsURL.appendingPathComponent(imageName)

            return Image(
                external: "https://via.placeholder.com/800x400/3B82F6/FFFFFF?text=Sample+Image+\(imageIndex + 1)",
                localUrl: imageURL
            )
        }
    }

    /// Generates sample Realm objects for database
    func generateSampleRealmPosts(count: Int = 15) -> [PostObj] {
        (0..<count).map { index in
            let post = PostObj()
            post.idPost = UUID().uuidString
            post.title = sampleTitles[index % sampleTitles.count]
            post.author = sampleAuthors[index % sampleAuthors.count]
            post.html = generateSampleHTML(index: index)
            post.mainImage = "sample-image-\(index)-0.jpg"

            // Add sample images
            for imageIndex in 0..<3 {
                let imageObj = ImagesObj()
                imageObj.imgUrl = "sample-image-\(index)-\(imageIndex).jpg"
                post.postImages.append(imageObj)
            }

            return post
        }
    }

    private func generateSampleHTML(index: Int) -> String {
        let title = sampleTitles[index % sampleTitles.count]
        let intro = sampleIntros[index % sampleIntros.count]

        return sampleBodies[0]
            .replacingOccurrences(of: "{title}", with: title)
            .replacingOccurrences(of: "{intro}", with: intro)
            .replacingOccurrences(of: "{index}", with: "\(index)")
    }
}

// MARK: - Demo Mode Configuration

/// Configuration for demo/portfolio mode
struct DemoConfiguration {
    /// Whether the app is running in demo mode
    static var isDemoMode: Bool {
        #if DEBUG
        return true
        #else
        return ProcessInfo.processInfo.environment["DEMO_MODE"] == "1"
        #endif
    }

    /// Number of sample posts to generate
    static let samplePostCount = 15

    /// Whether to show demo indicators in UI
    static let showDemoIndicators = true
}
