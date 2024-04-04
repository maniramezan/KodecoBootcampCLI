// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

enum CLIError: Error {
    case emptyBranchName
    case failed(exitCode: Int32, args: [String]?)
}

@main
struct KodecoBootcampCLI: ParsableCommand {

    @Argument(help: "Branch name for homework, like 'week09'")
    var branchName: String

    @Option(name: .shortAndLong, help: "Path to copy the sample app from")
    var sampleAppPath: String? = nil

    @Option(name: .shortAndLong, help: "Repo root directory, this is your github repository path")
    var repoRootPath: String? = nil

    var currentDirectoryPath: String {
        repoRootPath ?? FileManager.default.currentDirectoryPath
    }

    enum CodingKeys: String, CodingKey {
        case branchName
        case sampleAppPath
        case repoRootPath
    }

    mutating func run() throws {
        // Validate branch name is valid
        guard !branchName.isEmpty else {
            throw CLIError.emptyBranchName
        }

        // Checkout
        try runGitCommand(["checkout", "-b", branchName])

        // Copy the sample project if available
        if let sampleAppPath {
            try copySampleProject(sampleAppURL: URL(filePath: sampleAppPath))
        } else {
            try createWeekDirectory()
        }

        // Add unstage changes
        try runGitCommand(["add", "."])

        // Commit
        try runGitCommand(["commit", "-m", "Add \(branchName) homework"])

        // push
        try runGitCommand(["push", "-u", "origin", branchName])

    }

    private func runGitCommand(_ args: [String]?) throws {
        // Create
        let pipe = Pipe()
        let gitProcess = Process()
        gitProcess.executableURL = URL(filePath: "/usr/bin/git")
        gitProcess.standardOutput = pipe

        gitProcess.arguments = args
        gitProcess.currentDirectoryPath = currentDirectoryPath
        gitProcess.waitUntilExit()

        try gitProcess.run()

        gitProcess.waitUntilExit()
        guard gitProcess.terminationStatus == 0 else {
            throw CLIError.failed(exitCode: gitProcess.terminationStatus, args: gitProcess.arguments)
        }

        let outputFile = pipe.fileHandleForReading
        let output = String(data: outputFile.readDataToEndOfFile(), encoding: .utf8)
        print(output ?? 0)
    }

    private func copySampleProject(sampleAppURL: URL) throws {
        var destination = URL(filePath: currentDirectoryPath)
        destination.append(path: branchName)
        try FileManager.default.copyItem(at: sampleAppURL, to: destination)
    }

    private func createWeekDirectory() throws {
        var destination = URL(filePath: currentDirectoryPath)
        destination.append(path: branchName)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: false)
    }
}
