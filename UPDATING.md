# Update guide

## From 2.x to 3.x

BREAKING CHANGE: the [#255](https://github.com/savonrb/httpi/pull/225) made the gem socksify and rack gems optional dependencies.

In order to restore the old behavior, see the README section "SOCKS Proxy Support" and "Rack Mock Adapter".

## From 3.x to 4.x

BREAKING CHANGE: `HTTPI::Request#headers` and `HTTPI::Response#headers` now return `Rack::Headers` instead of `Rack::Utils::HeaderHash`. You may need to adjust any code that explicitly depends on the type of the return value of these methods.

This change was made to address a deprecation warning for a pending API change in the upcoming [rack](https://github.com/rack/rack) 3.1.
