# Contribution Guide

This page describes how to contribute changes to HTTPI.

Please do not create a pull request without reading this guide first.

**Bug fixes**

HTTPI is a common interface over Ruby's many HTTP client libraries (net/http, httpclient,
curb, excon, http.rb, em-http, net-http-persistent). If you think you found a bug, the most
useful input you can give us is: the adapter you were using, a minimal request that triggers
it (url, verb, headers, body, auth, ssl, proxy - whatever is relevant), what HTTPI did, and
what you expected instead. You're a developer, we are developers, and you know we need a test
to reproduce a problem and make sure it does not come back.

So if you can reproduce your problem in a spec, that would be awesome! Please note which
adapter is affected, because behavior often differs between them.

After we have a failing spec, it needs to be fixed. Make sure your new spec is the only
failing one under the `spec` directory.

**Running tests**

```bash
bundle install
bundle exec rake            # unit specs
bundle exec rake ci         # unit + integration specs (integration spins up a local server)
```

Before opening a pull request, also run the checks CI runs so you don't get a red build:

```bash
bundle exec standardrb
```

Please follow this workflow for Pull Requests:

* [Fork the project](https://help.github.com/articles/fork-a-repo)
* Create a feature branch and make your bug fix
* Add tests for it!
* [Send a Pull Request](https://help.github.com/articles/using-pull-requests)
* [Check that your Pull Request passes the build](https://github.com/savonrb/httpi/actions/workflows/ci.yml)

**Improvements and feature requests**

HTTPI is in maintenance mode. It receives bug fixes, security updates, and ecosystem
compatibility changes. New features are unlikely to be accepted - for new work the savon
family recommends the faraday transport.

If you have an idea anyway, please feel free to
[create a new Issue](https://github.com/savonrb/httpi/issues/new/choose) and describe your idea
so that other people can give their insights and opinions. This is also important to avoid
duplicate work.

Pull Requests and Issues on GitHub are meant to be used to discuss problems and ideas, so please
make sure to participate and follow up on questions. In case no one comments on your ticket,
please keep updating the ticket with additional information.
