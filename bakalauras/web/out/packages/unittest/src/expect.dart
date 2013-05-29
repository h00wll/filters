// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of matcher;

/** The objects thrown by the default failure handler. */
class TestFailure {
  String _message;

  get message => _message;
  set message(String value) => _message = value;

  TestFailure(String message) : _message = message;

  String toString() => _message;
}

/**
 * Some matchers, like those for Futures and exception testing,
 * can fail in asynchronous sections, and throw exceptions.
 * A user of this library will typically want to catch and handle 
 * such exceptions. The [wrapAsync] property is a function that
 * can wrap callbacks used by these Matchers so that they can be
 * used safely. For example, the unittest library will set this
 * to be expectAsync1. By default this is an identity function.
 */
Function wrapAsync = (f, [id]) => f;

/**
 * This is the main assertion function. It asserts that [actual]
 * matches the [matcher]. [reason] is optional and is typically not
 * supplied, as a reason is generated from the matcher; if [reason]
 * is included it is appended to the reason generated by the matcher.
 *
 * [matcher] can be a value in which case it will be wrapped in an
 * [equals] matcher.
 *
 * If the assertion fails, then the default behavior is to throw a
 * [TestFailure], but this behavior can be changed by calling
 * [configureExpectFailureHandler] and providing an alternative handler that
 * implements the [IFailureHandler] interface. It is also possible to
 * pass a [failureHandler] to [expect] as a final parameter for fine-
 * grained control.
 *
 * In some cases extra diagnostic info can be produced on failure (for
 * example, stack traces on mismatched exceptions). To enable these,
 * [verbose] should be specified as true;
 */
void expect(actual, matcher, {String reason, FailureHandler failureHandler,
            bool verbose : false}) {
  matcher = wrapMatcher(matcher);
  bool doesMatch;
  var matchState = new MatchState();
  try {
    doesMatch = matcher.matches(actual, matchState);
  } catch (e, trace) {
    doesMatch = false;
    if (reason == null) {
      reason = '${(e is String) ? e : e.toString()} at $trace';
    }
  }
  if (!doesMatch) {
    if (failureHandler == null) {
      failureHandler = getOrCreateExpectFailureHandler();
    }
    failureHandler.failMatch(actual, matcher, reason, matchState, verbose);
  }
}

void fail(String message, {FailureHandler failureHandler}) {
  if (failureHandler == null) {
    failureHandler = getOrCreateExpectFailureHandler();
  }
  failureHandler.fail(message);
}

/**
 * Takes an argument and returns an equivalent matcher.
 * If the argument is already a matcher this does nothing,
 * else if the argument is a function, it generates a predicate
 * function matcher, else it generates an equals matcher.
 */
Matcher wrapMatcher(x) {
  if (x is Matcher) {
    return x;
  } else if (x is Function) {
    return predicate(x);
  } else {
    return equals(x);
  }
}

// The handler for failed asserts.
FailureHandler _assertFailureHandler = null;

// The default failure handler that throws [TestFailure]s.
class DefaultFailureHandler implements FailureHandler {
  DefaultFailureHandler() {
    if (_assertErrorFormatter == null) {
      _assertErrorFormatter = _defaultErrorFormatter;
    }
  }
  void fail(String reason) {
    throw new TestFailure(reason);
  }
  void failMatch(actual, Matcher matcher, String reason,
      MatchState matchState, bool verbose) {
    fail(_assertErrorFormatter(actual, matcher, reason, matchState, verbose));
  }
}

/**
 * Changes or resets to the default the failure handler for expect()
 * [handler] is a reference to the new handler; if this is omitted
 * or null then the failure handler is reset to the default, which
 * throws [TestFailure]s on [expect] assertion failures.
 */
void configureExpectFailureHandler([FailureHandler handler = null]) {
  if (handler == null) {
    handler = new DefaultFailureHandler();
  }
  _assertFailureHandler = handler;
}

FailureHandler getOrCreateExpectFailureHandler() {
  if (_assertFailureHandler == null) {
    configureExpectFailureHandler();
  }
  return _assertFailureHandler;
}

// The error message formatter for failed asserts.
ErrorFormatter _assertErrorFormatter = null;

// The default error formatter implementation.
String _defaultErrorFormatter(actual, Matcher matcher, String reason,
    MatchState matchState, bool verbose) {
  var description = new StringDescription();
  description.add('Expected: ').addDescriptionOf(matcher).
      add('\n     but: ');
  matcher.describeMismatch(actual, description, matchState, verbose);
  description.add('.\n');
  if (verbose) {
    if (actual is Iterable) {
      description.add('Actual: ').addDescriptionOf(actual).add('\n');
    } else if (actual is Map) {
      description.add('Actual: ');
      var count = 25;
      for (var k in actual.keys) {
        if (count == 0) {
          description.add('...\n');
          break;
        }
        description.addDescriptionOf(k);
        description.add(' : ');
        description.addDescriptionOf(actual[k]);
        description.add('\n');
        --count;
      }
    }
  }
  if (reason != null) {
    description.add(reason).add('\n');
  }
  return description.toString();
}

/**
 * Changes or resets to default the failure message formatter for expect().
 * [formatter] is a reference to the new formatter; if this is omitted or
 * null then the failure formatter is reset to the default. The new
 * formatter is returned; this allows custom expect handlers to easily
 * get a reference to the default formatter.
 */
ErrorFormatter configureExpectFormatter([ErrorFormatter formatter = null]) {
  if (formatter == null) {
    formatter = _defaultErrorFormatter;
  }
  return _assertErrorFormatter = formatter;
}

