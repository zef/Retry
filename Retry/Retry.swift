//
//  Retry.swift
//  Retry
//
//  Created by Zef Houssney on 1/27/16.
//


import Foundation

class Retry {
    typealias ErrorParams = [String: Any]
    typealias Callback = (_ description: String, _ attempt: Int) -> Void
    typealias ErrorCallback = (_ description: String, _ attempt: Int, _ errorParams: ErrorParams?) -> Void

    struct Config {
        var onSuccess: Callback?
        var onSuccessAfterRetry: Callback?
        var onRetryAttempt: ErrorCallback?
        var onFinalFailure: ErrorCallback?
    }

    static var defaultConfig = Config()

    let config: Config
    let description: String
    var attemptsAllowed: Int = 1
    fileprivate var attemptBlock: (Retry) -> Void

    fileprivate(set) var currentAttempt: Int = 1

    init(_ description: String, retries: Int = 1, config: Config = Retry.defaultConfig, block: @escaping (Retry) -> Void) {
        self.description = description
        self.attemptsAllowed = retries + 1
        self.attemptBlock = block
        self.config = config
    }

    static func attempt(_ description: String, retries: Int = 1, config: Config = Retry.defaultConfig, block: @escaping (Retry) -> Void) {
        let attempt = Retry(description, retries: retries, config: config, block: block)
        attempt.attemptBlock(attempt)
    }

    func success() {
        config.onSuccess?(description, currentAttempt)
        if currentAttempt > 1 {
            config.onSuccessAfterRetry?(description, currentAttempt)
        }
    }

    func failure(_ errorParams: ErrorParams? = nil, block failureBlock: () -> Void ) {
        if currentAttempt < attemptsAllowed {
            config.onRetryAttempt?(description, currentAttempt, errorParams)
            currentAttempt += 1
            attemptBlock(self)
        } else {
            config.onFinalFailure?(description, currentAttempt, errorParams)
            failureBlock()
        }
    }
}
