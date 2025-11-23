//
//  RecentPostsWidget.swift
//  Offline Medium
//
//  WidgetKit implementation showing recent saved posts
//  Showcases: WidgetKit, Timeline Provider, SwiftUI in widgets
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry

struct RecentPostsEntry: TimelineEntry {
    let date: Date
    let posts: [PostData]
    let configuration: RecentPostsConfiguration
}

struct RecentPostsConfiguration {
    var displayMode: DisplayMode = .titles

    enum DisplayMode {
        case titles
        case titlesWithAuthors
        case preview
    }
}

// MARK: - Timeline Provider

struct RecentPostsProvider: TimelineProvider {

    func placeholder(in context: Context) -> RecentPostsEntry {
        RecentPostsEntry(
            date: Date(),
            posts: placeholderPosts(),
            configuration: RecentPostsConfiguration()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentPostsEntry) -> Void) {
        Task {
            let posts = await loadRecentPosts(limit: 5)
            let entry = RecentPostsEntry(
                date: Date(),
                posts: posts,
                configuration: RecentPostsConfiguration()
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentPostsEntry>) -> Void) {
        Task {
            let posts = await loadRecentPosts(limit: 5)
            let entry = RecentPostsEntry(
                date: Date(),
                posts: posts,
                configuration: RecentPostsConfiguration()
            )

            // Update every hour
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

            completion(timeline)
        }
    }

    // MARK: - Data Loading

    private func loadRecentPosts(limit: Int) async -> [PostData] {
        do {
            let actor = try DatabaseActor()
            let allPosts = await actor.getPostData()
            return Array(allPosts.prefix(limit))
        } catch {
            return placeholderPosts()
        }
    }

    private func placeholderPosts() -> [PostData] {
        [
            PostData(id: "1", title: "Building Modern iOS Apps", author: "Sarah Chen", mainImage: "", html: ""),
            PostData(id: "2", title: "Swift 6 Concurrency Guide", author: "Marcus Johnson", mainImage: "", html: ""),
            PostData(id: "3", title: "SwiftUI Best Practices", author: "Aisha Patel", mainImage: "", html: "")
        ]
    }
}

// MARK: - Widget Views

struct RecentPostsWidgetEntryView: View {
    var entry: RecentPostsProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(posts: entry.posts)
        case .systemMedium:
            MediumWidgetView(posts: entry.posts)
        case .systemLarge:
            LargeWidgetView(posts: entry.posts)
        default:
            MediumWidgetView(posts: entry.posts)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let posts: [PostData]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Recent Posts", systemImage: "newspaper")
                .font(.caption)
                .foregroundColor(.secondary)

            if let post = posts.first {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(3)

                    Text(post.author)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No saved posts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .widgetBackground()
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let posts: [PostData]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Recent Posts", systemImage: "newspaper")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(posts.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(posts.prefix(3)) { post in
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(2)

                        Text(post.author)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                if post.id != posts.prefix(3).last?.id {
                    Divider()
                }
            }

            Spacer()
        }
        .padding()
        .widgetBackground()
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let posts: [PostData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Recent Posts", systemImage: "newspaper.fill")
                    .font(.headline)
                Spacer()
                Text("\(posts.count) saved")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(posts.prefix(5)) { post in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)

                        Text(post.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                    }

                    Text("by \(post.author)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 16)
                }

                if post.id != posts.prefix(5).last?.id {
                    Divider()
                }
            }

            Spacer()
        }
        .padding()
        .widgetBackground()
    }
}

// MARK: - Widget Configuration

struct RecentPostsWidget: Widget {
    let kind: String = "RecentPostsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentPostsProvider()) { entry in
            RecentPostsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Recent Posts")
        .description("Quick access to your recently saved Medium articles")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        #if os(iOS)
        .contentMarginsDisabled()
        #endif
    }
}

// MARK: - Widget Bundle

@main
struct OfflineMediumWidgets: WidgetBundle {
    var body: some Widget {
        RecentPostsWidget()
    }
}

// MARK: - Helper Extensions

extension View {
    func widgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                Color.clear
            }
        } else {
            return background(Color.clear)
        }
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    RecentPostsWidget()
} timeline: {
    RecentPostsEntry(
        date: .now,
        posts: [
            PostData(id: "1", title: "Building Modern iOS Apps with SwiftUI", author: "Sarah Chen", mainImage: "", html: "")
        ],
        configuration: RecentPostsConfiguration()
    )
}

#Preview(as: .systemMedium) {
    RecentPostsWidget()
} timeline: {
    RecentPostsEntry(
        date: .now,
        posts: [
            PostData(id: "1", title: "Building Modern iOS Apps", author: "Sarah Chen", mainImage: "", html: ""),
            PostData(id: "2", title: "Swift 6 Deep Dive", author: "Marcus Johnson", mainImage: "", html: ""),
            PostData(id: "3", title: "Actor Concurrency Patterns", author: "Aisha Patel", mainImage: "", html: "")
        ],
        configuration: RecentPostsConfiguration()
    )
}
