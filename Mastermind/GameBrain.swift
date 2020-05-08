import Foundation

typealias Guess = [GameBrain.GuessOption]

struct GameBrain {
            
    // MARK: -- Initializers
    
    init(withSequence sequence: [GuessOption]) {
        self.correctSequence = sequence
        print(correctSequence)
    }
    
    init(withSequenceLength sequenceLength: Int = 4) {
        var randomSequence = [GuessOption]()
        for _ in 0..<sequenceLength {
            randomSequence.append(GuessOption.allCases.randomElement()!)
        }
        self.correctSequence = randomSequence
        print(correctSequence)
    }
    
    // MARK: -- Internal Methods
    
    mutating func makeGuess(sequence: [GuessOption]) -> GuessResult {
        guard sequence.count == correctSequence.count else {
            return .invalidSequence
        }
        guard guessCount < guessLimit else {
            return .noGuessesRemaining
        }
        guessCount += 1
        var imperfectGuesses = [GuessOption]()
        var remainingCorrectSequenceGuessOptions = [GuessOption]()
        var correctColorAndPlaceCount = 0
        for guessIndex in 0..<sequence.count {
            if sequence[guessIndex] == correctSequence[guessIndex] {
                correctColorAndPlaceCount += 1
            } else {
                imperfectGuesses.append(sequence[guessIndex])
                remainingCorrectSequenceGuessOptions.append(correctSequence[guessIndex])
            }
        }
        var correctColorIncorrectPlaceCount = 0
        let remainingCorrectSequenceGuessOptionFrequencyDict = frequencyDictionary(from: remainingCorrectSequenceGuessOptions)
        for (guess, count) in frequencyDictionary(from: imperfectGuesses) {
            correctColorIncorrectPlaceCount += min(count, remainingCorrectSequenceGuessOptionFrequencyDict[guess] ?? 0)
        }
        if correctColorAndPlaceCount == correctSequence.count { return .victory }
        let feedback = GuessFeedback(correctColorAndPlaceCount: correctColorAndPlaceCount,
                                     correctColorIncorrectPlaceCount: correctColorIncorrectPlaceCount)
        userGuesses.append((sequence, feedback))
        return .inProgress(feedback)
    }
    
    // MARK: -- Internal Properties
    
    var sequenceLength: Int {
        return correctSequence.count
    }
    
    var mostRecentGuess: [GuessOption] {
        return userGuesses.last?.0 ?? [GuessOption](repeating: .white, count: sequenceLength)
    }
    
    // MARK: -- Internal Enums and Structs
    
    enum GuessResult: Equatable {
        case inProgress(GuessFeedback)
        case noGuessesRemaining
        case invalidSequence
        case victory
    }
    
    struct GuessFeedback: Equatable {
        let correctColorAndPlaceCount: Int
        let correctColorIncorrectPlaceCount: Int
    }
    
    enum GuessOption: String, CaseIterable {
        case red, orange, blue, green, black, white, yellow, purple
        func nextOption() -> GuessOption {
            let sortedOptions = GuessOption.allCases.sorted { $0.rawValue < $1.rawValue }
            let currentIndex = sortedOptions.firstIndex(of: self)!
            return sortedOptions[(currentIndex + 1) % sortedOptions.count]
        }
    }
    
    // MARK: -- Private Methods
    
    private func frequencyDictionary(from arr: [GuessOption]) -> [GuessOption: Int] {
        var dict = [GuessOption: Int]()
        for guess in arr {
            dict[guess] = dict[guess, default: 0] + 1
        }
        return dict
    }

    // MARK: -- Private Properties
    
    private let correctSequence: [GuessOption]
    private(set) var userGuesses = [([GuessOption], GuessFeedback)]()
    private var guessCount = 0
    private var guessLimit = 6
}
