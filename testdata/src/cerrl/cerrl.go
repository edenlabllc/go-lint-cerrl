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

	_ = cerror.New()            // want "cerror.New... statement is not followed by a .Log call"
	cerror.New()                // want "cerror.New... statement is not followed by a .Log call"
	cerror.NewValidationError() // want "cerror.New... statement is not followed by a .Log call"
	cerror.NewF().WithPayload() // want "cerror.New... statement is not followed by a .Log call"

	return cerror.New() // want "cerror.New... statement is not followed by a .Log call"
}
