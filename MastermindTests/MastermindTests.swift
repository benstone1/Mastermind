import XCTest
@testable import Mastermind

class MastermindTests: XCTestCase {
    func testGameBrain() throws {
        var brain = GameBrain(withSequence: [.red, .orange, .blue, .green, .black])
        let guess: Guess = [.orange, .yellow, .blue, .purple, .white]
        XCTAssert(brain.makeGuess(sequence: guess) == GameBrain.GuessResult.inProgress(GameBrain.GuessFeedback(correctColorAndPlaceCount: 1, correctColorIncorrectPlaceCount: 1)))
        //TODO: Add more tests
    }
    
}
