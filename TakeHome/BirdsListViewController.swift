//
//  BirdsListViewController.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/3/25.
//

import UIKit

class BirdsListViewController: UIViewController {
    let service: ApiServiceProtocol
    var items: [BirdsListItem] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(BirdCollectionViewCell.self, forCellWithReuseIdentifier: BirdCollectionViewCell.reuseIdentifier)
        return cv
    }()
    
    init(service: ApiServiceProtocol = ApiService()) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadList()
        setup()
    }
    
    private func setup() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        setupSearch()    }
    
    private func setupSearch() {
        let search = UISearchBar()
        search.placeholder = "Search"
        search.sizeToFit()
        navigationItem.titleView = search
        let micImage = UIImage(systemName: "mic.fill")
        search.setImage(micImage, for: .bookmark, state: .normal)
        search.showsBookmarkButton = true
    }
    
    private func loadList() {
        service.fetchBirdsList { [weak self] result in
            switch result {
            case .success(let items):
                self?.items = items
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                // log error
                print(error)
            }
        }
    }
}

extension BirdsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bird = items[indexPath.item]
        let detail = BirdDetailViewController(id: bird.id, name: bird.name)
        detail.modalPresentationStyle = .formSheet
        present(detail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2.0)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension BirdsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BirdCollectionViewCell.reuseIdentifier, for: indexPath) as? BirdCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.bind(items[indexPath.item])
        return cell
    }
}
