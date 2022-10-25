//
//  Retry.swift
//  Retry
//
//  Created by Zef Houssney on 1/27/16.
//

import Foundation

public class Retry {
    public typealias ErrorParams = [String: Any]

    public struct Callbacks {
        public typealias SuccessCallback = (_ description: String, _ attempt: Int) -> Void
        public typealias ErrorCallback = (_ description: String, _ attempt: Int, _ errorParams: ErrorParams?) -> Void

        public var onSuccess: SuccessCallback?
        public var onSuccessAfterRetry: SuccessCallback?
        public var onRetryAttempt: ErrorCallback?
        public var onFinalFailure: ErrorCallback?
    }

    public static var defaultCallbacks = Callbacks()

    let callbacks: Callbacks
    let description: String
    var attemptsAllowed: Int = 1
    var attemptBlock: (Retry) -> Void

    public private(set) var currentAttempt: Int = 1

    init(_ description: String, retries: Int = 1, callbacks: Callbacks = Retry.defaultCallbacks, block: @escaping (Retry) -> Void) {
        self.description = description
        self.attemptsAllowed = retries + 1
        self.attemptBlock = block
        self.callbacks = callbacks
    }

    public static func attempt(_ description: String, retries: Int = 1, callbacks: Callbacks = Retry.defaultCallbacks, block: @escaping (Retry) -> Void) {
        let attempt = Retry(description, retries: retries, callbacks: callbacks, block: block)
        attempt.attemptBlock(attempt)
    }

    public func success() {
        callbacks.onSuccess?(description, currentAttempt)
        if currentAttempt > 1 {
            callbacks.onSuccessAfterRetry?(description, currentAttempt)
        }
    }

    public func failure(_ errorParams: ErrorParams? = nil, block failureBlock: () -> Void ) {
        if currentAttempt < attemptsAllowed {
            callbacks.onRetryAttempt?(description, currentAttempt, errorParams)
            currentAttempt += 1
            attemptBlock(self)
        } else {
            callbacks.onFinalFailure?(description, currentAttempt, errorParams)
            failureBlock()
        }
    }
}
