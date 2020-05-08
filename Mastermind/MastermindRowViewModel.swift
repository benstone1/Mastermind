import Foundation

enum MastermindRowViewModel {
    case historical(HistoricalMastermindRowViewModel)
    case userInputMode(UserInputModeMastermindRowViewModel)
}

struct UserInputModeMastermindRowViewModel {
    let marbleCount: Int
    let currentGuess: Guess
}

struct HistoricalMastermindRowViewModel {
    let perfectGuessCount: Int
    let imperfectGuessCount: Int
    var guess: Guess
}
