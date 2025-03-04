//
//  BirdDetailNoteCell.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/4/25.
//

import UIKit

class BirdDetailNoteCell: UITableViewCell {
    
    static let reuseIdentifier = "BirdDetailNoteCell"
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let bubbleBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(bubbleBackground)
        contentView.addSubview(commentLabel)
        
        NSLayoutConstraint.activate([
            bubbleBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bubbleBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            commentLabel.centerYAnchor.constraint(equalTo: bubbleBackground.centerYAnchor),
            commentLabel.centerXAnchor.constraint(equalTo: bubbleBackground.centerXAnchor),
            commentLabel.leadingAnchor.constraint(equalTo: bubbleBackground.leadingAnchor, constant: 8),
            commentLabel.topAnchor.constraint(equalTo: bubbleBackground.topAnchor, constant: 8),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.text = nil
    }
    
    func bind(_ comment: String) {
        commentLabel.text = comment
    }
}
