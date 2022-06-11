# go-lint-cerrl

go-lint-cerrl is the golang linter that helps to find
unlogged errors created by the `cerror` package from your project.

There are number of cases when errors are created with a `cerror.New...` call
but not logged with a `Log...` method.

For example:

`   err := cerror.NewF(...)` - bad, error is not logged
`   err := cerror.NewF(...).LogError()` - good, error is logged

It's so easy to forget about the `Log...` and very hard to catch during
a code review. Moreover this defect is totally invisible for the end user.
Highly likely we'll find out it only when catch another bug and try to find
some useful info in logs. These aspects make such kind of bugs quite
dangerous and should be a motivation to use the linter.

Note that the linter expect the `.Log()` in-chain, so the following cases:
```
    err := cerror.New()
    _ = err.Log()
```
will be highlited as errors. Fill free to use `//nolint:cerrl`.

The linter checks only files that contain cerror package import.
The import must have the `/pkg/cerror` suffix.
The linter also understands import aliases. For example:
```
    import cerr "my_proj/pkg/cerror"
    ...
    err := cerr.New(...).LogError()
    ...
```

There the following options to use the linter:
- as a standalone executable binary `go run cmd/cerrl/main.go ./...`
- integrated into govet
```
    go install ./cmd/...
    go vet -vettool=$(which cerrl) ./...
```
- as a golangci-lint plugin. Take the ready to use binary [here](/plugin/bin)
or build it by your own:
```
    go build --buildmode plugin -o plugin/bin/golangci-lint-cerrl.so plugin/cerrl.go
```
Then you can add the plugin to your golang-ci config file.
See the `.golangci.yml` configuration example with the plugin in our [repository](.golangci.yml#L2).

If you want to read more about how to build your own linter
and integrate it into `golangci-lint` see the following resources:

- build a [custom linter](https://disaev.me/p/writing-useful-go-analysis-linter/#integrate-with-go-vet) from scratch and integrate it into `go vet` and `golangci-lint`
- a simple example of `golangci-lint` [plugin](https://github.com/golangci/example-plugin-linter)
- how to [add a new linter](https://golangci-lint.run/contributing/new-linters/) into `golangci-lint`
- golang AST [visualizer](http://goast.yuroyoro.net/)