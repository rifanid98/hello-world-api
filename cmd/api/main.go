package main

import (
	"hello-world-api/internal/handler"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// Routes
	e.GET("/hello", handler.HelloHandler)

	// Start server on port 8080
	e.Logger.Fatal(e.Start(":8080"))
}
