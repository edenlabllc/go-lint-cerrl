package cerrl

import (
	"cerrl/pkg/cerror"
)

func useCerror() *cerror.CError {
	_ = cerror.New().Log()
	cerror.New().Log()
	cerror.NewF().Log()
	cerror.NewValidationError().LogError()

	cerror.New().WithPayload().LogError()
	cerror.NewValidationError().WithPayload().Log()

	_ = cerror.New()            // want "missing a .Log... call in chain after cerror.New..."
	cerror.New()                // want "missing a .Log... call in chain after cerror.New..."
	cerror.NewValidationError() // want "missing a .Log... call in chain after cerror.New..."
	cerror.NewF().WithPayload() // want "missing a .Log... call in chain after cerror.New..."

	return cerror.New() // want "missing a .Log... call in chain after cerror.New..."
}
