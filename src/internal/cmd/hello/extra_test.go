//go:build extra

package cmd

import (
	"testing"
)

func TestHelloExtra(t *testing.T) {
	expected := "Hello Go!"
	actual := helloGo()
	if actual != expected {
		t.Errorf("Test failed, expected: '%s', got:  '%s'", expected, actual)
	}
}

func TestGoodDayExtra(t *testing.T) {
	expected := "Good day!"
	actual := GoodDay()
	if actual != expected {
		t.Errorf("Test failed, expected: '%s', got:  '%s'", expected, actual)
	}
}
