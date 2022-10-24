//
//  RetryTests.swift
//  RetryTests
//
//  Created by Zef Houssney on 1/27/16.
//

import XCTest
@testable import Retry

class RetryTests: XCTestCase {
    enum RetryTestError: Int, Error {
        case fail = 1
        case failAgain = 2
        case failThrice = 3
    }

    var currentAttemptCount = 1
    var expectedFailures = 1
    var eventLog = [String]()

    func failingFunction(_ completion: (Result<String, RetryTestError>) -> Void) {
        print("failingFunction call", currentAttemptCount)
        currentAttemptCount += 1
        if currentAttemptCount > expectedFailures + 1 {
            completion(.success("success"))
        } else {
            guard let error = RetryTestError(rawValue: currentAttemptCount - 1) else {
                fatalError("Could not instantiate test RetryTestError.")
            }
            completion(.failure(error))
        }
    }

    override func setUp() {
        super.setUp()
        currentAttemptCount = 1
        expectedFailures = 1
        eventLog = []
    }

    func testSimpleRetry() {
        Retry.attempt("Simple Event") { attempt in
            self.eventLog.append("It worked")
            XCTAssertEqual(attempt.currentAttempt, 1)
            attempt.success()
        }
    }

    func testSingleFailure() {
        expectedFailures = 1
        Retry.attempt("Simple Event") { attempt in
            self.failingFunction { result in
                switch result {
                case .success:
                    self.eventLog.append("success on attempt \(attempt.currentAttempt)")
                    attempt.success()
                case .failure:
                    attempt.failure() {
                        print("failed attempt \(attempt.currentAttempt)")
                        XCTAssert(false, "Final failure should not occur")
                    }
                }
            }
        }

        XCTAssertEqual(self.eventLog, ["success on attempt 2"])
    }

    func testDoubleFailure() {
        expectedFailures = 2
        Retry.attempt("Double Failure Event") { attempt in
            self.failingFunction { result in
                switch result {
                case .success:
                    XCTAssert(false, "Success should not occur")
                    attempt.success()
                case .failure:
                    attempt.failure() {
                        self.eventLog.append("failure on attempt \(attempt.currentAttempt)")
                    }
                }
            }
        }

        XCTAssertEqual(self.eventLog, ["failure on attempt 2"])
    }

}
