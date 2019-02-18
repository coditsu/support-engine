# Coditsu Support Engine

[![CircleCI](https://circleci.com/gh/coditsu/support-engine/tree/master.svg?style=svg)](https://circleci.com/gh/coditsu/support-engine/tree/master)

Engine providing `git`, `yarn`, `shell` and other shared, helpful operation commands wrappers for the most common and more complex actions that are being used within the Coditsu ecosystem.

## Examples

Please use the `yard` docs to get the docs for the whole API. Meanwhile this is how you can use this lib:

```ruby
SupportEngine::Git::Blame.all('./', 'Gemfile') #=> ["68c066bdc... 2 2 1", "author Maciej", ...]
SupportEngine::Shell::Utf8.call('ls') #=> { stdout: 'bin\ncoverage\nGemfile...', stderr: '', exit_code: 0 }
SupportEngine::Git::Log.file_last_committer('./', 'Gemfile') #=> ["commit 80c0fc8...", ...]
```

## Note on contributions

First, thank you for considering contributing to Coditsu ecosystem! It's people like you that make the open source community such a great community!

Each pull request must pass all the RSpec specs and meet our quality requirements.

To check if everything is as it should be, we use [Coditsu](https://coditsu.io) that combines multiple linters and code analyzers for both code and documentation. Once you're done with your changes, submit a pull request.

Coditsu will automatically check your work against our quality standards. You can find your commit check results on the [builds page](https://app.coditsu.io/coditsu/commit_builds) of Coditsu organization.

[![coditsu](https://coditsu.io/assets/quality_bar.svg)](https://app.coditsu.io/coditsu/commit_builds)
