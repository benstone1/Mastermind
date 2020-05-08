//
//  ViewController.swift
//  Mastermind
//
//  Created by Benjamin Stone on 5/7/20.
//  Copyright © 2020 Benjamin Stone. All rights reserved.
//

import UIKit

class MastermindViewController: UIViewController {

    @IBOutlet weak var mastermindTableView: UITableView!
    
    lazy var currentUserGuess: Guess = {
        self.brain.mostRecentGuess
    }()
    
    var brain = GameBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    func configureTableView() {
        mastermindTableView.register(MastermindTableViewCell.self, forCellReuseIdentifier: "mastermindCell")
        mastermindTableView.delegate = self
        mastermindTableView.dataSource = self
    }
    
    @IBAction func makeNewGuess(_ sender: UIButton) {
        switch brain.makeGuess(sequence: currentUserGuess) {
        case let .inProgress(feedback):
            print(feedback)
            mastermindTableView.reloadData()
        case .victory:
            print("you win!")
        case .noGuessesRemaining:
            print("no guesses remaining to make this guess")
        case .invalidSequence:
            print("an error occurred with the sequence")
        }
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
