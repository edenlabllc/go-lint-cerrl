package cerrl

// the linter should ignore packages that don't meet the /pkg/cerror pattern
import "cerrl/cerror"

func useAnotherCerror() {
	cerror.New()
}
