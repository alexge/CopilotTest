//
//  BirdCollectionViewCell.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/3/25.
//

import UIKit

class BirdCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "BirdCollectionViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func bind(_ item: BirdsListItem) {
        label.text = item.name
    }
}
