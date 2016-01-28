//
//  Retry.swift
//  Retry
//
//  Created by Zef Houssney on 1/27/16.
//

import Foundation

class Retry {
    typealias ErrorParams = [String: Any]
    typealias Callback = (description: String, attempt: Int) -> Void
    typealias ErrorCallback = (description: String, attempt: Int, errorParams: ErrorParams) -> Void

    struct Config {
        var onSuccess: Callback?
        var onSuccessAfterRetry: Callback?
        var onRetryAttempt: ErrorCallback?
        var onFinalFailure: ErrorCallback?

        func attempt(description: String, retries: Int = 0, block: (Retry) -> Void) {
            Retry.attempt(description, retries: retries, config: self, block: block)
        }
    }

    static var defaultConfig = Config()

    let config: Config
    let description: String
    var attemptsAllowed: Int = 1
    private var attemptBlock: (Retry) -> Void

    private(set) var currentAttempt: Int = 1

    init(_ description: String, retries: Int = 1, config: Config = Retry.defaultConfig, block: (Retry) -> Void) {
        self.description = description
        self.attemptsAllowed = retries + 1
        self.attemptBlock = block
        self.config = config
    }

    static func attempt(description: String, retries: Int = 1, config: Config = Retry.defaultConfig, block: (Retry) -> Void) {
        let attempt = Retry(description, retries: retries, config: config, block: block)
        attempt.attemptBlock(attempt)
    }

    func success() {
        config.onSuccess?(description: description, attempt: currentAttempt)
        if currentAttempt > 1 {
            config.onSuccessAfterRetry?(description: description, attempt: currentAttempt)
        }
    }

    func failure(errorParams: ErrorParams, block failureBlock: () -> Void ) {
        if currentAttempt < attemptsAllowed {
            config.onRetryAttempt?(description: description, attempt: currentAttempt, errorParams: errorParams)
            currentAttempt++
            attemptBlock(self)
        } else {
            config.onFinalFailure?(description: description, attempt: currentAttempt, errorParams: errorParams)
            failureBlock()
        }
    }
}
