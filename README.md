#  Retry

A simple API for performing code that can be tried multiple times before giving
up.

## Motivation

I first conceived and built this library while working on an app in which we
would commonly encounter errors that were recoverable by re-running certain bits
of code.

This library can be used to help provide a more reliable user-experience, even
when the services that an app relies upon can have intermittent failures.

### Features

When trying to diagnose the source of problems and failures in an app, it's
important to understand which failure points exist, and which of those can be
recovered through retrying. Therefore, this library provides a mechanism by
which we can discover when retrying is worthwhile and when it's not.

This can be done through the implementing the following callbacks:

```Swift
onSuccess
// Use this to gauge whether retrying is ever effective
onSuccessAfterRetry
onRetryAttempt
onFinalFailure
```

These can be implemented in a global location and will apply to all of the uses
of `Retry` calls in your app. This keeps the callsites clean and introduces as
little complexity as possible.


### Ideas:

#### Add a short delay.
In some cases, you may want to insert a short delay before retrying. Depending
on the source of the failure, a short delay may help the chances of a retry
succeeding. I thought about including this functionality directly in the library,
but have not found the need to yet myself. You could easily do this in your own
function calls, and maybe even scale the delay time by `attempt.currentAttempt`
to increase the delay of each subsequent retry before finally giving up.



