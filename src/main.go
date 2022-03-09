package main

import (
    "fmt"
    "os"
    _ "log"
)

// Terminal output colors
var colorReset = "\033[0m"
var greenTermColor = "\033[32m"
var redTermColor = "\033[31m"

// Helper function for wrong argument / missing argument
func helper() {
    fmt.Println(string(greenTermColor), "Welcome to CleanCodersGIT!", string(colorReset))
    fmt.Printf("Usage: ccg [options] [--] [file...] \n Arguments: \n -h, --help \n Display this usage message and exit. \n -h <command>, --help <command> \n Shows useful information about the given command. \n")

    return
}

func main() {
    // Command line arguments
    var arguments = os.Args

    if len(arguments) < 2 {
        helper()
    }

    parseArgs := os.Args[1:]

    fmt.Println(parseArgs)
}
