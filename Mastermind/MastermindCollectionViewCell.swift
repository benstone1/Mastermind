//
//  MasterMindCollectionViewCell.swift
//  Mastermind
//
//  Created by Benjamin Stone on 5/7/20.
//  Copyright © 2020 Benjamin Stone. All rights reserved.
//

import UIKit

class MastermindCollectionViewCell: UICollectionViewCell {
    
    lazy var marbleImageView: UIImageView = {
       return UIImageView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(marbleImageView)
    }
    
    private func configureConstraints() {
        marbleImageView.translatesAutoresizingMaskIntoConstraints = false
        marbleImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        marbleImageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        marbleImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        marbleImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
        
    var currentOption: GameBrain.GuessOption = .white {
        didSet {
            marbleImageView.image = UIImage(named: currentOption.rawValue + "Marble.png")
        }
    }
}
