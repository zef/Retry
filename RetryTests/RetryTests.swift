//
//  RetryTests.swift
//  RetryTests
//
//  Created by Zef Houssney on 1/27/16.
//

import XCTest
@testable import Retry

enum BadError: Int, ErrorType {
    case Fail = 1
    case FailAgain = 2
    case FailThrice = 3
}

class RetryTests: XCTestCase {

    var currentAttemptCount = 1
    var expectedFailures = 1
    var eventLog = [String]()

    func failingFunction(success: (message: String) -> Void, failure: (error: ErrorType?, message: String) -> Void) {
        print("itsGonnaFail call", currentAttemptCount)
        currentAttemptCount += 1
        if currentAttemptCount > expectedFailures + 1 {
            success(message: "success")
        } else {
            let error = BadError(rawValue: currentAttemptCount - 1)
            failure(error: error, message: "failure")
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
            self.failingFunction({ message in
                self.eventLog.append("success on attempt \(attempt.currentAttempt)")
                attempt.success()
            }, failure: { error, message in
                attempt.failure([:]) {
                    print("failed attempt \(attempt.currentAttempt)")
                    XCTAssert(false, "Final failure should not occur")
                }
            })
        }

        XCTAssertEqual(self.eventLog, ["success on attempt 2"])
    }

    func testDoubleFailure() {
        expectedFailures = 2
        Retry.attempt("Double Failure Event") { attempt in
            self.failingFunction({ message in
                XCTAssert(false, "Success should not occur")
                attempt.success()
            }, failure: { error, message in
                attempt.failure([:]) {
                    self.eventLog.append("failure on attempt \(attempt.currentAttempt)")
                }
            })
        }

        XCTAssertEqual(self.eventLog, ["failure on attempt 2"])
    }

}