package cerrl

import (
	// the linter should work correctly even if import has alias
	cerr "cerrl/pkg/cerror"
)

func useAlias() {
	cerr.New().Log()
	cerr.New() // want "cerror.New... statement is not followed by a .Log call"
}
