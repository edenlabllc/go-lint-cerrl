// Test package with cerror-like interface
package cerror

type CError struct{}

func New() *CError {
	return new(CError)
}
