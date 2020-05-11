import UIKit

class MastermindTableViewCell: UITableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
//        perfectPinsLabel.text = ""
//        imperfectPinsLabel.text = ""
    }
    
    lazy var imperfectPinsLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var perfectPinsLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    lazy var mastermindCellsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MastermindCollectionViewCell.self, forCellWithReuseIdentifier: "mastermindCell")
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        configureConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(imperfectPinsLabel)
        contentView.addSubview(perfectPinsLabel)
        contentView.addSubview(mastermindCellsCollectionView)
    }
    
    private func configureConstraints() {
        constrainImperfectPinsLabel()
        constrainPerfectPinsLabel()
        constrainMastermindCellsCollectionView()
    }
    
    private func constrainImperfectPinsLabel() {
        imperfectPinsLabel.translatesAutoresizingMaskIntoConstraints = false
        imperfectPinsLabel.leadingAnchor.constraint(equalTo: mastermindCellsCollectionView.trailingAnchor, constant: 20).isActive = true
        imperfectPinsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20).isActive = true
        imperfectPinsLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20).isActive = true
        imperfectPinsLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func constrainPerfectPinsLabel() {
        perfectPinsLabel.translatesAutoresizingMaskIntoConstraints = false
        perfectPinsLabel.leadingAnchor.constraint(equalTo: imperfectPinsLabel.leadingAnchor, constant: 0).isActive = true
        perfectPinsLabel.trailingAnchor.constraint(equalTo: imperfectPinsLabel.trailingAnchor, constant: 0).isActive = true
        perfectPinsLabel.topAnchor.constraint(equalTo: imperfectPinsLabel.bottomAnchor, constant: 20).isActive = true
        perfectPinsLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func constrainMastermindCellsCollectionView() {
        mastermindCellsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        mastermindCellsCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mastermindCellsCollectionView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        mastermindCellsCollectionView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func setViewModel(to newViewModel: MastermindRowViewModel) {
        self.viewModel = newViewModel
    }
    
    func setDelegate(to newDelegate: MastermindRowDelegate) {
        self.delegate = newDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    private var viewModel: MastermindRowViewModel? {
        didSet {
            switch viewModel {
            case let .userInputMode(vm):
                delegate?.didUpdateGuess(to: vm.currentGuess)
            case let .historical(vm):
                perfectPinsLabel.text = String(repeating: "🔴", count: vm.perfectGuessCount)
                imperfectPinsLabel.text = String(repeating: "⚪️", count: vm.imperfectGuessCount)
            case .none:
                perfectPinsLabel.text = ""
                imperfectPinsLabel.text = ""
                mastermindCellsCollectionView.reloadData()
            }
        }
    }
    
    private weak var delegate: MastermindRowDelegate?
}

extension MastermindTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel {
        case let .userInputMode(userInputVM):
            return userInputVM.marbleCount
        case let .historical(historicalVM):
            return historicalVM.guess.count
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
                cell.currentOption = historicalVM.guess[indexPath.row]
            case let .userInputMode(userModeVM):
                cell.currentOption = userModeVM.currentGuess[indexPath.row]
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MastermindCollectionViewCell else {
            fatalError("Unexpected cell type")
        }
        guard let viewModel = viewModel else {
            fatalError("Expected a view model at this point")
        }
        let newSelection = cell.currentOption.nextOption()
        switch viewModel {
        case let .userInputMode(viewModel):
            var newGuess = Guess()
            let oldGuess = viewModel.currentGuess
            for i in 0..<oldGuess.count {
                newGuess.append(i == indexPath.row ? newSelection : oldGuess[i])
            }
            cell.currentOption = newSelection
            setViewModel(to: MastermindRowViewModel.userInputMode(UserInputModeMastermindRowViewModel(marbleCount: viewModel.marbleCount,
                                                                                                      currentGuess: newGuess)))
        default: break
        }
    }
}
