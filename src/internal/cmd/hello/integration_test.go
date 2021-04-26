//go:build integration

package cmd

import (
	"testing"
)

// TestHelloIntegration : intended to fail
func TestHelloIntegration(t *testing.T) {
	expected := "Hello Go!"
	actual := helloGo()
	if actual != expected {
		t.Errorf("Test failed, expected: '%s', got:  '%s'", expected, actual)
	}
}

func TestGoodDayIntegration(t *testing.T) {
	expected := "Good day!"
	actual := GoodDay()
	if actual != expected {
		t.Errorf("Test failed, expected: '%s', got:  '%s'", expected, actual)
	}
}
