// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

enum Token {
    case name(String)
    case quality(Double)
}

typealias Entry = (name: String, quality: Double)

@main
struct SwiftRandomPicker: ParsableCommand {
    @Argument(parsing: .allUnrecognized, help: "List of names.\nPrefix a name with -q and a nonnegative number to set its weight (default is 1).")
    var items: [String]

    mutating func run() throws {
        let tokens = try parseTokens()
        let entries = try parseEntries(tokens: tokens)
        let name = try pickRandomEntry(entries: entries)
        print(name)
    }

    private func parseTokens() throws -> [Token] {
        var tokens: [Token] = []
        var isQualityExpected = false

        for item in items {
            if isQualityExpected {
                let q = try parseQuality(item)
                tokens.append(.quality(q))
                isQualityExpected = false
                continue
            }

            if item.hasPrefix("-") {
                guard item.hasPrefix("-q") else {
                    throw ValidationError("Unexpected option: \(item)")
                }

                // If independent "-q" is found, look for a following number
                if item.count == 2 {
                    isQualityExpected = true
                    continue
                }

                // Use appended number, e.g. "-q2.5"
                let qualityPart = item.dropFirst(2)
                let q = try parseQuality(qualityPart)
                tokens.append(.quality(q))
            } else {
                tokens.append(.name(item))
            }
        }

        if isQualityExpected {
            throw ValidationError("Expected a number after -q")
        }

        return tokens
    }

    private func parseQuality(_ string: some StringProtocol) throws -> Double {
        guard let q = Double(string) else {
            throw ValidationError("Expected a number after -q, got \"\(string)\"")
        }

        guard q.isFinite, q >= 0 else {
            throw ValidationError("Quality must be a valid nonnegative number, got \"\(string)\"")
        }

        return q
    }

    private func parseEntries(tokens: [Token]) throws -> [Entry] {
        var items: [Entry] = []
        var currentQuality: Double?

        for token in tokens {
            switch token {
            case let .name(name):
                if let quality = currentQuality {
                    items.append((name, quality))
                    currentQuality = nil
                } else {
                    items.append((name, 1))
                }
            case let .quality(q):
                if let currentQuality {
                    throw ValidationError("Quality is already specified (\(currentQuality)), cannot override with \(q)")
                }
                currentQuality = q
            }
        }

        if let currentQuality {
            throw ValidationError("No name after quality (\(currentQuality))")
        }

        return items
    }

    private func getTotalChance(entries: [Entry]) -> Double {
        entries.reduce(0) { $0 + $1.quality }
    }

    private func pickRandomEntry(entries: [Entry]) throws -> String {
        guard entries.count > 0 else {
            throw ValidationError("No entries to select!")
        }

        let total = getTotalChance(entries: entries)
        guard total > 0 else {
            throw ValidationError("Sum of all qualities must be greater than 0")
        }

        let value = Double.random(in: 0.0 ..< total)

        var cumulativeQuality = 0.0
        for (name, quality) in entries {
            cumulativeQuality += quality
            if value < cumulativeQuality {
                return name
            }
        }

        fatalError("Value \(value) did not match any entry, total was \(total)")
    }
}
