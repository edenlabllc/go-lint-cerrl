// The mock package with cerror-like functions
package cerror

type CError struct{}

func New() *CError {
	return new(CError)
}
