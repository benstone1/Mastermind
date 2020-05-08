import Foundation

protocol MastermindRowDelegate: AnyObject {
    func didUpdateGuess(to newGuess: Guess)
}
