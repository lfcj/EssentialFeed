# iOS Lead Essentials

Github: https://github.com/lfcj/EssentialFeed

## Networking Module

#### 1. From Singletons and Globals to Proper Dependency Injection ✅

* It is about singletons, Singletons, and inverse dependency injection by which it is easier to decouple from third party libraries

#### 2. Asserting a Captured Value Is Not Enough + Cross-Module Access Control ✅

* Public vs @testable, using spy objects in tests to extend coverage and not only asserting captured value, but other data like how often a method is called.

#### 3. Handling Errors + Stubbing vs. Spying + Eliminating Invalid Paths ✅

* Here we look into handling network errors and talk about the differences between stubbing and spying when unit testing. Designing better code with enums to make invalid paths unrepresentable
* A spy should not perform actions, a stub can do that, e.g.: If the client has errors that can be injected, the spy should not have to decide if it finishes with an error or not.
* Spies are usually test-helpers with a single responsibility of capturing the received messages.
* In order to keep the spy not stubbing we make sure the spy keeps track of/captures all the actions/completions.
* Spies should not have predefined behaviour, the user of the spy should decided what to do with the values the spy has captured.
* Replacing stubbing with capturing/spying allows us to better test asynchronous behaviour with completion closures.
* With a stub the stub would need to re-use an injected error when a method is called. With a spy, the completion is captured and one can later do spy.completions[index](Error(..))
* By not capturing paths with enums but with options, we allow scenarios in which, for example, both error + response as nil or non-nil at the same time. That should never happen.

    ### Stubs and Spies are test-doubles. 📚💡

	a. A Stub is used to set predefined behaviors or responses during tests. For example, you 		can create a Stub to provide "canned" HTTP responses (e.g., predefined JSON data or 			error).

	b. A Spy collects or "records" usage information such as method invocation count and 			values received. So you can use/verify them later in the test.

	A Spy is often also a Stub, as you can choose to set predefined actions/responses into it.

#### 4. A Classicist TDD Approach (No Mocking) to Mapping JSON with Decodable + Domain-Specific Models ✅


* Diffs and trade-offs between mocking vs testing collaborators in integration
* Mapping JSON data to native models with Decodable.
* Simplifying tests leveraging factory methods and test helper functions.
* When small and readable, keep JSONs as text in the tests, avoid putting them in files. Debugging becomes easier.
* It is important to pass file and line to the XCTAssert.. method when they are called in a helper method.
* Do not couple modules in the Decodable extensions. The API module should own the JSON keys.

#### 5. Automating Memory Leak Detection + Preventing a (Way Too Common) Async Bug ✅

* It is possible to implement automating memory leak detection with tests
* Use addTeardownBlock inside factory methods to make sure that instances are deallocated after the tests have been run.
* Clients should not parse data inside results when self has already been deallocated. Tests should be written for this.
* Whenever a method does not require state, make it static to not have to capture self to use it.

    ##### Video: [The Minimum You Should Do To Prevent Memory Leaks in Swift][1]
    In tests make sure that references to objects are nil by the time the retainer ends using the referenced object. The normal solution is to always use [weak retainedObject].

    ##### Video: [XCTest + Swift: SetUp/TearDown vs Factory Methods][2]
	TIL: An instance of the Test class is created per test, so global variables within tests will not keep up changes between one test and the next one. There is also not order of execution. Given these points it is mostly better to have factory methods vs using the setUp/tearDown. Readability is also affected because one has to scroll up and down to see what initial config is done.

#### 6. Conforming to Feature Abstractions While Maintaining System Modularity + Keeping Test Details Out of Production With Enum Pattern Matching and Async Expectations ✅

* Protecting the production code from test details -> Do not make types conform to protocols for testability.
* Maintain modularity by protecting high-level abstractions from low-level implementation details
* DRY (Don’t Repeat Yourself) is sometimes better than early abstracting code to common modules because one creates modular dependencies without really finding out the needs of the system.
* Assert asynchronous behavior with XCTestCase expectations. exp + exp.fulfill + wait(for: [exp])


#### 7. Four Approaches to Test(-Drive) Network Requests: End-to-End, Subclass & Protocol-Based Mocking, and URLProtocol Stubbing ✅

* Learn various testing strategies for network requests and their trade-offs:

	* **End-to-end-testing:** It is an integration test between client and server. Real requests are done. This can make our development slow because the API might not be ready. It can also happen that there is just not network or that it is slow.

	* **Mocking with Subclasses:** It can be dangerous when subclassing classes we do not own, such as URLSession. There are methods that could do things we do not expect. It is also very coupled with the production code because we have to follow the step by step process that happens in production to fulfil our expectations. As an example URLSession’s initialiser was deprecated. Refactoring code in production immediately  breaks tests.

	* **Mocking with Protocols:** We can define protocols that have the interfaces we’d like to spy on. With this we can hide unnecessary details and avoid overwriting methods, we only care about specific behaviours. This, however, does not solve the tight coupling problem. Creating these protocols is also noisy in the production code because the sole purpose of the protocols may be testing.

	* **URLProtocol stubbing:** This is done using the “little-known URL Loading System”. It is fast and reliable, recommended by Apple to test network requests, so hopefully not unexpected mocking behaviour. It is good to decouple code from the production one as well as production details. We can also use this for other purposes such as analytics, caching or profiling (how long are things taking?). It awesome cuz one can just register stubs that would spy on requests, but the delegation to the stub is handled by the system. URLProtocol is an abstract class, when subclassed, one needs to implement 4 methods and one has access to all of the instance variables of the URLSession. See [commit][3] for an example.
What we did with URLProtocol is intercepting and handling URL requests.
Subclass and protocol-based mocking of classes we don’t own (e.g., the Foundation URLSession class)


##### Video: [Clean iOS Architecture pt.2: Good Architecture Traits][4]
* Good architecture makes a system soft -> easy to change and adapt to the ever changing requirements.
* A soft system is:

	* **flexible:** it welcomes requirement changes.
	* **maintainable:** Improves the estimation accuracy of the team. With new requirements it is more clear to know what is needed to do the changes. They are
	* **scalable:** They are easy to test.

##### Video: [Clean iOS Architecture pt.5: MVC, MVVM, and MVP (UI Design Patterns)][5]

None of them are architectures!

* **MVC:** It was very UI based and does not approach where networking or interacting with databases would live. Controller and view should not have a contact with each other, for example, the model would notify the view or use callbacks for it.
The model, however, is very independent and can live in a different module and be tested alone.

* **Apple MVC:** The original MVC was a broad design pattern that was not ready for new technology. In the Apple MVC the events from the View. It is very messy for big applications.

* **MVVM:** We do not have a controller, it is replaced by a view model. But again, networking, routing and parsing are a dev option. It should not be used to deal with the business logic, they should only be for the view. Bigger responsibilities should be kept away from this pattern.

* **MVP:** This is inverted to what MVC does. The presenter has a reference to the View, but through a protocol.

#### 8. Speeding up Development by: Reducing Debugging Time, Minimizing Risk & Maximizing Learning, and Decoupling Tests From Implementation Details ✅

* Avoiding the downsides of mocking/stubbing
* The economics of test feedback
	* Looking for bugs takes longer -> **if one has to debug to find where the test is failing, the value of the test is diminished.**. Each thing should be tested in different places, for example, avoid testing request and urls in the same test, separate those concerns.
	* Use factory methods in tests to protect the tests from implementation details. It is a good call to also add memory leak tracking to those methods.
	* It is important to add `file: StaticString = #file, line: UInt = #line` to helper methods.
	* Minimizing risk in the codebase and maximizing learning by testing all scenarios (including error, invalid and unhappy paths)
	* Refactoring techniques for abstracting tests from implementation details
	* When using 3rd-party frameworks, it's advised to add extra tests to validate assumptions. One example was the test checking that empty Data triggered an error. Wrong -> `URLSession` just returns `.sucess()` with `Data` having 0 bytes.
	* Keep these cases in mind when testing dataTask outcomes:

	![Possible data task outcomes to test][6]

	So far we have the last case: `nil, `nil`, `value.
	We implement a test for all the cases and land on finally testing sucessful situations.
	Important here is to take into account that comparing classes compares the pointers, not the values. In the case of the URL Loading System, when we pass a response through the `URLProtocol`, the system copies it into another instance, so the pointers are different.
	The URL Loading System also replaces `nil` data into `Data` with 0 bytes.


#### 9. Randomizing & Parallelizing Tests, Code Coverage, Testing in Integration with the Backend, and Automating a Continious Integration (CI) Pipeline

	* Extra testing configurations (running tests in random order, parallelizing test execution and gathering code coverage)
		* The randomization is great to avoid any kind of order dependency in our tests.
		* If tests run slowly, try running them in paralell. For this small use case it is not necessary.
	* Testing client and server integration (end-to-end) even when the backend is still in development
	* Economics of the end-to-end tests vs unit tests
		* End-to-end tests can be expensive to maintain and we want to not keep them low by relying on more, faster, precise unit tests. That is if we trust our backend. If we do not, we do need more end-to-end tests before releasing buggy builds.

	* Setting up a CI pipeline
		* For a team it is painfully necessary to have a pipeline, but even as solo developers it is benefitial to have one to speed up development process and ensure quality and integrity of the codebase...and to allow to easily integrate new devs in the future.




[1]: https://www.essentialdeveloper.com/articles/the-minimum-you-should-do-to-prevent-memory-leaks-in-swift
[2]: https://www.essentialdeveloper.com/articles/xctest-swift-setup-teardown-vs-factory-methods
[3]: https://github.com/lfcj/EssentialFeed/commit/9aec96725975871f560aec63c7a712e13f2c0b14
[4]: https://www.youtube.com/watch?v=C2GyNTN4j4o
[5]: https://www.youtube.com/watch?v=qzTeyxIW_ow&list=PLyjgjmI1UzlSWtjAMPOt03L7InkCRlGzb&index=5
[6]: /summary-images/data-task-possible-results.jpg
