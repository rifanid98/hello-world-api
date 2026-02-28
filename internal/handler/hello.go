package handler

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

// HelloHandler handles GET /hello and returns hello world message.
func HelloHandler(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]string{
		"message": "hello world",
	})
}
