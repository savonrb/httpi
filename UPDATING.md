# Update guide

## From 2.x to 3.x

BREAKING CHANGE: the [#255](https://github.com/savonrb/httpi/pull/225) made the gem socksify and rack gems optional dependencies.

In order to restore the old behavior, see the README section "SOCKS Proxy Support" and "Rack Mock Adapter".

## From 3.x to 4.x

POTENTIAL BREAKING CHANGE: `HTTPI::Request#headers` and `HTTPI::Response#headers` now return `HTTPI::Utils::Headers` instead of `Rack::Utils::HeaderHash`. This change will prevent HTTPI from breaking or changing its public API whenever rack rearranges its classes. If you were relying on the `Rack::Utils::HeaderHash` implementation, you will need to update your code to use `HTTPI::Utils::Headers` instead.
