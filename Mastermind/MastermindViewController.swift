//
//  ViewController.swift
//  Mastermind
//
//  Created by Benjamin Stone on 5/7/20.
//  Copyright © 2020 Benjamin Stone. All rights reserved.
//

import UIKit

class MastermindViewController: UIViewController {

    enum State: Equatable {
        case guessing
        case gameEnd(GameBrain.GameOver)
    }
    
    @IBOutlet weak var mastermindTableView: UITableView!
    @IBOutlet var bottomButton: UIButton!
    @IBOutlet var remainingGuessesLabel: UILabel!
    
    lazy var currentUserGuess: Guess = {
        self.brain.mostRecentGuess
    }()
    
    var state = State.guessing {
        didSet {
            guard oldValue != state else { return }
            handleStateUpdate(to: state)
        }
    }
    
    var brain = GameBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        remainingGuessesLabel.text = "Guesses Remaining: \(brain.guessLimit)"
    }
    
    func configureTableView() {
        mastermindTableView.register(MastermindTableViewCell.self, forCellReuseIdentifier: "mastermindCell")
        mastermindTableView.delegate = self
        mastermindTableView.dataSource = self
    }
    
    @IBAction func bottomButtonPressed(_ sender: UIButton) {
        switch state {
        case .guessing:
            let guessFeedback = brain.makeGuess(sequence: currentUserGuess)
            mastermindTableView.reloadData()
            switch guessFeedback {
            case let .inProgress(feedback):
                remainingGuessesLabel.text = "Guesses Remaining: \(feedback.remainingGuesses)"
            case let .gameOver(gameOverCondition):
                state = .gameEnd(gameOverCondition)
            case let .error(error):
                print("An error occurred: \(error)")
            }
        case .gameEnd:
            state = .guessing
        }
    }
    
    private func handleStateUpdate(to newState: State) {
        switch state {
        case .guessing:
            resetGame()
        case let .gameEnd(status):
            bottomButton.setTitle("Reset Game", for: .normal)
            let title: String
            let message: String
            switch status {
            case .victory:
                title = "Victory!"
                message = "You have won!"
            case .defeat:
                title = "Defeat!"
                message = "The correct sequence was: \(brain.correctSequence.map{ $0.rawValue })"
                remainingGuessesLabel.text = "Remaining Guesses: \(0)"
            }
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    private func resetGame() {
        bottomButton.setTitle("Submit Guess", for: .normal)
        brain = GameBrain()
        mastermindTableView.reloadData()
        remainingGuessesLabel.text = "Remaining Guesses: \(brain.guessLimit)"
    }
}

extension MastermindViewController: MastermindRowDelegate {
    func didUpdateGuess(to newGuess: Guess) {
        currentUserGuess = newGuess
    }
}

extension MastermindViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brain.userGuesses.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mastermindCell") as? MastermindTableViewCell else { fatalError("Unexpected cell type")
        }
        let viewModel: MastermindRowViewModel
        if indexPath.row < brain.userGuesses.count {
            let (guess, feedback) = brain.userGuesses[indexPath.row]
            viewModel = .historical(HistoricalMastermindRowViewModel(perfectGuessCount: feedback.correctColorAndPlaceCount, imperfectGuessCount: feedback.correctColorIncorrectPlaceCount, guess: guess))
        } else {
            viewModel = .userInputMode(UserInputModeMastermindRowViewModel(marbleCount: brain.sequenceLength, currentGuess: brain.mostRecentGuess))
        }
        cell.setViewModel(to: viewModel)
        cell.setDelegate(to: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
