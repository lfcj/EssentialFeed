# iOS Lead Essentials Course

[![iOS Essential Feed Automation Tests](https://github.com/lfcj/EssentialFeed/actions/workflows/ios.yml/badge.svg)](https://github.com/lfcj/EssentialFeed/actions/workflows/ios.yml)

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
    -   Naive calendrical calculations can be very bad for UX. Calendars are full of edge cases.
    -   Use the native `Calendar` as much as possible to avoid calculations.
    -   Tests should be calendar/timezone agnostic whenever possible.
-   Creating a simple DSL (Domain Specific Language) to decouple tests from implementation details.
    -   An example of this are methods in extensions to make our codebase more readable and more adjusted to the domain needs.
-   Increasing test coverage and reducing the probability of error by triangulating data points.
    -   When testing, triangulation is done by thinking of three points regarding each reality, e.g: what if less, what if equal, what if more?

[1]: https://www.essentialdeveloper.com/articles/the-minimum-you-should-do-to-prevent-memory-leaks-in-swift

[2]: https://www.essentialdeveloper.com/articles/xctest-swift-setup-teardown-vs-factory-methods

[3]: https://github.com/lfcj/EssentialFeed/commit/9aec96725975871f560aec63c7a712e13f2c0b14

[4]: https://www.youtube.com/watch?v=C2GyNTN4j4o

[5]: https://www.youtube.com/watch?v=qzTeyxIW_ow&list=PLyjgjmI1UzlSWtjAMPOt03L7InkCRlGzb&index=5

[6]: /summary-images/data-task-possible-results.jpg

[7]: https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/WhyNetworkingIsHard/WhyNetworkingIsHard.html#//apple_ref/doc/uid/TP40010220-CH13-SW3
