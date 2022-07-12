package main

import (
    "fmt"
    "os"
    "flag"
    _ "log"
    "github.com/satori/go.uuid"
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

func genUuid() uuid.UUID {
    var uuid = uuid.NewV4()

    fmt.Printf("Generated a new commit with id: %s \n", uuid)

    return uuid
}

// Iterate through a given path
func scan(path string) {
    print("scan")
}

// Generate GIT contributions graph
func stats(email string) {
    print("stats")
}

func main() {
    // Command line arguments
    parseArgs := os.Args[1:]

    if len(parseArgs) <= 0 {
        helper()
    } else {
        for i := 0; i < len(parseArgs); i++ {
            switch parseArgs[i] {
            case "add":
                fmt.Println("Added 5 files.")
                break
            case "commit":
                genUuid()
                break
            default:
                helper()
            }
        }
    }

    // Test for contribution stats
    var folder string
    var email string
    flag.StringVar(&folder, "add", "", "add a new folder to scan GIT repositories.")
    flag.StringVar(&email, "email", "email@provider.com", "the email address to scan")
    flag.Parse()

    if folder != "" {
        scan(folder)
        return
    }
}
