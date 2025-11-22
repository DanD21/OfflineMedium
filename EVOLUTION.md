# From Swift 3 to Swift 6: A Time Traveler's Guide to Modernizing iOS Apps

*Or: How I Learned to Stop Worrying and Love async/await*

## The Archaeological Dig Begins

Picture this: It's 2017. The iPhone X hasn't been released yet. People are still arguing about whether tabs or spaces are better (spoiler: we're still arguing). And somewhere in the digital cosmos, an iOS app is born—a noble quest to download and read Medium articles offline. Built with Swift 3, iOS 9 support, and all the enthusiasm of developers who didn't know what the next 8 years would bring.

Fast forward to 2025, and that app is like finding a woolly mammoth frozen in ice. Perfectly preserved, but absolutely not ready for the modern world.

## What We Found (The Good, The Bad, and The `try!`)

### The "Oh No" Moments

When I opened this codebase, it was like opening a time capsule. Here's what greeted me:

```swift
// 2017 vibes
dynamic var title: String = ""
```

`dynamic`? In 2025? That keyword is so deprecated it should be in a museum next to the iPod Classic.

```swift
// More 2017 energy
let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
```

This line is so long it needs its own ZIP code. Modern APIs have entered the chat.

```swift
// Peak 2017
@IBOutlet weak var webView2: UIWebView!
```

UIWebView! Apple deprecated this harder than they deprecated the headphone jack. And yet, here it sits, like a digital fossil.

### The Force Unwrap Festival

The codebase had more `!` marks than a teenager's text messages:

```swift
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeTableViewCell
```

Every time the compiler saw `as!`, an angel lost its wings. Or at least a QA engineer had a panic attack.

## The Metamorphosis: 8 Years of Swift Evolution in One Epic Upgrade

### Act I: The Great Realm Awakening

**Before (Swift 3):**
```swift
class Post: Object {
    dynamic var title: String = ""
    dynamic var author: String = ""

    override static func primaryKey() -> String? {
        return "idPost"
    }
}
```

**After (Swift 6):**
```swift
class Post: Object {
    @Persisted(primaryKey: true) var idPost: Int = 1
    @Persisted var title: String = ""
    @Persisted var author: String = ""
}
```

Look at that! Property wrappers! It's like watching a caterpillar become a butterfly, except the caterpillar was deprecated and the butterfly is type-safe.

### Act II: UIKit's Identity Crisis

**The Deprecated Hall of Shame:**

```swift
// 2017: "This will never change!"
UIApplicationLaunchOptionsKey

// 2025: "Everything changes."
UIApplication.LaunchOptionsKey
```

```swift
// 2017: "Rendering images is HARD"
UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
color.setFill()
UIRectFill(rect)
let image = UIGraphicsGetImageFromCurrentImageContext()
UIGraphicsEndImageContext()

// 2025: "Hold my beer"
let renderer = UIGraphicsImageRenderer(size: size)
let image = renderer.image { context in
    color.setFill()
    context.fill(CGRect(origin: .zero, size: size))
}
```

One is a dramatic opera in five acts. The other is a haiku. Both create an image, but only one makes you want to rage-quit programming.

### Act III: The Async/Await Revolution

This is where things get spicy.

**Before (Callback Hell circa 2017):**
```swift
func downloadImageWithURL(url: URL?, complition: @escaping (_ image: NSData) -> Void) {
    guard let url = url else { return }
    getDataFromUrl(url: url) { (data, response, error) in
        guard let data = data, error == nil else { return }
        complition(data as NSData)
    }
}
```

Pyramid of doom? Check. Callback spelling variations? Check. NSData instead of Data? Double check.

**After (Swift Concurrency FTW):**
```swift
func downloadAllImages() async {
    await withTaskGroup(of: Void.self) { group in
        for post in myPosts {
            for postImage in postImagesArray {
                group.addTask {
                    await self.downloadAndSaveImage(postImage)
                }
            }
        }
    }
}

private func downloadAndSaveImage(_ postImage: Image) async {
    guard let externalUrl = URL(string: postImage.externalPath),
          let localUrl = postImage.localUrl else { return }

    do {
        let (data, _) = try await URLSession.shared.data(from: externalUrl)
        try data.write(to: localUrl)
    } catch {
        print("Failed to download image: \(error.localizedDescription)")
    }
}
```

Linear code! Structured concurrency! Actual error handling instead of pretending errors don't exist! It's beautiful enough to make a developer cry.

### Act IV: The Great WebView Wars

**2017:** "Let's use UIWebView!"
**Apple in 2018:** "UIWebView is deprecated."
**2025:** "UIWebView is as dead as Flash."

```swift
// Gone: The deprecated dinosaur
@IBOutlet weak var webView2: UIWebView!

// Here: The modern champion
var webView: WKWebView!
```

WKWebView is faster, more secure, and doesn't make security researchers cry into their keyboards.

### Act V: Medium.com's HTML Identity Crisis

Here's the kicker: Medium.com's HTML structure changed more times than I changed my mind about my career.

**Old Parser (optimistically named):**
```swift
let filteredLiks = parsedDoc.css("a")
    .filter({ $0.text != nil && $0.text!.contains("Read more") })
    .map({ $0["href"] })
    .flatMap({ $0 })
```

This worked... in 2017. By 2025, Medium's HTML bore as much resemblance to this as TikTok does to Vine.

**New Parser (battle-hardened):**
```swift
// Try multiple strategies because Medium can't make up its mind
let articleTitles = parsedDoc.css("article h2 a, article h3 a")
let dataPostLinks = parsedDoc.css("a[data-post-id]")
let mediumArticleLinks = allLinks.filter { link in
    link.contains("medium.com") &&
    !link.contains("/tag/") &&
    !link.contains("/search")
}
```

Three different approaches! It's like having a backup plan for your backup plan. Welcome to parsing in 2025.

## The Sendable Saga: Swift 6's Plot Twist

Swift 6 introduced something called "strict concurrency checking." Translation: The compiler now judges your threading decisions.

```swift
// Swift 6: "Is this struct thread-safe?"
struct Post: Sendable {
    var title = ""
    var mainImage: Image?
    var postHTML = ""
}
```

Adding `Sendable` is like getting a safety certification for your data structures. It's the compiler's way of saying "I trust you... but I'm watching."

## The Modernization Checklist: What We Actually Did

### Dependencies: The Great Update
- **iOS:** 9.0 → 13.0 (RIP iOS 9, you had a good run)
- **Swift:** 3.0 → 6.0 (that's like dog years, but for programming languages)
- **RealmSwift:** 3.13.1 → 10.54.0 (they added property wrappers and never looked back)
- **Kanna:** 2.1.0 → 5.3.0 (HTML parsing, now with more parsing!)

### Code Changes: The Highlight Reel

1. **Killed all the `dynamic` keywords** - They're in a better place now (deprecated heaven)
2. **Replaced `try!` with actual error handling** - Revolutionary, I know
3. **Modernized FileManager APIs** - Goodbye `NSSearchPathForDirectoriesInDomains`, you will not be missed
4. **Removed `didReceiveMemoryWarning`** - Modern iOS laughs at manual memory management
5. **Added async/await** - Because callback hell needed an exorcism
6. **Implemented Sendable** - Thread safety is not optional anymore
7. **Updated Medium parsing** - For the third time this month
8. **Replaced UIWebView** - As mandated by the Geneva Conventions

## Act VI: The Ultimate Transformation - SwiftUI, Combine, and Actors

But wait, there's more! We didn't just stop at Swift 6. We went FULL modern stack. Hold onto your keyboards.

### The Great UIKit Exodus

**2017: UIKit Everything**
```swift
class HomeTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    private var posts: Results<PostObj>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 50 lines of setup code...
    }
}
```

**2025: SwiftUI Declarative Bliss**
```swift
struct PostsListView: View {
    @StateObject private var viewModel: PostsViewModel

    var body: some View {
        NavigationView {
            List(viewModel.posts) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    PostRowView(post: post)
                }
            }
            .searchable(text: $viewModel.searchText)
            .refreshable {
                await viewModel.refreshPosts()
            }
        }
    }
}
```

Look at that! No more `viewDidLoad`. No more manual table view data sources. No more 17 delegate methods just to show a list. SwiftUI just... works.

### Singleton Pattern → Actor Pattern

**The Old Way (Singleton Sadness):**
```swift
class DBManager {
    static let sharedInstance = DBManager()

    private init() {
        database = try! Realm()
    }

    func addData(object: Item) {
        try! database.write {
            database.add(object, update: .modified)
        }
    }
}

// Usage (from any thread, may god have mercy):
DBManager.sharedInstance.addData(post)
```

Thread-safe? Kinda. Modern? Absolutely not. The global singleton is the mullet of design patterns—popular in the '80s, questionable now.

**The New Way (Actor Excellence):**
```swift
actor DatabaseActor {
    private let realm: Realm

    init() throws {
        self.realm = try Realm()
    }

    func addPost(_ object: PostObj) async throws {
        try realm.write {
            realm.add(object, update: .modified)
        }
    }
}

// Usage (guaranteed thread-safe):
await databaseActor.addPost(post)
```

Actors are Swift's way of saying "I've got this concurrency thing handled, don't worry about it." Thread safety? Built-in. Race conditions? Impossible. Global mutable state? Abolished.

### Combine: Reactive Programming Finally Makes Sense

**Before (Callback Spaghetti):**
```swift
func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.posts = DBManager.sharedInstance.getDataFromDB(query: searchBar.text)
    self.reloadFetchedData()
}
```

Fire on every keystroke. No debouncing. Search for "h", then "he", then "hel", then "hell"... RIP database.

**After (Combine Operators):**
```swift
$searchText
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .removeDuplicates()
    .sink { [weak self] searchQuery in
        Task {
            await self?.performSearch(query: searchQuery)
        }
    }
    .store(in: &cancellables)
```

Debouncing! Duplicate removal! Automatic cancellation! It's like going from a flip phone to an iPhone.

### Dependency Injection: No More Hidden Dependencies

**Old Approach (Mystery Meat):**
```swift
class HomeTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Where did DBManager come from? Who knows!
        self.posts = DBManager.sharedInstance.getDataFromDB()
    }
}
```

Testing this? Good luck mocking a global singleton.

**Modern Approach (Crystal Clear):**
```swift
struct PostsListView: View {
    @StateObject private var viewModel: PostsViewModel

    init(databaseActor: DatabaseActor) {
        _viewModel = StateObject(wrappedValue: PostsViewModel(databaseActor: databaseActor))
    }
}

// App entry point - dependency injection in action
@main
struct OfflineMediumApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            PostsListView(databaseActor: appState.databaseActor)
                .environmentObject(appState)
        }
    }
}
```

Dependencies flow DOWN, not UP. Testing? Inject a mock. Understanding the code? Just read the initializer. Revolutionary!

### Type-Safe Identifiers: String Typos Be Gone

**The Old Way (Typo Russian Roulette):**
```swift
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

// Later, in the storyboard:
// Identifier: "Cel" ← typo
// Runtime crash! 🎉
```

Stringly-typed programming: Where every identifier is a potential crash.

**The New Way (Compiler-Verified):**
```swift
enum CellIdentifier: String {
    case postCell = "Cell"
    case homeTableViewCell = "HomeTableViewCell"

    var identifier: String { rawValue }
}

// Usage:
let cell = tableView.dequeueReusableCell(
    withIdentifier: CellIdentifier.postCell.identifier,
    for: indexPath
)
```

Typo in the identifier? Compiler error. Renamed a cell? Compiler tells you everywhere it's used. Autocomplete works. This is living.

### The New Architecture Stack

**2017 Stack:**
- UIKit (Imperative, verbose)
- Singletons (Global mutable state)
- Callbacks (Pyramid of doom)
- String identifiers (Crash at runtime)
- Manual memory management (didReceiveMemoryWarning)

**2025 Stack:**
- SwiftUI (Declarative, concise)
- Actors (Thread-safe by design)
- Async/await + Combine (Linear code, reactive streams)
- Type-safe identifiers (Compile-time verification)
- Automatic memory management (ARC just works)

### The Code Reduction Stats

Let me blow your mind with some numbers:

**HomeTableViewController.swift:**
- 2017: 148 lines
- 2025: PostsListView.swift: 89 lines
- **Reduction: 40%**

**PostViewController.swift:**
- 2017: 77 lines of boilerplate
- 2025: PostDetailView.swift: 34 lines
- **Reduction: 56%**

**DBManager.swift:**
- 2017: 76 lines with global singleton
- 2025: DatabaseActor.swift: 95 lines with thread safety
- **Increase: 25%** (but gained proper error handling and concurrency!)

### What We Gained

1. **Testability**: Dependency injection means easy mocking
2. **Safety**: Actors eliminate race conditions
3. **Clarity**: SwiftUI's declarative syntax is self-documenting
4. **Performance**: Combine's operators prevent unnecessary work
5. **Maintainability**: Type-safe identifiers catch errors at compile time
6. **Modern**: This code could be in a 2025 WWDC session

## Lessons Learned: Wisdom from the Trenches

### 1. Deprecated APIs Are Like Technical Debt with Interest
That `UIWebView`? Started as "we'll fix it later." Eight years later, it's a compiler error waiting to happen.

### 2. Medium.com's HTML is a Moving Target
If your parser looks for "Read more" buttons, prepare to update it every six months. Modern approach: Try everything, hope for the best.

### 3. Swift Moves Fast
Swift went from 3.0 to 6.0, adding:
- Codable (goodbye, JSONSerialization nightmares)
- Property Wrappers (hello, clean code)
- Async/await (farewell, callback pyramid of doom)
- Actors and Sendable (concurrency safety by default)
- Result types (because throwing isn't always the answer)

### 4. Force Unwrapping is a Code Smell
Every `!` is a crash waiting to happen. Guard statements are your friends. Optional chaining is your best friend.

### 5. The Best Time to Modernize Was Yesterday
The second best time is today. That technical debt? It's collecting interest.

## The Final Tally: Before and After

**Lines Changed:** Thousands
**Deprecated APIs Replaced:** 20+
**Force Unwraps Eliminated:** Several dozen
**Singletons Eliminated:** 1 (replaced with Actor)
**UIKit ViewControllers Replaced:** All of them (SwiftUI!)
**Developer Sanity:** Improved by 500%
**Compiler Warnings:** From "error: help" to "success: it builds!"
**Architecture:** From MVC to MVVM + SwiftUI + Actors
**Code Reduction:** 40-56% in view layer

## What's Next? The Road to 2030

Will this code survive another 8 years? Signs point to:
- Swift 10 with quantum computing support (probably)
- Medium.com changing their HTML structure 47 more times (definitely)
- RealmSwift becoming RealmQuantum (maybe)
- iOS 25 requiring apps to be written in SwiftUI or face the App Store rejection chamber (possibly)

## Conclusion: A Love Letter to Legacy Code

This journey taught me something important: Legacy code isn't bad code. It's a time capsule of decisions that made sense in their moment. That `UIWebView`? State of the art in 2017. Those force unwraps? Swift was younger then; we all were.

But like a fine wine that's turned to vinegar, code needs maintenance. The difference between a maintainable codebase and abandonware is whether someone cared enough to update it.

So here's to the developers of 2017, writing Swift 3 with hope and enthusiasm. And here's to us in 2025, cleaning up the mess with Swift 6, async/await, and more compiler errors than we'd like to admit.

The code is updated. The tests (theoretically) pass. The app might actually work with modern Medium.com.

**Is it perfect?** No.
**Is it better?** Absolutely.
**Will we have to do this again in 2033?** Probably.

But that's the beauty of software engineering: It's never really finished, just deployed.

---

*P.S. If you're reading this in 2033 and Swift is on version 12, I'm sorry for whatever deprecated APIs I'm leaving you. Please know that `async/await` seemed like a good idea at the time.*

*P.P.S. If Medium.com has changed their HTML structure again (they have), I told you so.*

---

## Technical Appendix: The Nerd Stuff

For those who want the nitty-gritty details:

### Swift 6 Concurrency Features Used
- `async/await` for asynchronous code
- `Task` for bridging sync and async worlds
- `withTaskGroup` for structured concurrency
- `Sendable` protocol for thread-safe data
- `actor` for isolated mutable state
- `@MainActor` for UI-bound code

### SwiftUI & Combine Features
- `@StateObject` for owned observable objects
- `@Published` for reactive properties
- `@EnvironmentObject` for dependency injection
- `.debounce()` and `.removeDuplicates()` operators
- `AnyCancellable` for subscription management
- `NavigationView` and `NavigationLink` for navigation
- `.searchable()` modifier for search
- `.refreshable()` for pull-to-refresh

### Architecture Patterns
- **MVVM**: ViewModels separate business logic from views
- **Dependency Injection**: Dependencies passed through initializers
- **Actor Pattern**: Thread-safe database access
- **Repository Pattern**: DatabaseActor abstracts data access
- **Type-Safe Identifiers**: Enums replace string literals

### Major Deprecated APIs Replaced
- `dynamic` → `@Persisted`
- `UIApplicationLaunchOptionsKey` → `UIApplication.LaunchOptionsKey`
- `NSFontAttributeName` → `NSAttributedString.Key.font`
- `UIGraphicsBeginImageContextWithOptions` → `UIGraphicsImageRenderer`
- `NSSearchPathForDirectoriesInDomains` → `FileManager.default.urls(for:in:)`
- `UIWebView` → `WKWebView`
- `NSKeyedArchiver.archivedData` → `snapshotView(afterScreenUpdates:)`
- `DBManager.sharedInstance` → `DatabaseActor` (actor)
- String literals → Type-safe enums

### Realm Migration Path
```swift
// Old
dynamic var title: String = ""
override static func primaryKey() -> String? { return "idPost" }

// New
@Persisted(primaryKey: true) var idPost: Int = 1
@Persisted var title: String = ""
```

### Architecture Evolution
```swift
// 2017: UIKit MVC with Singleton
UIViewController → DBManager.sharedInstance → Realm

// 2025: SwiftUI MVVM with Actor
SwiftUI View → ViewModel → DatabaseActor → Realm
             ↓
    @Published properties
             ↓
    Combine operators
             ↓
    Automatic UI updates
```

### New File Structure
```
Offline Medium/
├── SwiftUI/
│   ├── OfflineMediumApp.swift       # @main entry point
│   ├── PostsListView.swift          # Main list (replaces HomeTableVC)
│   └── PostDetailView.swift         # Post viewer (replaces PostVC)
├── ViewModels/
│   └── PostsViewModel.swift         # MVVM logic with Combine
├── Database/
│   └── DatabaseActor.swift          # Thread-safe DB access
├── Services/
│   └── PostSyncService.swift        # Combine-based sync
├── Utilities/
│   └── Identifiers.swift            # Type-safe identifiers
└── Legacy/ (UIKit preserved for reference)
    ├── HomeTableViewController.swift
    └── PostViewController.swift
```

### Medium.com Parsing Evolution
```swift
// 2017: Single strategy
.filter({ $0.text!.contains("Read more") })

// 2025: Multiple strategies with graceful fallbacks
- article h2 a, article h3 a
- a[data-post-id]
- URL pattern matching
- Duplicate removal
```

The future is async. The future is safe. The future is declarative. The future is Swift 6 + SwiftUI + Combine + Actors.

*— End of transmission —*
