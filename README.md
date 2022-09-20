# iOS Lead Essentials Course

[![iOS Essential Feed Automation Tests](https://github.com/lfcj/EssentialFeed/actions/workflows/CI-iOS.yml/badge.svg)](https://github.com/lfcj/EssentialFeed/actions/workflows/CI-iOS.yml)

[![MacOS Essential Feed Automation Tests](https://github.com/lfcj/EssentialFeed/actions/workflows/CI-macos.yml/badge.svg)](https://github.com/lfcj/EssentialFeed/actions/workflows/CI-macos.yml)

This README contains the notes for the course.

# iOS Lead Essentials Notes

Github: https://github.com/lfcj/EssentialFeed

## Networking Module

#### 1. From Singletons and Globals to Proper Dependency Injection ✅

-   It is about singletons, Singletons, and inverse dependency injection by which it is easier to decouple from third party libraries
-   An object can be a Singleton if it makes sense to have one and only one instance of it throughout the app life cycle. Even in this case, components shouldn't access the singleton directly if one wants to decouple the components from the concrete singleton class -> Use Reverse Dependency Injection for that!

#### 2. Asserting a Captured Value Is Not Enough + Cross-Module Access Control ✅

-   Public vs @testable, using spy objects in tests to extend coverage and not only asserting captured value, but other data like how often a method is called.

#### 3. Handling Errors + Stubbing vs. Spying + Eliminating Invalid Paths ✅

-   Here we look into handling network errors and talk about the differences between stubbing and spying when unit testing. Designing better code with enums to make invalid paths unrepresentable
-   A spy should not perform actions, a stub can do that, e.g.: If the client has errors that can be injected, the spy should not have to decide if it finishes with an error or not.
-   Spies are usually test-helpers with a single responsibility of capturing the received messages.
-   In order to keep the spy not stubbing we make sure the spy keeps track of/captures all the actions/completions.
-   Spies should not have predefined behaviour, the user of the spy should decided what to do with the values the spy has captured.
-   Replacing stubbing with capturing/spying allows us to better test asynchronous behaviour with completion closures.
-   With a stub the stub would need to re-use an injected error when a method is called. With a spy, the completion is captured and one can later do spy.completions[index](Error(..))
-   By not capturing paths with enums but with options, we allow scenarios in which, for example, both error + response as nil or non-nil at the same time. That should never happen.

    ### Stubs and Spies are test-doubles. 📚💡

-  a. A Stub is used to set predefined behaviors or responses during tests. For example, you can create a Stub to provide "canned" HTTP responses (e.g., predefined JSON data or error).

-  b. A Spy collects or "records" usage information such as method invocation count and values received. So you can use/verify them later in the test. A Spy is often also a Stub, as you can choose to set predefined actions/responses into it.

#### 4. A Classicist TDD Approach (No Mocking) to Mapping JSON with Decodable + Domain-Specific Models ✅

-   Diffs and trade-offs between mocking vs testing collaborators in integration
-   Mapping JSON data to native models with Decodable.
-   Simplifying tests leveraging factory methods and test helper functions.
-   When small and readable, keep JSONs as text in the tests, avoid putting them in files. Debugging becomes easier.
-   It is important to pass file and line to the XCTAssert.. method when they are called in a helper method.
-   Do not couple modules in the Decodable extensions. The API module should own the JSON keys.

#### 5. Automating Memory Leak Detection + Preventing a (Way Too Common) Async Bug ✅

-   It is possible to implement automating memory leak detection with tests
-   Use addTeardownBlock inside factory methods to make sure that instances are deallocated after the tests have been run.
-   Clients should not parse data inside results when self has already been deallocated. Tests should be written for this.
-   Whenever a method does not require state, make it static to not have to capture self to use it.

    ##### Video: [The Minimum You Should Do To Prevent Memory Leaks in Swift][1]

    In tests make sure that references to objects are nil by the time the retainer ends using the referenced object. The normal solution is to always use [weak retainedObject].

    ##### Video: [XCTest + Swift: SetUp/TearDown vs Factory Methods][2]

    TIL: An instance of the Test class is created per test, so global variables within tests will not keep up changes between one test and the next one. There is also not order of execution. Given these points it is mostly better to have factory methods vs using the setUp/tearDown. Readability is also affected because one has to scroll up and down to see what initial config is done.

#### 6. Conforming to Feature Abstractions While Maintaining System Modularity + Keeping Test Details Out of Production With Enum Pattern Matching and Async Expectations ✅

-   Protecting the production code from test details -> Do not make types conform to protocols for testability.
-   Maintain modularity by protecting high-level abstractions from low-level implementation details
-   DRY (Don’t Repeat Yourself) is sometimes better than early abstracting code to common modules because one creates modular dependencies without really finding out the needs of the system.
-   Assert asynchronous behavior with XCTestCase expectations. exp + exp.fulfill + wait(for: [exp])

#### 7. Four Approaches to Test(-Drive) Network Requests: End-to-End, Subclass & Protocol-Based Mocking, and URLProtocol Stubbing ✅

-   Learn various testing strategies for network requests and their trade-offs:

    * **End-to-end-testing:** It is an integration test between client and server. Real requests are done. This can make our development slow because the API might not be ready. It can also happen that there is just not network or that it is slow.

    * **Mocking with Subclasses:** It can be dangerous when subclassing classes we do not own, such as URLSession. There are methods that could do things we do not expect. It is also very coupled with the production code because we have to follow the step by step process that happens in production to fulfil our expectations. As an example URLSession’s initialiser was deprecated. Refactoring code in production immediately  breaks tests.

    * **Mocking with Protocols:** We can define protocols that have the interfaces we’d like to spy on. With this we can hide unnecessary details and avoid overwriting methods, we only care about specific behaviours. This, however, does not solve the tight coupling problem. Creating these protocols is also noisy in the production code because the sole purpose of the protocols may be testing.

    * **URLProtocol stubbing:** This is done using the “little-known URL Loading System”. It is fast and reliable, recommended by Apple to test network requests, so hopefully not unexpected mocking behaviour. It is good to decouple code from the production one as well as production details. We can also use this for other purposes such as analytics, caching or profiling (how long are things taking?). It awesome cuz one can just register stubs that would spy on requests, but the delegation to the stub is handled by the system. URLProtocol is an abstract class, when subclassed, one needs to implement 4 methods and one has access to all of the instance variables of the URLSession. See [commit][3] for an example.

    What we did with URLProtocol is intercepting and handling URL requests.
    Subclass and protocol-based mocking of classes we don’t own (e.g., the Foundation URLSession class)

##### Video: [Clean iOS Architecture pt.2: Good Architecture Traits][4]

-   Good architecture makes a system soft -> easy to change and adapt to the ever changing requirements.
-   A soft system is:

    * **flexible:** it welcomes requirement changes.
    * **maintainable:** Improves the estimation accuracy of the team. With new requirements it is more clear to know what is needed to do the changes. They are
    * **scalable:** They are easy to test.

##### Video: [Clean iOS Architecture pt.5: MVC, MVVM, and MVP (UI Design Patterns)][5]

None of them are architectures!

-   **MVC:** It was very UI based and does not approach where networking or interacting with databases would live. Controller and view should not have a contact with each other, for example, the model would notify the view or use callbacks for it.
    The model, however, is very independent and can live in a different module and be tested alone.

-   **Apple MVC:** The original MVC was a broad design pattern that was not ready for new technology. In the Apple MVC the events from the View. It is very messy for big applications.

-   **MVVM:** We do not have a controller, it is replaced by a view model. But again, networking, routing and parsing are a dev option. It should not be used to deal with the business logic, they should only be for the view. Bigger responsibilities should be kept away from this pattern.

-   **MVP:** This is inverted to what MVC does. The presenter has a reference to the View, but through a protocol.

#### 8. Speeding up Development by: Reducing Debugging Time, Minimizing Risk & Maximizing Learning, and Decoupling Tests From Implementation Details ✅

-   Avoiding the downsides of mocking/stubbing
-   The economics of test feedback
    * Looking for bugs takes longer -> **if one has to debug to find where the test is failing, the value of the test is diminished.**. Each thing should be tested in different places, for example, avoid testing request and urls in the same test, separate those concerns.
    * Use factory methods in tests to protect the tests from implementation details. It is a good call to also add memory leak tracking to those methods.
    * It is important to add `file: StaticString = #file, line: UInt = #line` to helper methods.
    * Minimizing risk in the codebase and maximizing learning by testing all scenarios (including error, invalid and unhappy paths)
    * Refactoring techniques for abstracting tests from implementation details
    * When using 3rd-party frameworks, it's advised to add extra tests to validate assumptions. One example was the test checking that empty Data triggered an error. Wrong -> `URLSession` just returns `.sucess()` with `Data` having 0 bytes.
    * Keep these cases in mind when testing dataTask outcomes:

    ![Possible data task outcomes to test][6]

    So far we have the last case: `nil`, `nil`, `value`.

    We implement a test for all the cases and land on finally testing sucessful situations.

    Important here is to take into account that comparing classes compares the pointers, not the values. In the case of the URL Loading System, when we pass a response through the `URLProtocol`, the system copies it into another instance, so the pointers are different.

#### 9. Randomizing & Parallelizing Tests, Code Coverage, Testing in Integration with the Backend, and Automating a Continuous Integration (CI) Pipeline ✅

-   Extra testing configurations (running tests in random order, parallelizing test execution and gathering code coverage)
    -   By running tests in random order we find order dependencies in our test suite.
        -   Edit scheme -> Info -> Options -> Randomize execution order
    -   Tests that depend on an order are hard to maintain because reproducing something is not easy.
    -   Running tests in parallel decreases the execution time, but so do good test practices.
        -   Edit scheme -> Info -> Options -> Execute in parallel
    -   100% code coverage does not mean that all the "behaviours" have been tested. Code coverage is a byproduct of good TDD.
        -   Edit scheme -> Options -> Code coverage
-   Testing client and server integration (end-to-end) even when the backend is still in development
    -   End-to-end tests may be less reliable than unit tests because they test integration components (databases, networking,
        etc.).
    -   If our backend cannot give us a test API, we should be able to create it ourselves.
-   Economics of end-to-end tests vs unit tests
    -   End-to-end tests usually also need longer to run, and are harder to maintain.
    -   We want lots of reliable, fast unit tests. If we do not trust the backend, we also want enough integration tests as a backup to alert us when things go wrong.
    -   **MAKE SURE TO ALWAYS ADD TEST FOR MEMORY LEAKS!**
-   Setting up a CI pipeline
    -   Create a Unit Testing Bundle target. That automatically creates a scheme
    -   Any team that does not have automated testing enabled is not as functional as they could be.
    -   We want to run this automatically before merging to `master`.
    -   In CI scheme, under Tests, add all the targets (Unit + Integration tests/targets), it is advised to
    select randomized execution and code coverage.
    -   Even solo devs can profit from this to ensure quality of codebase...as well as helping welcome new devs in the future.
    - Travis is OpenSource CI server, set .travis.yml for it. If not needed, disable codesign:
    ```
    os: osx
    os_image: xcode13.2.1
    language: swift
    script: xcodebuild clean build test -project EssentialFeed.xcodeproj -scheme "CI" -destination 'platform=iOS Simulator,name=iPhone 12' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
    ```
    Run the `script` in the terminal to make sure everything is fine.
    -   CI is only the first step towards the bigger goals: Continuous Delivery and Continuous Deployment. Automatic checks support harmonious collaboration in development teams and increase transparency and trust with the business side as we can deploy versions of our code to a broader team throughout the day.
    -   The link to the Travis status is https://travis-ci.com/github/lfcj/EssentialFeed
    -   TODO: Add status page to README.md once I have a CI server

#### 10. Identifying, Debugging, and Solving Data Races with the Thread Sanitizer ✅

-   Identifying, debugging, and solving data races with the Thread Sanitizer
    -   Turn it on under Edit Scheme -> Test -> Diagnostics -> Thread Sanitizer
    -   Although awesome, the thread sanitizer can slow down the CPU from 2 to 20 times, and incrase memory usage from 5 to 10 times.
    -   Due to this it is recommended only to leave this option on in the CI, not in the local tests.
    -   This, however, can result costly because it may need more server resources.
    -   Run at least once locally before doing so in the CI.
-   Visualizing how global shared state and threading together are prone to data races
    -   Avoid globally modifiable states, *for God's sake*.

#### 11. What Many Apps Get Wrong About Reachability and How To Get It Right ✅

-   There’s no reliable way to check for connectivity without actually trying to perform the request! From [Apple][7]:

> “Always attempt to make a connection. Do not attempt to guess whether network service is available, and do not cache that determination.”

-   It is advised to retry network requests when there are connectivity errors, or telling the user it looks like they are offline. But **not running the request** is bad UX.

-   Tools such as `SCNetworkReachability` are good for diagnosing the causes behind a request failing, not to realiably know if there is Internet.

    ##### What are alternatives?

    -   Setting `URLSessionConfiguration.default.waitsForConnectivity` to `true` starts the task when there is connectivity.

        -   Background sessions **always** wait for connectivity anyway.
        -   There is also a waiting time timeout, which is controlled by `timeoutIntervalForResource`.
        -   The URLSession delegate method notifies when a task is waiting. See `urlSession(taskIsWaitingForConnectivity)`.
        -   Only make sure to `nil` the delegate because the reference to it is strong -> Memory Leak Alert.
        -   Check `allowsExpensiveNetworkAccess` and `allowsConstrainedNetworkAccess` isntead of checking for reachability.

    -   If the request can start but fails due to lack of connection, it is the client's decision to retry or not.

#### Networking Module Learning Outcome ✅

-   *Try to commit as often as possible*
-   Basic depiction of dependencies, abstractions and concrete types in diagrams
-   How diagrams translate into code and vice versa
-   How the SOLID principles and composition are applied through examples
-   Differences and similarities between closures and protocols as abstractions in Swift (unnamed type signatures vs. strictly named types)
-   Representing component and module relationships in a diagram
-   How concrete or modular a system is from its diagram representation
-   Understand that every system needs to be tailored, rather than fit a predefined template
-   The process of modularization needs to be applied incrementally
-   How good architecture is a byproduct of good team processes
-   The importance of good communication and well-defined requirements
-   How to deal with lousy requirements
-   How to represent and communicate requirements into different formats
-   How contracts enable teams to develop independently (even when key parts of the system such as the UI or the backend API are not yet implemented.)
-   Establishing processes promoting detailed documentation.
-   The tradeoffs of the project’s starting point (should we start with abstractions or concrete components?!).
-   How to speed up the development process using macOS frameworks.
-   How to test-drive an API layer implementation
-   Modular Design
-   Singletons: When and Why
-   Singletons: Better alternatives
-   Singletons: Refactoring steps to gradually remove tight coupling created by singletons
-   Controlling your dependencies: Locating globally shared instances (Implicit) vs. Injecting dependencies (Explicit)
-   Controlling your dependencies: Dependency injection
-   Understand the trade-offs of access control for testing purposes
-   Expand behavior checking (and coverage) using test spy objects
-   Handling network errors
-   Differences between stubbing and spying when unit testing
-   How to extend code coverage by using samples of values to test specific test cases
-   Design better code with enums to make invalid paths unrepresentable
-   Differences and trade-offs between mocking vs. testing collaborators in integration
-   Mapping JSON data to native models using the `Decodable` protocol
-   How to protect your architecture abstractions by working with domain-specific models
-   How to simplify tests leveraging factory methods and test helper functions
-   Automating memory leak detection with tests
-   Preventing common async bugs
-   Protecting the production code from test details
-   Maintain modularity by protecting high-level abstractions from low-level implementation details
-   Dealing with potential issues when using the `Swift.Error` protocol
-   Pattern matching using Swift enums
-   Assert asynchronous behavior with `XCTestCase` expectations
-   Learn various testing strategies for network requests and their trade-offs
-   Subclass and protocol-based mocking of classes we don’t own (e.g., the Foundation `URLSession` class)
-   The (little-known) URL Loading System
-   Intercepting and handling URL requests with `URLProtocol`
-   Avoiding the downsides of mocking/stubbing
-   The economics of test feedback
-   Minimizing risk in the codebase and maximizing learning by testing all scenarios (including error, invalid and unhappy paths)
-   Refactoring techniques for abstracting tests from implementation details
-   Extra testing configurations (running tests in random order, parallelizing test execution, and gathering code coverage)
-   Testing client and server integration (end-to-end) even when the backend is still in development
-   Economics of end-to-end tests vs unit tests
-   Setting up a CI pipeline

#### Key Stats to Consider in Codebases ✅

-   [x] Less than Lines of Code per file
-   [x] No TODOs nor FIX comments
-   [x] No (!) force unwrapping
-   [x] No `unowned` reference count
    -   Using `unowned` is not recommended because it is difficult to understand the lifetime of objects, especially when they are controlled by frameworks, e.g.: `UIKit`. Objects/views/windows often live longer than one thinks they do. On the other hand, we strive to have modular and highly decoupled systems, so when using abstractions such as protocols to perform operations, we cannot guarantee their lifetime...nor should we try to guess it as we would be leaking implementation details.
-   [x] No more than 4 indentation level.
-   [x] Assignable `var` variable count.
-   [x] 0 merges to `master` with failing tests.


    Clear separation of concerns, establishing proper boundaries and utilizing dependency inversion whenever necessary are the keys to a clean architecture, not the paradigm one uses

## Persistence Module

#### 12. URLCache as a Persistence Alternative & Solving The Infamous “But it works on my machine!” Caching Problem ✅

-   Pros and cons of `URLCache` as a caching/persistence alternative.
    -   `URLCache` caches response by mapping `CachedURLResponse`s to `URLRequest`s. One can create its own `URLCache` instance with disk path, and memory preferences (RAM or hard drive). Creating policies onself is also possible (`requestCachePolicy`). It all works out of the box as long as the server implements cache-control correctly.
    -   It is possible to set a custom `URLCache.shared`, it is only advised to do so as soon as possible so it is propagated correctly, e.g.: after `didFinishLaunch` method.

    ##### Notes:
    -   Only HTTP/HTTPs requests are cached.
    -   Only 200-299 successful responses are cached.
    -   Response came from server and not from cache.
    -   The session config allows caching.
    -   The `URLRequest` cache policy allows caching.
    -   The cache-related headers in the response allow caching.
    -   The response size fits in the cache size, e.g.: response must not be larger than about 5% of the disk cache size.

-   Depicting an architecture diagram of implicitly coupled Networking and Caching modules
-   Improving the test suite integrity by eliminating shared caching artifacts across test executions
    -   `URLSession` caches by default, so if our tests use it, there will be a shared state that can affect our end-to-end tests. This must be avoided by using the ephemeral configuration of `URLSession` not to store any data to disk. This makes that all session data is stored to RAM.

#### 13. Clarifying Requirements, Enhancing Cross-Team Domain Knowledge, and Iterative vs. Big Upfront Design ✅

-   Developing software is a social activity.
-   Aim for flexible solutions to be able to adapt quickly.
-   In TDD a test class name can match the behaviour it tests, not the name of a class.
-   Write up requirements as specific as possible to come up with cases that product/design did not specify.

#### 14. Decoupling Use-Case Business Logic From Framework Details + Controlling Time + Multi-Method Abstractions Following The Interface Segregation and Single Responsibility Principles ✅

-   Start starting tests without a protocol, if possible, that allows introducing properties/methods without breaking a contract.
    - The class created in the tests can always become the `Spy` and the name it had can be the protocol name.
-   Enriching test coverage by asserting the presence, the order, and values of method invocations.
-   Disciplined application of the Interface Segregation and Single Responsibility Principles.
    - ❔ When adding methods to a protocol, ask: "is every method related and responsible for the one and only responsability?" If not, create a new protocol.
    - The ISP stays that **no client should be forced to depend on methods it does not use**.
    - Classes in the Swift library such as `Sequence` and `Collection` do not break ISP, they have many methods because they solve universal abstractions on the types they represent.
-   Controlling the current date/time during tests.
    - It is a good idea to inject time creation as a dependency to be able to control time/dates during tests.
-   When adding a spy to the tests, make sure that this one saves all the information without having to take order into account when testing.

#### 15. Proper Memory-Management of Captured References Within Deeply Nested Closures + Identifying Highly-Coupled Modules ✅

-   Checking expected behavior after deallocation
    - Using `unowned` can make that an instance is still 'alive' after being deallocated. We should test against this and use `weak` instead of `unowned`.
-   Identifying highly coupled modules with a visual representation of dependencies.
    -   A good question to know if modules are too coupled is to ask: "Can I refactor or add new features to this module without touching any files of the other module?" The answer should be yes.
    -   Design of software must facilitate change.
-   A good architecture has these traits:
    -   Welcome requirement changes
    -   Improve estimation accuracy
    -   Make testing easier
    -   Allow independent development (and deployment, and testing in isolation/parallel)
    -   Make it easier to maintain a fast and constant pace
    -   Increase the number of reusable components

#### 16. Visualizing and Solving High-Coupling Issues by Decentralizing Components Using Data Transfer Model Representations ✅

-   Data transfer model representations for achieving modularity.
    -   This is also know as DTO: Data Transfer Objects
    -   Using single models across modules leads to complex, expensive-to-maintain and hard-to-use code.
    -   Make the name of each model very specific to its usage.
    -   The translation layer is the mapping to and from data representations.
    -   Measure performance when translating models! It is often surprising how minimal the impact is, especially when using immutable data. This is because the compiler optimizes such immutable data mappings since copies are not always necessary.
    -   If the collection is too big, lazy evaluation and caching are good tools to improve performance.
-   Decentralizing components to develop and deploy parts of the system in parallel.
-   The return on investment (ROI) of refactoring as a result of disciplined decoupling techniques.
    -   By only testing the public interfaces, refactoring code is easy without having to change tests. So `public` better than `@testable` when testing :)
    -   Call remote models similar to the contract done with the backend and client properties/models closer to what the domain experts spec.
-   A Swifty way of translating models with Array type constraint extensions.
    -   `extension`s of classes, especially native ones, that deal with local logic, should be kept private.

#### 17. Performing Calendrical Calculations Correctly, Dealing With Coincidental Duplication While Respecting the DRY Principle, Decoupling Tests From Implementation With Tiny DSLs, and Test Triangulation to Increase Coverage & Confidence ✅

-   Identifying coincidental duplication while respecting the DRY (Don't Repeat Yourself) principle.
    -   Code that looks the same but is conceptually different is not duplicate.
-   Performing calendrical calculations correctly.
     -   Use the native `Calendar` as much as possible to avoid calculations.
    -   Tests should be calendar/timezone agnostic whenever possible.
-   Creating a simple DSL (Domain Specific Language) to decouple tests from implementation details.
    -   An example of this are methods in extensions to make our codebase more readable and more adjusted to the domain needs.
-   Increasing test coverage and reducing the probability of error by triangulating data points.
    -   When testing, triangulation is done by thinking of three points regarding each reality, e.g: what if less, what if equal, what if more?

#### 18. Test-driving Cache Invalidation + Identifying Complex (Bloated) Functionality With The Command–Query Separation Principle ✅

-   Test-driving cache invalidation
-   Identifying bloated requirements
    -   Break each task into smaller tasks, this helps find hidden tasks.
-   Identifying bloated code with the _Command–Query Separation_ principle
    -   This principle allows identifying methods that do too much. The idea is **a query/get-call should only return a result and should not have side effects**. On the other hand, **a command/set-call changes the state of a system (side-effects) but does not return a value**.
    -   There are cases in which CQS is not needed, like the `remove` method, which mutates the collection and returns the removed object. Why not needed? Because this method leads to simpler and more idiomatic code.

#### 19. Separating Queries & Side-effects for Simplicity and Reusability, Choosing Between Enum Switching Strategies, and Differentiating App-Specific from App-Agnostic Logic ✅

-   Separating queries and side-effects by following the Command-Query Separation principle
    -   If a query and and command become tangled, they need to be separated, e.g.: a `load` method that deleted the cache becomes `load()` and `validateCache`.
-   Choosing between enum switch strategies: Explicit Cases vs. default vs. @unknown default
    -   By avoiding using `default` we get notified when new cases are added.
    -   An altenative is using `@unknonw default`, which causes a warning instead of a build error when new cases are added. We get the best of two worlds: flexible code and the free reminder to double check on the `switch` logic.
-   Producing a reliable codebase history (always in a working state)
    -   Each commit should have working code with all tests green, even if not refactored not clear yet.
-   Identifying Application-specific vs. Application-agnostic logic
    -   Specific use cases may not suit every application, but core business modesl/rules/policies should.
-   By keeping methods without side effects that validate our cache we can schedule periodic runs for them without worrying about collateral changes.

#### 20. Separating App-specific, App-agnostic & Framework logic, Entities vs. Value Objects, Establishing Single Sources of Truth, and Designing Side-effect-free (Deterministic) Domain Models with Functional Core, Imperative Shell Principles ✅


-   Application-specific vs. Application-agnostic vs. Framework (Infrastructure) Logic
    -   Use Cases describe _**application-specific business logic**_ and is often implemented by a Controller (aka Interactor/ModelController/Service...) type collaborating with other components (coordinating domain models and application infrastructure abstractions). Controllers deal with application interactions (e.g., coordinating asynchronous operations from collaborators) with strict boundaries (protocol/closure) to protect the application from depending on low-level details (e.g., 3rd-party frameworks). It should not depend on concrete (specific) framework details.
    -   Domain Models describe _**application-agnostic business logic**_. This kind of logic is application-independent, also known as core business logic. Core business logic is often reused across Use Cases within the same application and even across other applications. It should not depend on any application or framework details. Domain Models are usually tiny little objects when compared with the size of the system. But its importance is much greater than its size. Domain Models implement the essential business logic (the code that really matters to the business), so we don’t lose sight of the domain within the technical and infrastructure complexities. Notice how, for example, we strive to keep our models simple, with no asynchronous or impure behavior (application detail) leaking into the domain models.
    -   📚 Use cases contain application-specific  business logic.
    -   If a type has no side-effects, is deterministic and it holds no state, it is a value type and it can be static. Methods and variables can be inside a struct/class, but the constructor should be private because no one will need to ever create an instance of it. Or even better, create an `enum` and that way it has no initializer.
    -   Framework/infrastructure logic is not to implement any business rules. Mixing infrastructure details with business logic is one of the most common  mistakes we find in codebases (e.g.: `Database` and `Network` clients implementing validation of business rules operations or Domain Models inheriting from framework types such as CoreData's `NSManagedObject`). When this happens the business logic is scattered across the code and there is no central source of truth. It is then harder to use, reuse, maintain and test business rules and infrastructure code.
    -   The less a piece of code knows/does, a.k.a. the more we separate code, the easier it is to use, develop, reuse, maintain, test.
    - Infrastructure/framework interface implementations should be as simple and dumb as possible. It should only fulfil framework commands sent by the controllers via abstract interfaces (protocol or closures). Examples are: Download something from URL, fetch store this in URL, fetch something from cache.
-   Entities vs. Value objects
    -   `Entities` are models with intrinsic identity. `Value` objects rare models with no intrinsic identity. Both can contain business rules.
    -   💡 A `Value` type can be replaced by static or free functions when it does not hold a state.
    -   A good way to know if a type is a `Value` one or not is by checking if comparing its values is enough to make the comparison. an example would be `Money` when it looks like this:
    ```
    struct Money {
      let amount: Decimal
      let currency
    }
    ```
    When used by a system to track money and it gains a `let id: MoneyID`, then it becomes an `Entity` because it has an identity.
    -   Two  `Entities` with the same ID are considered identical even if their values do not match.
    -   A controller should coordinate the communication to external systems when performing business logic.
-   Designing side-effect free (deterministic) core business rules
    -   It is important to keep our core domain free from side-effects to keep it easy to maintain, build and test.
    -   Side effects are UI updates, I/O database writes, etc.)
-   Establishing Functional Core, Imperative Shell
    -   The goal is to have a deterministic core by it not having side-effects.
-   Promoting reusability and reducing cost, duplication, and defects with single sources of truth
    -   We want to hide implementation details as much as possible to reduce the cost of change, making mistakes, have reusable components and keep a DRY codebase. One example was the fact that the "7 days old cache policy" was included in the names of test methods. That was not hidden.
    -   Try to hide all of those magic numbers behind variables to keep them reusable and easy to change.

#### 21. Dependency Inversion Anatomy (High-level | Boundary | Low-level), Defining Inbox Checklists and Contract Specs to Improve Collaboration and Avoid Side-effect Bugs in Multithreaded Environments ✅

-   The anatomy of Dependency Inversion (High-level, Low-level, and Boundary components)
    -   A good modular system relies on dependency inversion between high-level (e.g.: business rules) and low-level (e.g.: infrastructure implementations) components.
    -   Good rules to follow include:
        -   A high level component has no references to low level components.
        -   A low level component is aware of the delivery mechanism.
        -   A boundary component is (a protocol or a closure) acts as an abstract barrier to guarantee that the high level component does not need to know low-level details.
-   Specs as Contracts & Documenting infrastructure requirements with an Inbox checklist
    -   Before writing code, write all possible use cases/specifications for the delivered product. Use that contract to start writing the tests.
    -   Well written contracts make it easier for different devs to participate on the same project without interferring with each other.
-   Proactively avoiding bugs caused by side-effects in multithreaded environments
    -   Avoid side-effects, respect the CQS paradigm!

#### 22. Persisting/Retrieving Models with Codable+FileSystem, Test-driving in Integration with Real Frameworks Instead of Mocks & Measuring Test Times Overhead with `xcodebuild` ✅

-   Encoding and decoding models with `Codable`
    -   One disadvantage of using `Codable` (and its convenience of Swift hiding a lot of decoding/encoding logic) is that we cannot longer hide framework details from our model.
    -   An alternative is to create create a `Codable<Name>` for each model so we can map `Codable<Name>` to `<Name>` and avoid that `<Name>` knows infrastructure details.
    -   There is no wrong/right option that can be applied universally.
-   Persisting model data to disk
    -   Not mocking collaborators of APIs we test has risks: collaborators, especially system ones, can have side effects that can affect our tests.
    -   It is important to remove any state inside `tearDown` to avoid the former point.
    -   A downside is that if the test fails to finish (crash?), `tearDown` is not called and you end up with flaky tests that fail sometimes. The solution to that is also clearing up state inside `setUp`, so cleaning before execution.
-   Retrieving model data from disk
    -   Relying on shared disk URLs prevent us from running tests in parallel as other tests may leave artifacts that need to be cleaned up before any other test runs.
-   Test-driving infrastructure components in integration with real frameworks instead of mocks
-   Preventing hard-to-debug test issues in stateful components by cleaning up the system state before and after test executions
    -   It is possible to use the same artifact name or to append an ID to it every time. Just watch out to clean that up as with CIs it can amount to a lot of data used.
    -   Using  `cachesDirectory` (which the OS cleans up when necessary), we avoid `documentDirectory` for which the developer needs to worry about maintenance.
-   Preventing hidden-coupling implications of cross-boundary `Codable` requirements
    -   It is important to measure the test suite performance over time.
-   Improving testability, maintainability, and reusability by moving from implicit hardcoded data to explicit data injection
-   Using `xcodebuild` to measure test times and discover potential overheads
    -   This can be done in the CI and the data can be collected to alert when performance outliers are detected. To measure this run:
    ```
    xcodebuild clean build test -project EssentialFeed.xcodeproj -scheme "EssentialFeed" -destination 'platform=iOS Simulator,name=iPhone 12' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
    ```
    A useful report can be:

    >   Executed 46 tests, with 0 failures (0 unexpected) in 0.151 (0.177) seconds

-   I/O operations can be expensive, so it is a good idea to measure the before and after performances.
-   Codebase health analysis
    -   One parameters is checking the number of lines of code changed with `commit`.

    >   "Make it work. Make it right. Make it fast. In that order."—Kent Beck

    -   Parts three (The Codebase) and four (The Software Product and the Delivery Process) of the book show a good list of indicators to pay attention to. Collecting them over time gives a good hint on the health of the codebase and on improvements to overtake.

-   📚 Try to convert comments into helper methods to avoid having to write comments. These are easily outdated.

#### 23. Deleting Models and Handling Errors with Codable+FileSystem, Making Async Code Look Sync in Tests to Eliminate Arrow Anti-Pattern, and More Essential Test Guidelines to Improve Code Quality and Team Communication ✅

-   Turning async code into sync for expressiveness and readability in tests
    -   This can be done by adding a helper method to translate from:
    ```
    func asyncFunction(completion: @escaping (ReturnType) -> Void)
    ```
    to:
    ```
    func syncFunction() -> ReturnType
    ```
    This is doable in the tests thanks to being able to `wait` for expectations.

-   Eliminating hard-to-read nested code (arrow-shaped code)
    -   By using sync-looking methods, we avoid completions and hence arrow-shaped code.
-   Monitoring the impact of refactoring with quantitative analysis
    -   It is helpful to measure lines of code and number of indentations as characteristics of outcomes of refactoring.
-   Improving test code by providing better names & making dependencies explicit
    -   It is better to repeat oneself with the purpose of being very explicit, than not doing so and leaving important logic hidden.
-   📚 The **Liskov Principle** tell us that types in a program should be replaceable with instances of their subtypes without altering the correctness of the program.

#### 24. Designing and Testing Thread-safe Components with DispatchQueue, Serial vs. Concurrent Queues, Thread-safe Value Types, and Avoiding Race Conditions ✅

-   Designing and testing thread-safe components with DispatchQueue
    -   💡 Test first that methods are run serially
    -   Use a local DispatchQueue (when suited). A `DispatchQueue(label: "\(Class.self)Queue", qos: .userInitiated)` is a background queue, BUT blocks run serially.
-   Differences between serial and concurrent dispatch queues
    -   If we have methods that have no side effects (READ ones?), these ones can be completely asynchronous. Our `DispatchQueue` can have the `attributes: .concurrent` and the methods with side effects can be dispatched using `flags: .barrier`. This makes sure that they act as a barrier and nothing is dispatched until they are done.
-   Avoiding threading race conditions (e.g., data corruption/crashes)
    -   Classes are **reference types** and share a single copy of data. Bad news for mutex.
    -   Structs, enums and tuples are **value types** and are passed as unique copies of the instance.
    -   **Pure Value Types** are the ones that only have value types and they do not share a mutable state -> **Thread Safe**.
    -   **Impure Value Types** are value types with pointers to reference types, such as classes or closures -> Not Thread Safe.
    -   It is important to add documentation to methods so clients know that completion handlers can be invoked in any thread...if they want to update the UI, they then need to call main queue for that, for example.
-   Thread-safe(r) value types
    ##### Video: [How Safe are Structs?][8]
    -   The most voted SO answer says that "structs should be chosen by default...[they] are safer and bug free, especially in a multithreaded environment".
    -   This is not always true, what is **Thread Safe** are **Pure Value Types**, an impure one is not thread safe.
    -   If the struct has a closure, that closure can have a different return type every time, making it mutable.
    -   The important thing is that structs do not have behaviours.
-   Measuring test time overheads
    -   To measure the time it takes to test, run:
    ```
    xcodebuild clean build test -project EssentialFeed.xcodeproj -scheme "EssentialFeed" -destination 'platform=iOS Simulator,name=iPhone 12' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
    ```
    The time it took looks like this:
    ```
    2022-02-24 08:37:40.781 xcodebuild[88678:2003168] [MT] IDETestOperationsObserverDebug: 0.000 sec, +0.000 sec -- start
    2022-02-24 08:37:40.781 xcodebuild[88678:2003168] [MT] IDETestOperationsObserverDebug: 19.863 sec, +19.863 sec -- end
    ```
    It is a good idea to collect these times to check the sanity and performance of our tests.

#### Tools
-   To draw the Dependency Diagrams, https://draw.io is used.
-   "To measure lines of code and other health indicators in the codebase we have developed our own tools to do so." Example:
-   Find all lines of code:
    ```
    find EssentialFeed/EssentialFeedTests -iname '*.swift' -type f -print0 | xargs -0 wc -l
    ```

#### 25.  Protocol vs Class Inheritance, Composite Reuse Principle, and Extracting Reusable Test Specs with Protocol Inheritance, Extensions and Composition ✅


-   Forming good abstractions by following the Liskov Substitution and Interface Segregation principles
    -   No client should be forced to depend on methods it does not use.
    -   By using protocol intefaces in our classes we support Liskov and any other implementation can use our code.
-   Protocol vs. Class inheritance
    -   Swift only allows one class inheritance, but it allows confirming to as many methods as possible.
-   Composite Reuse Principle (aka “Prefer composition over inheritance”)
    -   By making each protocol as specific as possible, we separate concerns. But composing methods is possible, so it is easy to put them all together.
-   Extracting reusable test specs to facilitate the correct/expected implementation of protocols
    -   It is a good idea to extract all of the method helpers into an extension of the `Specs` protocol where `Self: XCTestCase`. This is a very neat way to make all methods reusable. That way the client only needs to worry about the implementation and the tests are already written.
-   Using Swift’s protocol inheritance, extensions, composition, and conditional conformance to create clean & reusable abstractions
-   Creating explicit and straightforward test contexts
    -   Try that tests only have one assertion. Break it all down into as many tests as needed to achieve this.

#### 26.  Core Data Overview, Implementation, Concurrency Model, Trade-offs, Modeling & Testing Techniques, and Implementing Reusable Protocol Specs ✅

-   Core Data overview, implementation, concurrency model, trade-offs, modeling, and testing techniques
    -   Core Data is a persistence solution framework developed and maintained by Apple.
    -   An advantage is that it abstracts the details of mapping objects to a store, so interacting with the database directly is not needed.
    -   It offers a manager that allows rollbacks and tracking changes.
    -   Advantages:
        -   It implements efficient caching strategies and storage.
        -   The model relationships.
        -   Lightweight migrations
        -   Offers different ways so to deal with concurrency.
        -   It is possible to undo/rollback.
        -   Not needed to deal with databases directly.
    -   Disadvantages:
        -   It has a steep  learning curve.
        -   The architecture is comples.
        -   The backing stores are plain-text (e.g.: XML or SQLite). That means that there is not a an easy way to encrypt the data _yet_. Data-Production (Face|Touch-ID or password are the only security measure right now).

    > Core Data has a straightforward concurrency model: the managed object context and its managed objects must be accessed only from the context's queue. Everything below the context – i.e. the persistent store coordinator, the persistent store, and SQLite – is thread-safe and can be shared between multiple contexts.– Florian Kugler.

    -   `NSManagedObjectContext.perform` uses its own thread to execute blocks. This is very important not to cause concurrency issues. Its closure is executed asynchronously. The synchronous method is `performAndWait`. In this case the block is still executed in its own thread, but the method does not return until the block is returned.
    -   If the dataset is small, it is possible to load it to memory completely to operate on it. It is possible using `fetchBatchSize: 0` and `returnsObjectsAsFaults: false`.

-   Implementing reusable protocol specs

    > A lot of the downside of frameworks can be avoided by applying them selectively to solve difficult problems without looking for a one-size-fits-all solution – Eric Evans.

    -   Using the file URL `/dev/null` for persistent store makes that the Core Data stack does not save SQLite artifacts to disk, so the work happens in memory. This is faster when running tests and helps avoid side effects.
    -   If side effects are needed for testing, use an _in-memory store_. Just name the `dev/null` store like this:
    ```
    let storeURL = URL(fileURLWithPath: "/dev/null").appendingPathComponent("a name")
    ```

#### 27. Finishing the Cache Implementation with Business Logic + Core Data Integration Tests—Unit vs. Integration: Pros/Cons, Performance, Complexity & How to Achieve The ideal Testing Pyramid Distribution ✅

-   Unit/Isolated vs. Integration Tests: pros/cons, performance, complexity, and how to make the most out of both.
-   Achieving a healthy distribution of testing strategies (the ideal testing pyramid).
    -   A testing pyramid has Unit/Isolated tests as the base, Integration tests as the middle part and UI tests on the top. This is because the high cost/time of the ones above is higher.
    -   There is no common definition of what are unit, integration, UI, performance, etc. tests, so we will define one:
    -   One should be able to run isolated tests several times a day without affecting productivity.

        > **Integration Tests:** Any test that checks two or more components collaborating without mocks, stubs, spies, or any other test double. That is opposed to a single behaviour being checked by a single component in a unit or isolated test.

    -   The number of integration tests needed is equal the states that component A can have times the states that component B has, e.g.: 4x5 = 20 tests needed.
    -   When the system grows to hundreds of state, this becomes non-sustainable.


#### Persistence Module Learning Outcome ✅

-   `URLCache` as a caching/persistence alternative (pros and cons)
-   Depicting an architecture diagram of implicitly coupled Networking and Caching modules
-   Improving the test suite integrity by eliminating shared caching artifacts across test executions
-   Minimize risk by reviewing, refining and expanding the requirements iteratively
-   The importance of enhancing domain knowledge with consistent and clear cross-team communication
-   Advantages of iterative design over big upfront decision making
-   Decoupling business logic encapsulated in use cases from framework details
-   Test-driving and discovering collaborator interfaces without abstracting too early
-   Enriching test coverage by asserting the presence, the order, and values of method invocations
-   Disciplined application of the Interface Segregation and Single Responsibility Principles
-   Controlling the current date/time during tests
-   Checking expected behavior after deallocation
-   Identifying highly coupled modules with a visual representation of dependencies
-   Visualizing and solving dependency bottlenecks
-   Data transfer model representations for achieving modularity
-   Decentralizing components to develop and deploy parts of the system in parallel
-   The return on investment (ROI) of refactoring as a result of disciplined decoupling techniques
-   A Swifty way of translating models with Array type constraint extensions
-   Identifying coincidental duplication while respecting the DRY (Don’t Repeat Yourself) principle
-   Performing calendrical calculations correctly
-   Creating a simple DSL (Domain Specific Language) to decouple tests from implementation details
-   Increasing test coverage and reducing the probability of error by triangulating data points
-   Test-driving cache invalidation
-   Identifying bloated requirements
-   Identifying bloated code with the Command–Query Separation principle
-   Separating queries and side-effects by following the Command-Query Separation principle
-   Choosing between enum switch strategies: Explicit Cases vs. default vs. @unknown default
-   Producing a reliable codebase history (always in a working state)
-   Identifying Application-specific vs. Application-agnostic logic
-   Application-specific vs. Application-agnostic vs. Framework (Infrastructure) Logic
-   Entities vs. Value objects
-   Designing side-effect free (deterministic) core business rules
-   Establishing Functional Core, Imperative Shell
-   Promoting reusability and reducing cost, duplication, and defects with single sources of truth
-   The anatomy of Dependency Inversion (High-level, Low-level, and Boundary components)
-   Specs as Contracts
-   Proactively avoiding bugs caused by side-effects in multithreaded environments
-   Documenting infrastructure requirements with an Inbox checklist
-   Encoding and decoding models with `Codable`
-   Persisting model data to disk
-   Retrieving model data from disk
-   Test-driving infrastructure components in integration with real frameworks instead of mocks
-   Preventing hard-to-debug test issues in stateful components by cleaning up the system state before and after test executions
-   Preventing hidden-coupling implications of cross-boundary Codable requirements
-   Improving testability, maintainability, and reusability by moving from implicit hardcoded data to explicit data injection
-   Using `xcodebuild` to measure test times and discover potential overheads
-   Codebase health analysis
-   Turning async code into sync for expressiveness and readability in tests
-   Eliminating hard-to-read nested code (arrow-shaped code)
-   Monitoring the impact of refactoring with quantitative analysis
-   Improving test code by providing better names & making dependencies explicit
-   Designing and testing thread-safe components with DispatchQueue
-   Differences between serial and concurrent dispatch queues
-   Avoiding threading race conditions (e.g., data corruption/crashes)
-   Thread-safe(r) value types
-   Measuring test time overheads
-   Forming good abstractions by following the Liskov Substitution and Interface Segregation principles
-   Protocol vs. Class inheritance
-   Composite Reuse Principle (aka “Prefer composition over inheritance”)
-   Extracting reusable test specs to facilitate the correct/expected implementation of protocols
-   Using Swift’s protocol inheritance, extensions, composition, and conditional conformance to create clean & reusable abstractions
-   Creating explicit and straightforward test contexts
-   Core Data overview, implementation, concurrency model, trade-offs, modeling, and testing techniques
-   Implementing reusable protocol specs
-   Unit/Isolated vs. Integration Tests: pros/cons, performance, complexity, and how to make the most out of both.
-   Achieving a healthy distribution of testing strategies (the ideal testing pyramid).

#### Key Stats ✅

There are certain statistics that help have an overview over the health of the codebase. Examples are:

#####   Production report
<img src="/summary-images/production-report.png" width=40% height=40%>
-   The assignable `var` properties denote a mutable state and these ones are hard to maintain as they easily grow out of control.

#####   Testing report
<img src="/summary-images/test-report.png" width=40% height=40%>

#####   Repository report
<img src="/summary-images/repository-report.png" width=40% height=40%>


#### Bonus: Improving Model Composability With Swift’s Standard Result and Optional Types, Map, Functors, and Powerful Refactorings Backed by Tests and Types (Compiler!) ✅

-   Migrating Swift versions using a TDD + Git workflow
-   Refactoring code backed by tests and types
-   Modeling for simplicity and composability with Swift’s standard types (Array, Optional, Result…)
-   Map, Functors and composition

    >   Types that implement map (by following some rules) are called Functors.
    >   A Functor is “a mapping between categories where the structure is preserved.”

    -   The new `Swift.Result` has a new initializer that allows doing `Result { ... return / try }`
    -   `compactMapValues` is a nice method that allows mapping from dictionaries.

## UI + Presentation Module

#### 28. Gathering Fast Feedback and Validating UI Design and Dev Decisions Through Realistic App Prototypes ✅

-   Validating UI design and dev decisions through prototyping.
    -   🤩 A tip is to set `.defaultHigh` for vertical constraints in `TableViewCell`s. That prevents these ones from conflicting with other constraint and generating warnings.
    -   `clipToBounds = true` makes that subviews are not rendered outside of the corners.
-   A good set of checklist points to mark is:
    -   the design is polished following the specs (app icons, fonts, colors, margins, images, animations, etc.—aim for a realistic experience!)
    -   the content is localized, if your testers expect it to be
    -   the app works on all expected orientations
    -   the description on the tester invite is detailed and specific enough to avoid any confusion for the testers (with a clear way for testers to provide feedback!)
-   Working effectively with designers
-   Improving collaboration and getting fast feedback from clients with prototyping
-   Using Storyboards it is easy to quickly prototypes UIs and generate TF builds so design and product can test.
-   It is possible to fake asynchronous loading of images by setting the `alpha` to 0 on `prepareForReuse` and animate it to `1` when the image is set.

#### 29. Apple MVC, Test-driving UIViewControllers, Dealing with UIKit’s Inversion of Control & Temporal Coupling, and  Decoupling Tests from UI Implementation Details ✅

-   Validating UX experiences and exploring solutions through prototyping
-   Introduction to the MVC UI architectural design pattern
    -   A big missconception is that in MVC there is only one model: no, we need plenty of ones.
-   Test-driving MVC implementations
-   Testing effectively with 3rd-party frameworks
-   Preventing bugs caused by 3rd-party framework’s Inversion of Control and Temporal Coupling
    -   **Inversion of Control:** Any programming style where an overall framework or runtime controls the program flow.
    `UIKit` uses [Inversion of Control][9] a lot to notify of events, user actions, and view lifecycle events. This makes that we do not have a lot of control of when a view lifecycle starts/ends. We can only react to them whenever they happen. Also, view lifecycle events happen with an order, which introduces Temporal Coupling:

    > “Temporal Coupling is a common problem in API design. It occurs when there’s an implicit relationship between two or more members of a class, requiring clients to invoke one member before the other. This tightly couples the members in the temporal dimension.”—Dependency Injection: Principles, Practices, and Patterns by Mark Seemann & Steven van Deursen

-   Decoupling tests from UI implementation details
    -   It is important to include all the lifecycle events that have Temporal Coupling into the same test to still be able to execute in random order.
    -   It is good to only have one assertion per test, but it is encouraged to add more to tell a story when there is Temporal Coupling.
        -   Try to separate by logical units (e.g.: activity indicator is shown _when_).

#### 30. Effectively Test-driving MVC UI with Multiple Views/Models/State, Efficiently Loading/Prefetching/Cancelling Image Requests, Inside-Out vs. Outside-In Development, and Identifying the Massive View Controller Anti-pattern by Following Design Principles ✅

-   Inside-Out vs. Outside-In development approaches
    -   **Inside-Out:** You start by implementing Core functionality (Inside) and move to Outer layers (Out).
    -   **Outside-In:** One starts from the outer layers and ends with the core functionality.

    Both are very good. When one has the UI application upfront and not just use cases, the latter one makes more sense.
-   Efficiently loading images in UITableView cells
-   Efficiently prefetching images when cells are near visible
-   Efficiently canceling image loading requests to avoid excessive data usage
-   Managing multiple views, models, and state
-   Moving state management responsibility to clients with Return Values
    -   One alternative to reduce method counts in interfaces is to move the responsibility of keeping count of something to the client instead of having a method so outer entities take care of calling those methods from outside.
    -   Protocols should not be merged to be stateful, it means that one method should not depend on the existance of the other one.
-   Identifying the Massive View Controller antipattern
-   Test-driving UI components
-   Testing UIKit components without mocking
-   Creating in-memory UIImage representations for fast and reliable tests
    -   This can be done creating images of 1x1 size of a color with help of `UIGraphicsBeginImageContext`.
    -   Another good idea is to use `UITableViewDataSourcePrefetching` to prefetch images for rows.
-   Following the Open Closed, Interface Segregation, and Dependency Inversion Principles
    -   **Open Closed Principle:** A component should be open for extension, but closed for modification. This means one can extend the behaviour of the component without making changes to it.
    -   **Interface Segregation:** Protocols need to be kept concise and not have too many methods.

    It is common in iOS codebases to see huge protocols and implementations of them that run `fatalError`, which breaks Liskov's Principle.

> Keep in mind that your components will conform to the Open Closed Principle (OCP) as a result of respecting other principles such as the Interface Segregation (ISP), Liskov Substitution (LSP), Dependency Inversion (DIP) and Single Responsibility (SRP). Making sure to follow these guidelines will give you the freedom to extend your system with the minimum cost for changing it.

#### 31. Refactoring Massive View Controllers Into Multiple Tiny MVCs + Using Composers & Adapters to Reduce Coupling and Eliminate Redundant Dependencies ✅

-   Distributing the responsibilities of a view controller with other controllers to form a multi-MVC design
    -   It is a good idea to start breaking apart the modular design graph into linear dependencies that one can break apart.
    -   When a class extracts its logic to a collaborator, it wins two new tasks: create it (in some cases), and communicate with it.
    -   A factory does not solve this because the factory becomes a dependency of the controller.
-   Creating Composers to separate usage from creation and decoupling components
    -   When an instance creates its own helpers/collaborators, it ends up requiring extra dependencies just to create them. DI should be used to eliminate redundant dependencies.
        -   A class should not need something in its initializer just to be able to instantiate a helper!!
    -   There are two rules when using composers:
        -   Composers should only be used in the Composition Root
        -   Only Composers can use other Composers
    -   Do not charge instantiators with dependencies to be able to create an instance using the composer!!
-   Using the Adapter pattern to enable components with incompatible interfaces to work together seamlessly
    -   The adapter method is mapping structures from one context into another one to keep concerns separated while allowing collaboration.

    >   The purpose of an Adapter, also known as Wrapper, is to convert the interface of a component into another interface a client expects. It enables you to decouple components from complex dependencies.

In other words, the Adapter pattern enables components with incompatible interfaces to work together seamlessly.

- 🤩 The main takeaway is that:
    -   MVC does not only have one controller, it can have many Controllers
    -   MPV does not only have one presenter, it can have many presenters.
    -   MVVM does not only have one model, it can have a lot of different models and views.

#### 32. MVVM: Reducing Boilerplate, Shifting Reusable Presentation Logic from Controllers into Cross-Platform (Stateful & Stateless) ViewModels, and Decoupling Presentation from UI Frameworks with Swift Generics ✅

-   Improving architectural separation between UI and core components with View Models
-   Creating a reusable cross-platform Presentation layer with MVVM

    The goal of MVVM, created by Microsoft, was to eliminate the synchonisation of view events and model updates that controllers control in MVC.

    This binding happens automatically with help of a `ViewModel` (for Microsoft). This is a reason why MVVM is also known as MVB (Model-View-Binder). Swift generally uses RxSwift or Combine to make this binding happen.

    Here is a comparison between MVC and MVVM regarding their dependencies and flows:

    ![MVC vs MVVM][10]

    Notice the main difference is that the ViewModel does not hold a reference to the View as the Controller does in MVC.
    Not making the View and the ViewModel depend on each other makes everything more reusable. They should communicate through a binding mechanism. In UIKit the VC can do that as the app must have at least one.

    There is a lot of needed boilerplate, but view models allow reusability of UI components and a better architectural separation.

    One **important recommendation** is that view models are platform and framework agnostic so they can be easily re-used on all platforms.

-   Implementing Stateful and Stateless View Models
-   Using Generics to create reusable components

    An example of Dependency Injection together with Swift's generics together to create a modular design is injecting a transformer from Data to Image in order to stay away from having the ViewModel depend on UIKit. Example:

    For UIKit:
    ```
    FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
    ```
    For WatchKit:
    ```
    FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: WKImage.init)
    ```

    > You don’t have to choose between MVC or MVVM. You can mix and switch MVC with MVVM to organize your UI layer as needed. We recommend you to use the best option for the problem at hand. For example, if you find yourself duplicating code across View Controllers or performing value transformations in View Controllers, you should think of moving the logic to a reusable platform-agnostic ViewModel. Otherwise, a simple MVC solution would do just fine. Caio & Mike.

#### 33. MVP: Creating a Reusable and Cross-Platform Presentation Layer, Implementing Service Adapters, and Solving Cyclic Dependencies & Memory Management issues with the Proxy Pattern ✅

-   Creating a reusable cross-platform Presentation Layer with MVP
    MVP is like MVC, but with a Presenter instead of a Controller. MVP allows, besides a cross-platform and reusable presentation layer, a clear separation between UI and presentation logic. In MVP the View holds a reference to the Presenter and sends events to it. The Presenter then updates an `AbstractView` protocol that the View implements.
    ![MVC vs MVP][11]
-   Improving architectural separation between UI and core components with Presenters
    And important separation is that teh `AbstractView` belogs inside the presentaion layer. That helps the implementation of the presenter to not depend on the UI layer.

    🧯☣️ The two-way communication view -> presenter, presenter -> view creates a **potential retain cycle**. It is important to watch out for memory management when using MVP.

    📚 The `<AbstractView>` can be several protocols as different views may be in charge of different tasks and in ordre to maintain Interface Segregation Principle, we do not want one protocol with all methods.

    One important difference to MVVM is that the ViewModels only hold data, not a beheaviour. The Presenter merely passes data to the view via the ViewModel, but it takes care of transforming the data itself.
-   Implementing various MVP solutions
    The most typical way is having a bi-directional Presenter <-> View communication where the `View` holds a reference to the `Presenter` and the `Presenter` a (weak) reference to the `<Abstract View>`.

    -   Option 1: A UIKit view subclasses `<AbstractView>`. It sends the events to the Presenter.
    -   Option 2: A UIKit `UIViewController` subclasses `<AbstractView>`, it translates the protocol methods into actions for its view and sends the view's events to the Presenter
    -   Option 3: Same as in option 2, but the `View` does not hold a strong reference to the presenter directly, instead it holds a reference to a `<PresenterProtocol>`
    -   Option 4: Using an Adapter and injecting dependencies in the composer the Presenter is leaner and everything is more re-usable. The Adapter translates events into `<Service>` methods and delegates state changes and responses to the presenter.
    > “An ADAPTER is a wrapper that allows a client to use a different protocol than that understood by the implementer of the behavior. When a client sends a message to an ADAPTER, it is converted to a semantically equivalent message and sent on to the “adaptee.” The response is converted and passed back[…]

    > For each SERVICE we define, we need an ADAPTER that supports the SERVICE’S interface and knows how to make equivalent requests of the other system[…]

    > The ADAPTER’S job is to know how to make a request. The actual conversion of conceptual objects or data is a distinct, complex task that can be placed in its own object, making them both much easier to understand. A translator can be a lightweight object that is instantiated when needed."—Eric Evans “Domain-Driven Design: Tackling Complexity in the Heart of Software

    All of them are good to use, Option 1, 2 being the easiest ones, 3 and 4 being more reusable in exchange. Using 3 and 4 also has more levels of indirection, so less quick readability.

-   Differences between ViewModels in MVVM, MVC, and MVP
    A ViewModel in MVP is called `ViewData`, meaning it only holds data, it has no behaviours.
-   Implementing the Proxy design pattern
    It is possible to move the memory management concerns to the composition layer (instead of just marking a variable as `weak`). Using the proxy pattern. This proxy is not weak, but it holds a weak reference to the final object (in this case the presenter). The proxy can implement the protocol and pass all requests to the objects it holds, but the caller has the impression it is dealing with the real implementation.
-   Identifying and solving Cyclic Dependencies
    A Presenter having a weak optional view that needs to be injected introduces temporal coupling as there is a time when the presenter does not have all its dependencies available. We can solve this by moving it into the Composition Layer and using the proxy design pattern to wrap the View.
-   Dealing with Memory Management in the Composer layer to prevent leaking composition details into components

#### 34. Storyboard vs. Code: Layout, DI and Composition, Identifying the Constrained Construction DI Anti-pattern, and Optimizing Performance by Reusing Cells ✅

-   Trade-offs of creating the app layout in storyboards vs. programmatically.
    Code is the most efficient, reusable and flexible option. But storyboards make it easier to create simple layouts.
    Storyboards are good to start, but do not scale well because they mix too many things (Layout, Navigation, Compsition, etc.). They are recommended only for Layout purposes.

-   Dependency Injection and component composition with storyboards
    One big downside is that all storyboard views need to be instantiated using the same constructor: `init?(coder: NSCoder)`. This makes it impossible to use DI through the constructor. It needs to be Property Injection. A consequence of this is that the properties cannot be private in order to allow injection.

    > When you move object instantiation and composition to a centralized place, Dependency Injection becomes much easier, simpler, and safer. Additionally, you minimize the shortcomings of DI with Storyboards.

-   Optimizing UITableView performance by reusing cells
    Re-used cells can be modified by other controllers when they are already out of screen, causing faulty behaviours. This can be tested against in order for the test to fail. Once the faulty behaviour is fixed, the test starts passing.
    The fix can happen setting the cell to `nil` inside `tableView(:didEndDisplaying cell`

#### 35.  Creating, Localizing, and Testing Customer Facing Strings in the Presentation Layer + NSLocalizedString Best Practices ✅

-   Localizing strings within various UI design patterns (MVC, MVVM, MVP)
    -   In **MVC** the Controller is the String creator.
    -   In **MVP** the Presenter is the String creator.
    -   In **MVP** the ViewModel is the String creator.
-   NSLocalizedString best practices
    -   Write tests for the keys of the strings, not for the values as tests can run in different countries.
    -   The `key` should not be the default value as it can be buggy.
    -   `NSLocalizedString` uses the underlying bundle, so it is the same as `Bundle(for: SomeClass.self).localizedString(...)`
-   Creating and managing customer-facing strings in the Presentation Layer (away from Business Logic!)
-   Testing customer-facing strings
    -   To test the values use snapshot/screenshot tests.
    -   Test that all keys used across the project have values for each supported language. This is possible by accessing each bundle and treating the `.strings` files as keys-values dictionaries.

#### 36. Decorator Pattern: Decoupling UIKit Components From Threading Details, Removing Duplication, and Implementing Cross-Cutting Concerns In a Clean & SOLID Way ✅

-   Decoupling UIKit components (and any other client) from threading details
    -   Decorating the behavior of objects, should make the components lighter, reduce duplication, and contribute to their open/closed nature.
-   Removing duplication and centralizing threading logic in the composition layer
    -   If the UI or Presentation layer dispatch UI changes in the main thread (UIKit needs it), we'd be disclosing info on how the Business happened in background threads and we do not want that. To avoid this, the dispatching can be moved to the composition layer and/or using a decorator.
-   Decorator pattern: Extending behavior of individual objects without changing its implementation or subclassing (Liskov Substitution + Open/Closed Principles)
    -   The decorator implements the protocol of the decoratee so it can be passed as if it were the decoratee itself:
    ```
    class Decorator: T {
      let decoratee: T
    }
    extension Decorator: SomeProtocol where SomeProtocol == T {
      func someMethodFromSomeProtocol(...) {
        // Extra implementation details go here!
        decoratee.someMethodFromSomeProtocol(...)
      }
    }
    ```
-   Decorator pattern: Implementing Cross-Cutting concerns (Single Responsibility Principle)
    -   When capturing `self` inside of `async`, since it is not run immediately, the strong reference will not be deallocated when it needs to be and it can cause a memory leak => **ALWAYS WEAKIFY**.

#### 37. Test-driven Approach to Effectively Dealing with Legacy Code (Code With No Tests!) + Extracting Cross-platform Components From a Platform-specific Module ✅

-   One method is to re-write a piece of logic into a slightly differently named class/struct. Re-write using TDD and copy-paste the solutions from the legacy code.
-   Copy the least to make things work.
-   Make sure that the constructor does not do any work, start with the most simple behaviours.
-   A code needs to fail before one starts copy-pasting code.

#### UI + Presentation Module Learning Outcome ✅


-   Validating UI design and dev decisions through prototyping
-   Working effectively with designers
-   Improving collaboration and getting fast feedback from clients with prototyping
    -   Best use for storyboards.
-   Separating platform-specific and platform-agnostic components in Xcode using Swift frameworks
-   Supporting multiple platforms on Swift frameworks
    -   Use composers to inject factory methods for different platforms in one place. That way the main logic remains platform agnostic.
-   Configuring Xcode Targets and Schemes to build and test all supported platforms on the continuous integration (CI) pipeline
-   Validating UX experiences and exploring solutions through prototyping
-   Introduction to the MVC UI architectural design pattern
-   Test-driving MVC implementations
-   Testing effectively with 3rd-party frameworks
-   Preventing bugs caused by 3rd-party framework’s Inversion of Control and Temporal Coupling
-   Decoupling tests from UI implementation details
-   Inside-Out vs. Outside-In development approaches
-   Efficiently loading images in UITableView cells
-   Efficiently prefetching images when cells are near visible
-   Efficiently canceling image loading requests to avoid excessive data usage
-   Managing multiple views, models, and state
-   Moving state management responsibility to clients with Return Values
-   Identifying the Massive View Controller antipattern
-   Test-driving UI components
-   Testing UIKit components without mocking
-   Creating in-memory UIImage representations for fast and reliable tests
-   Following the Open Closed, Interface Segregation, and Dependency Inversion Principles
-   Distributing the responsibilities of a view controller with other controllers to form a multi-MVC design
-   Creating Composers to separate usage from creation and decoupling components
-   Using the Adapter pattern to enable components with incompatible interfaces to work together seamlessly
-   Improving architectural separation between UI and core components with View Models
-   Creating a reusable cross-platform Presentation layer with MVVM
-   Implementing Stateful and Stateless View Models
-   Using Generics to create reusable components
-   Creating a reusable cross-platform Presentation Layer with MVP
-   Improving architectural separation between UI and core components with Presenters
-   Implementing various MVP solutions
-   Differences between ViewModels in MVVM, MVC, and MVP
-   Implementing the Proxy design pattern
-   Identifying and solving Cyclic Dependencies
-   Dealing with Memory Management in the Composer layer to prevent leaking composition details into components
-   Trade-offs of creating the app layout in storyboards vs. programmatically
-   Dependency Injection and component composition with storyboards
-   Optimizing UITableView performance by reusing cells
-   Localizing strings within various UI design patterns (MVC, MVVM, MVP)
-   NSLocalizedString best practices
-   Creating and managing customer-facing strings in the Presentation Layer (away from Business Logic!)
-   Testing customer-facing strings
-   Decoupling UIKit components (and any other client) from threading details
-   Removing duplication and centralizing threading logic in the composition layer
-   Decorator pattern: Extending behavior of individual objects without changing its implementation (Liskov Substitution + Open/Closed Principles)
-   Decorator pattern: Implementing Cross-Cutting concerns (Single Responsibility Principle)
-   Extracting cross-platform components from a platform-specific module
-   Test-driven approach to testing components that have been implemented already (test-after)

#### Recommendation on how to implement MVC ✅

```
|MODEL| - - observer/callback- - -> |CONTROLLER| -----updates----->|VIEW|
|MODEL| <---------manages---------- |CONTROLLER| <- - events - - - |VIEW|
```
-   The **model** is platform-agnostic and represents services and domain data. The are decoupled from the controller and from the view.
-   The **view** is decoupled from the controller and, at its best, also from the model. It represents what the user can interact with.
-   The **controller** is the middleman between the model and the view. It receives events from the View and gives commands to the model depending on the action/event. In the other direction it is notified on model changes and it makes sure the view is updated.

The controller should be lean and should not transform data, nor should the model. So the controller should have _collaborators_ to translate data from the model to displayable data for the view. An _adapter_ can also take care of transforming model data into view viewModels.

Also, very important, in MVC the model **does not have a behaviour**, it only holds data.

#### Recommendation on how to implement MVVM

```
|MODEL| - - observer/callback- - -> |VIEW MODEL|- - -notifies on state changes- - -> |VIEW|
|MODEL| <---------manages---------- |VIEW MODEL| <- - - - - - - events - - - - - - - |VIEW|
                                    |VIEW MODEL| <----binds----|BINDER|----binds>----|VIEW|
```
-   The **model** is platform-agnostic and represents services and domain data. The are decoupled from the ViewModel and from the View.
-   The **view** is decoupled from the domain models and represents what the user can interact with.
-   The **viewModel** is the communicating bridge between the Model and the View and is _binded_ by a Binder component. The view model translates model data into displayable data for the view. It is important to notice that these view models have both dependencies and behaviours.

The VCs are usually good places to make the binding happen. In UIKit, since the view is inside the `UIViewController`
, the controller is considered part of the View.

#### Recommendation on how to implement MVP ✅

```
|MODEL| - - observer/callback- - -> |PRESENTER|<---- events ---- |VIEW| - - - -> |ABSTRACT VIEW|
|MODEL| <---------manages---------- |PRESENTER|------------ updates------------> |ABSTRACT VIEW|

```

-   The **model** is platform-agnostic and represents services and domain data. The are decoupled from the Presenter and from the View.
-   The **view** is decoupled from the domain models and represents what the user can interact with. The presenter does not know which one is the view, it only holds a reference to the protocol (Abstract View) and the View conforms to this protocol.
-   The **presenter** manages the model and receives data from the model. It transforms this data into displayable data for the Abstract View
-   The **view model** (also known as Presentable Model or ViewData) only holds representable data, no behaviour.

Just like in MVVM, the UIViewController is considered part of the View. It is then typical that the VCs implement the Abstract View protocols.

> Regardless of the pattern you choose, focus on the goal: simple, testable, and loosely coupled components. When you achieve this goal, you are free to easily develop, maintain, extend, and test your modules in isolation.

-   Avoid Frankestein Architectures by keeping transparent and clear communication, pairing development, having good training and effecting refactoring and codebase maintenance.


#### 38. Feed Image Data Loading and Caching with URLSession/CoreData + Composing Modules Into a Running iOS Application with Xcode Workspaces ✅


-   Breaking responsibilities into multiple protocols (Interface Segregation Principle) to achieve flexible, composable and modular components.
    -   **Good abstractions should contain methods the clients need, not methods that are put together because they are related** -> (ISP) Interface Segregation Principle.
    >  Single Responsibility Principle: a component should have only one reason to change

-   Combining Xcode projects into a workspace and embedding frameworks to compose modules into a running iOS app.
    > Allows External Storage […] lets Core Data decide whether it stores binary data within SQLite or as external files, based on the size of the data. The underlying SQLite database can efficiently store binary data up to roughly 100 kilobytes directly in the database. This option should generally be enabled.

-   Create workspace
    Drag and drop the projects into the final project that will put them all together. Create the workspace file under that folder. Close Xcode with all other projects and re-open the workspace to have access to all projects in Xcode.
    In order to use frameworks, embed them under `Embed Frameworks`
    Workspace can be found here: https://github.com/lfcj/EssentialApp. To get this one to work, make sure to close this EssentialFeed project paralel to the EssentialApp one.

#### 39. Composite Pattern: Implementing a Flexible & Composable Strategy for Loading Data with Fallback Logic ✅

-   Testing component behavior with the Stub test-double
    A Stub does not capture values like the Spy does. It only has predefined behaviours.
-   Creating a flexible and modular strategy for loading data from remote with fallback logic without altering the services or the clients (Open/Closed Principle).
    ```
    class RealType1: Interface { ... }
    class RealType2: Interface { ... }
    ```
    -   **Composition with concrete types**: The Composite conforms to the common protocol, but depends on the actual types involved.
    ```
    class Composite: Interface {
      init(type1: RealType1, type2: RealType2) { ... }
    }
    ```
    -   Compile-time type checks for composing the correct objects.
    -   The composite is coupled with the concrete types.
    -   Testing the composite would be done in integration with the concrete types instead of in isolation. Any change in the public interfaces of the concrete Types would potentially break the composite tests. It converts the unit tests to an integration tests cuz the dependencies need to be setup.

    -   **Composition with abstract types:** The Composite conforms to the common protocol and depends on the same protocol for its dependencies.
    ```
    class Composite: Interface {
      init(type1: Interface, type2: Interface) { ... }
    }
    ```
    -   Working with abstractions as dependencies instead of concrete types increases our flexibility.
    -   Can test the Composite in isolation as opposed to integration.
    -   Can't enforce compile-time checks for passing the dependencies in the correct order, meaning one can do both:
    ```
    Composite(type1: RealType2(), type2: RealType1())
    Composite(type1: RealType1(), type2: RealType2())
    ```

    -   **Composition with custom protocol abstractions:** The Composite conforms to the protocol and its dependencies depend on protocol extensions.
    ```
    protocol Dependency1: Interface {}
    protocol Dependency2: Interface {}
    extension RealType1: Dependency1 {}
    extension RealType2: Dependency2 {}
    class Composite: Interface {
      init(type1: Dependency1, type2: Dependency2) { ... }
    }
    ```
    -   Compile-time type checks for composing the correct objects.
    -   The composite is coupled with the concrete types.
    -   Can test the composite in isolation.
    -   End up with more types and more complexity.

    -   **Composition without remote or local notions:** The Composite conforms to the protocol and just depends on a primary and fallback dependencies that both conform to the protocol as well.
    ```
    class Composite: Inteface { // A good name is "<Interface>WithFallbackComposite"
      init(primary: Interface, fallback: Interface) { ... }
    }
    ```
    -   Working with abstractions as dependencies instead of concrete types increases our flexibility.
    -   Can test the composite in isolation.
    -   Working with abstractions that can be composed infinitely.
    -   Flexible strategy not constrained to a remote/local paradigm.
-   Composing objects that share a common interface with the Composite Design Pattern

-   📚 The Composite design pattern allows you to compose objects into tree structures to represent part or whole hierarchies. A Composite enables its clients to treat individual objects and compositions of objects uniformly, through a single interface. Clients using a Composite then do not care if they are treating a final implementation or another layer that wraps a protocol implementation itself.

**Patterns**

**Strategy Design Pattern**
>  “Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from clients that use it.

> Use the Strategy pattern when:

> • many related classes differ only in their behavior. Strategies provide a way to configure a class with one of many behaviors.
> • you need different variants of an algorithm. For example, you might define algorithms reflecting different space/time trade-offs. Strategies can > be used when these variants are implemented as a class hierarchy of algorithms.
> • an algorithm uses data that clients shouldn’t know about. Use the Strategy pattern to avoid exposing complex, algorithm-specific data structures.
> • a class defines many behaviors, and these appear as multiple conditional statements in its operations. Instead of many conditionals, move related conditional branches into their own Strategy class.”— Gamma, Johnson, Vlissides, Helm, “Design Patterns”

**Chain of Responsibility Design Pattern**
> “Avoid coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. Chain the receiving objects and pass the request along the chain until an object handles it.

> Use Chain of Responsibility when:

> • more than one object may handle a request, and the handler isn’t known a priori. The handler should be ascertained automatically.
> • you want to issue a request to one of several objects without specifying the receiver explicitly.
> • the set of objects that can handle a request should be specified dynamically.”— Gamma, Johnson, Vlissides, Helm, “Design Patterns”

#### 40. Interception: An Effective, Modular and Composable Way of Injecting Behavior and Side-effects in the App Composition ✅

-   Isolating side-effects to create simple, testable, and composable operations (Command-Query Separation Principle).
    1.  We have a module Feed API to communicate with the backend and, to keep the Single Responsability Principle, we want to keep it that way. We'd break this if it learns about the caching use case.
    2.  When we fetch information with Queries (`load`), we do not want them to make changes in the system (Command-Query Separation Principle), so the only way to support caching/saving is injecting that behaviour.
    3.  If we add a `save` method to the main protocol, we'd break the Liskov Substitution Principle because not all implementations could conform to this method. Moreover, not every client needs the behaviuor, so we'd also break the Interface Segregation Principle.
    4.  Using the Open/Close Principle we want to inject the `save` logic and the idea is to find a composable solution that does not need inheritance in order to keep the Interface Segregation Principle intact.

    The solution to fulfil adding the `save` behaviour while maintaining the good principles is using **Decorator**.
-   Using the Decorator Design Pattern to intercept and inject side-effects in the system composition, supporting single-purpose, testable, and modular components.

    A **Decorator** can be used to easily inject/extend/alter behaviour in a single-purpose abstraction.
    In our case the Decorator maintains the main logic and extends it to support saving.
-   Using the Decorator Design Pattern to extend the behavior of a component without altering it (Open/Closed Principle).

    > A Decorator works by wrapping one implementation of an Abstraction in another implementation of the same Abstraction. This wrapper delegates operations to the contained implementation, while adding behavior before and/or after invoking the wrapped object.

    > The ability to attach responsibilities dynamically means that you can make the decision to apply a Decorator at runtime rather than having this relationship baked into the program at compile time, which is what you’d do with subclassing.

    > A Decorator can wrap another Decorator, which wraps another Decorator, and so on, providing a “pipeline” of interception.” – Dependency Injection: Principles, Practices, Patterns by Mark Seemann and Steven van Deursen

-   If we have extensions that are not interesting to all test cases, then an easy route is to create a class with that extension alone:
    ```
    class <Protocol>TextCase: XCTestCase {
      func reusableMethod(...)
    }
    ```
    And all tests that will need that extensio can inherit from `<Protocol>TestCase`.

    On the other hand, in order to make it composable, it is better to make `<Protocol>TextCase` a protocol itself.

-   A good reason to prefer protocols per implementation is to make testability higher when objects are coupled, that allows us to inject fake objects rather quickly without having to configure the object from scratch.

#### 41. Validating Acceptance Criteria with High-Level UI Tests, Controlling Network and App State in UI tests with Launch Arguments and Conditional Compilation Directives ✅

-   Validating your app’s acceptance criteria with high-level UI tests.
    -   It is important to utilize the accessibility identifiers in order to test UI.
    -   Even if they are executed randomly, they still keep a state, so it is important to reset data at the beginning of every test.
    -   UI tests should test the bare minimum. Testing too many details can produce flaky scenarios. We want to test **Acceptance Criteria**, very high level conditions or business requirements.

    > In teams following BDD or similar processes, the acceptance criteria and tests are written by business folks (e.g., business analysts), and they are implemented by QA engineers.

-   Replacing and controlling flow logic and state in black-box UI tests.
    -   Every UI test starts with `XCUIApplication`, a proxy for an app that can be started, killed, and interacted with.
    -   The way to control states is the same one as when you see the app: with taps, gestures, etc. To change states it is necessary to do the same as the user would do, e.g.: To sign in, you need to use username and password and so on.
    -   The main way to pass on "UI test only" data is using the `launchArguments`, e.g.:
    ```
    let app = XCUIApplication()
    app.launchArguments = ["-connectivity", "offline"]
    ```
    Access these arguments through the [`CommandLine.arguments`][12] or (parsing them) through `UserDefaults.standard`. The first ones are good when there is no value for an option, e.g: `--no-edit`, but if one has `-option value` and wants to get `value`, use the `UserDefaults.standard` to convert to String, boolean or what is expected.
    -   These arguments can be used to inject data/states into the launched app.
-   Utilizing conditional compilation directives to safeguard your app from debug- and test-specific details.
    -   It is important to pay attention to not mixing test and production code, and **very important**, not to leak testing code to production. This can make that hackers take control of the state of our app via command line arguments.
    -   Use compiler macros ([compilation directives][13]) such as `#if DEBUG` or `#if TESTING` to not put test-only code in production.
-   Subclassing and extending components to remove conditional logic resulting in clean, decoupled, maintainable, and testable components.
    -   We do not want a bunch of macros `#if` inside of our production code, so one way is to use subclasses or extension to replace components with test-only ones when testing. That way the definition of the components can be wrapped in a macro itself.
-   Use stubbed data in order not to depend on network connectivity and diminish the level of flakiness.

-   Avoid using the queries such as `cells` or `images`. Instead use `.matching(identifier:)`. This is less flaky
    So avoid `app.cells` alone and do `app.cells.matching(identifier:)`, for example.
    
-   UI tests need to be reset because they keep a state, so it is important to clean the state before running any tests.
-   Never interfere with business logic to run UI tests, only change infrastructure details like the network client.

#### 42. Validating Acceptance Criteria with Fast Integration Tests, Composition Root, and Simulating App Launch & State Transitions ✅

-   Validating acceptance criteria with Integration Tests.
-   Replacing UI Tests with significantly faster and thorough Integration Tests.
-   What's a Composition Root
    This is a concept, not a concrete class or method.
    Classes should be composed at a single place of the app. This is a kind of third party that connects consumers with their services. It should be places as close as possible to the entry point of the app.
    Modules should have as little dependencies from each other as possible, so the composition root should take care of making them work together.
-   Where's the Composition Root in iOS apps
    Historically in the AppDelegate's `didFinishLaunchingWithOptions` method. Newly inside the `SceneDelegate`s `willConnectToSession`.
    Frameworks SHOULD NOT have composition roots.
-   How to test components of the Composition Root
    Since the Composition Root depends on other modules and none depend on it, this is the correct place to import the modules it depends on using the `@testable` modifier.
    This is because the Composition Root logic does not need to be `public` at all (again, no other module should depend on it). 
-   Simulating app launch and state transitions during tests
    It is possible to instantiate a `SceneDelegate` or an `AppDelegate` and call the entry methods to simulate launching the app. So it is good to try and not use UI tests, but integration tests whenever possible as they can easily be 100 times faster.
-   Testing methods you cannot invoke
    A workaround is to create a method that is invoked when calling a different method that is "hard" to call. So if one needs to inject a window or similar in order to test something, one can separate the logic into a new method and only call that method.

#### 43. Validating the UI with Snapshot Tests + Dark Mode Support ✅

-   Validating the app’s UI with Snapshot Testing
    The idea of snapshot testing is that we take a snapshot/screenshot of the UI at a point when we are happy with it. We then save it in the file system.
    Our snapshot tests then consist of taking new snapshots and comparing them to the ones saved.
    
    -   A good usage is reviewing PRs as the image is saved automatically.
    -   They are a better alternative than UI tests.
    -   Good to test multi-line screens.
    -   Snapshot tests just test the rendering, they do not test logic.
    
    Here how to take a snapshot:
    ```
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
    ```

    ##### Downsides
    -   Reliability on a specific device.
    -   Runtime is faster than UI tests, but slower than Unit tests. Writing and reading from the file system is also a bottleneck.
    -   The error is not precise, it is needed that a dev takes a look at the two images to see what is wrong and start investigating.

-   Supporting Dark Mode
    For this it makes sense to create a `SnapshotWindow` that takes on any possible `SnapshotConfiguration` so one can pack the view or the view controller insider the window (configured as one wants), and take the screenshot:
    ```
    struct SnapshotConfiguration {
        let size: CGSize
        let safeAreaInsets: UIEdgeInsets
        let layoutMargins: UIEdgeInsets
        let traitCollection: UITraitCollection

        static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
            SnapshotConfiguration(
                size: CGSize(width: 375, height: 667),
                safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
                layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
                traitCollection: UITraitCollection(
                    traitsFrom: [
                        .init(forceTouchCapability: .available),
                        .init(layoutDirection: .leftToRight),
                        .init(preferredContentSizeCategory: .medium),
                        .init(userInterfaceIdiom: .phone),
                        .init(horizontalSizeClass: .compact),
                        .init(verticalSizeClass: .regular),
                        .init(displayScale: 2),
                        .init(displayGamut: .P3),
                        .init(userInterfaceStyle: style)
                    ]
                )
            )
        }
    }

    final class SnapshotWindow: UIWindow {
        private var configuration: SnapshotConfiguration = .iPhone8(style: .light)

        convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
            self.init(frame: CGRect(origin: .zero, size: configuration.size))
            self.configuration = configuration
            self.layoutMargins = configuration.layoutMargins
            self.rootViewController = root
            self.isHidden = false
            root.view.layoutMargins = configuration.layoutMargins
        }

        override var safeAreaInsets: UIEdgeInsets {
            configuration.safeAreaInsets
        }

        override var traitCollection: UITraitCollection {
            UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
        }

        func snapshot() -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: bounds, format:  UIGraphicsImageRendererFormat(for: traitCollection))
            return renderer.image { action in
                layer.render(in: action.cgContext)
            }
        }

    }
```
-   Rendering views without running the app
    This is great to pass designers rendered UI in a quick way.

-   📚 Table header views do not play nicely with autolayout, so headers need to be resized manually.

#### 44. Preventing a Crash when Invalidating Work Based on UITableViewDelegate events ✅

-   Fixing bugs and preventing regressions following the TDD process
    -   To fix a bug, first create test that fails because of it.
    -   Fix the bug, check how test passes.
-   UITableViewCell reuse cycle: `didEndDisplaying` is also called when one calls `tableView.reloadData()`
    -   When `didEndDisplaying` cell is called, it is possible the data used for the table view has changed.
    If we are accessing the model to run logic, such as cancelling getting images for a cell, then it may happen that we run into a crash. See example:
    ```
    model has 2 items
    willDisplay is called for 2 items. Fetching of 2 images start for each cell
    
    model changes right then, it now has 0 items.
    didEndDisplaying is being called for the 2 items -> we access the model to cancel fetching the image. Crash is model has 0 elements. 
    ```
-   Invalidating work based on UITableViewDelegate events
-   Enforcing UITableView delegate events in Integration Tests
    In order to test these kind of scenarios it is important to force update the tableView when we change the model:
    ```
    tableView.layoutIfNeeded()
    Runloop.main.run(until: Date())
    ```

[1]: https://www.essentialdeveloper.com/articles/the-minimum-you-should-do-to-prevent-memory-leaks-in-swift

[2]: https://www.essentialdeveloper.com/articles/xctest-swift-setup-teardown-vs-factory-methods

[3]: https://github.com/lfcj/EssentialFeed/commit/9aec96725975871f560aec63c7a712e13f2c0b14

[4]: https://www.youtube.com/watch?v=C2GyNTN4j4o

[5]: https://www.youtube.com/watch?v=qzTeyxIW_ow&list=PLyjgjmI1UzlSWtjAMPOt03L7InkCRlGzb&index=5

[6]: /summary-images/data-task-possible-results.jpg

[7]: https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/WhyNetworkingIsHard/WhyNetworkingIsHard.html#//apple_ref/doc/uid/TP40010220-CH13-SW3

[8]: https://www.essentialdeveloper.com/articles/how-safe-are-swift-structs

[9]:  https://martinfowler.com/bliki/InversionOfControl.html

[10]: /summary-images/mvc-vs-mvvm.png

[11]: summary-images/mvc_vs_mvp.png

[12]: https://developer.apple.com/documentation/swift/commandline/2294816-arguments

[13]: https://docs.swift.org/swift-book/ReferenceManual/Statements.html11
