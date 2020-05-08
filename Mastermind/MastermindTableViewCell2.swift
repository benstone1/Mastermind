//
//  MasterMindTableViewCell.swift
//  Mastermind
//
//  Created by Benjamin Stone on 5/7/20.
//  Copyright © 2020 Benjamin Stone. All rights reserved.
//

import UIKit

class MastermindTableViewCell2: UITableViewCell {

    @IBOutlet weak var imperfectPinsLabel: UILabel!
    @IBOutlet weak var perfectPinsLabel: UILabel!
    @IBOutlet weak var mastermindCellsCollectionView: UICollectionView!

    func setViewModel(to newViewModel: MastermindRowViewModel) {
        self.viewModel = newViewModel
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func configureCollectionView() {
        let nib = UINib(nibName: "MastermindCollectionViewCell", bundle: nil)
        mastermindCellsCollectionView.register(nib, forCellWithReuseIdentifier: "mastermindCell")
        mastermindCellsCollectionView.delegate = self
        mastermindCellsCollectionView.dataSource = self
    }
    
    private var viewModel: MastermindRowViewModel?
}

extension MastermindTableViewCell2: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel {
        case let .userInputMode(marbleCount):
            return marbleCount
        case let .historical(historicalVM):
            return historicalVM.guesses.count
        case .none:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mastermindCell", for: indexPath) as? MastermindCollectionViewCell else {
            fatalError("Unexpected cell type")
        }
        if let viewModel = viewModel {
            switch viewModel {
            case let .historical(historicalVM):
                cell.currentOption = historicalVM.guesses[indexPath.row]
            case .userInputMode:
                // TODO: Change models to allow access to last input
                cell.currentOption = .white
            }
        }
        return cell
    }
}
