// Serves as an entry point for the cerrl linter.
// May be used as a standalone CLI or integrated into go vet via -vettool argument.
package main

import (
	"flag"

	"github.com/edenlabllc/go-lint-cerrl/pkg/cerrl"
	"github.com/edenlabllc/go-lint-cerrl/testdata/src/cerrl/pkg/cerror"
	"golang.org/x/tools/go/analysis/singlechecker"
)

func main() {
	cerror.New()
	// Don't use it. Just not to crash on -unsafeptr flag from go vet
	flag.Bool("unsafeptr", false, "")

	singlechecker.Main(cerrl.Analyzer())
}
