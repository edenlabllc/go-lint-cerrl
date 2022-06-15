# go-lint-cerrl

![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)

go-lint-cerrl is a golang linter that helps finding unlogged errors
created by the `cerror` package from your project.

## Description

There are number of cases when errors are created with a `cerror.New...` call
but not logged with a `Log...` method.

For example:

`err := cerror.NewF(...)` - bad, error is not logged
`err := cerror.NewF(...).LogError()` - good, error is logged

It's so easy to forget about the `Log...` and very hard to catch this during
a code review. Moreover this defect is totally invisible for the end user.
Highly likely we'll find out it only when catch a bug and try to find
some useful inforamtion in logs. These aspects make such kind of bugs quite
dangerous and should be a motivation to use the linter.

Note that the linter expects the `.Log()` in chain, so the following cases:

```
err := cerror.New()
_ = err.Log()
```

will be highlited as errors. Fill free to use `//nolint:cerrl` if you
use the linter as `golangci-lint` pluign.

The linter checks only files that contain cerror package import.
The import must have the `/pkg/cerror` suffix.
The linter also understands import aliases. For example:

```
import cerr "my_proj/pkg/cerror"
...
err := cerr.New(...).LogError()
...
```

# Installation

It's very important to remember that plugins programs that load them must
be built with the same configuration (go version, os, arch, ...).

All the `golangci-lint` builds and docker images have `CGO_ENABLED=0`
that breaks the go plugin system requirements `CGO_ENABLED=1`.
So most likely you'll have to install `golangci-lint` from source:

```
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.45.0
```

Before installation ensure that you have `CGO_ENABLED=1` locally:

```
go env | grep CGO_ENABLED
```

## Use as a golangci-lint plugin locally

Clone or download the repo:

```
git clone https://github.com/edenlabllc/go-lint-cerrl
```

Switch to the root directory and build the plugin:

```
#build into the current directory
make build-plugin

#or into a custom directory
go build --buildmode plugin --output {custom dir path} plugin/cerrl.go
```

Finally you'll get the `*.so` file that you can add to your `golangci-lint` config file.
See the `.golangci.yml` configuration example with the plugin in our [repo](config/.golangci.yml#L2).

##### Known issues

If you see an error during `golangci-lint run` that looks similar too:

```
... unable to load plugin: plugin.Open(...): plugin was built with a different version of ...
```

Solution - try to remove all the installed versions of `golangci-lint` and install it again:

```
#see the path to golangci-lint
which golangci-lint

#remove it
rm $(which golangci-lint)

#ensure that you don't have another copy
which golangci-lint
#should see golangci-lint not found. If no delete this copy too

#install
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.45.0
```

If some of your teammate haven't manage to install the plugin you can keep
two `golangci-lint` configs - with and without plugin and refer them inside
your IDE individually.
For example for `vscode` add the following lines to `settings.json`:

```
"go.lintFlags": [
    "-c",
    ".golangci-no-plugin.yml",
]
```

And use them from cli as we did in our [repo](Makefile#L16).


## Use as a golangci-lint plugin in docker

If you don't want to install the plugin locally and you don't need
online linter issues discovering, you can run  `golangci-lint` inside
the docker.

As it was mentioned [here](#installation) we can't use one of the `golangci-lint`
docker images. So we have to run the `golang` image and install `golangci-lint`
and build the plugin inside the container. You can see an example of
`docker-compose` file in our [repo](docker/docker-compose-lint.yaml)

## Use in github workflows

Unfortunately we can't use the original `golangci-lint` github [action](https://github.com/golangci/golangci-lint-action)
because of [CGO_ENABLED=0](#installation). We have to install the plugin and `golangci-lint`
by our own during the github action and then run the linter. See an example of such
action inside our [repo](.github/workflows/test.yaml#l51). You can use this approach for the entire linting
process or separate the linting into two jobs (as wee deed):
- lint using config without plugins and use the original `golangci-lint` github action
- lint using config with plugins only and use a custom action

## Use as a standalone

Rememeber that `nolint` directives won't work outside the `golangci-lint`.

Install using go:

```
go install github.com/edenlabllc/go-lint-cerrl/cmd/cerrl
```

then use like:

```
cerrl ./...
```

Also you can integrate the binary into `go vet`:

```
go vet -vettool=$(which cerrl) ./...
```

## Links

If you want to read more about how to build your own linter
and integrate it into `golangci-lint` see the following resources:

- build a [custom linter](https://disaev.me/p/writing-useful-go-analysis-linter/#integrate-with-go-vet) from scratch and integrate it into `go vet` and `golangci-lint`
- a simple example of `golangci-lint` [plugin](https://github.com/golangci/example-plugin-linter)
- how to [add a new linter](https://golangci-lint.run/contributing/new-linters/) into `golangci-lint`
- golang AST [visualizer](http://goast.yuroyoro.net/)