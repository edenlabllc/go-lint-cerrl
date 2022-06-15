package cerrl

import (
	// the linter should work correctly even if import has alias
	cerr "cerrl/pkg/cerror"
)

func useAlias() {
	cerr.New().Log()
	cerr.New() // want "missing a .Log... call in chain after cerror.New..."
}
