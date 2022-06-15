// Test package with cerror-like interface
package cerror

type CError struct{}

func New() *CError {
	return new(CError)
}

func NewF() *CError {
	return new(CError)
}

func NewValidationError() *CError {
	return new(CError)
}

func (c *CError) WithPayload() *CError {
	return c
}

func (c *CError) Log() *CError {
	return c
}

func (c *CError) LogError() *CError {
	return c
}
