// +build !without_unit

package cmd

import (
	"testing"
)

func TestHello(t *testing.T) {
	expected := "Hello Go!"
	actual := helloGo()
	if actual != expected {
		t.Errorf("Test failed, expected: '%s', got:  '%s'", expected, actual)
	}
}

func TestGoodDay(t *testing.T) {
	expected := "Good day!"
	actual := GoodDay()
	if actual != expected {
		t.Errorf("Test failed, expected: '%s', got:  '%s'", expected, actual)
	}
}
