//
//  BirdCollectionViewCell.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/3/25.
//

import UIKit

class BirdCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "BirdCollectionViewCell"
    
    private var service: ImageServiceProtocol?
    
    private var name: String?
    
    private let image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(image)
        contentView.addSubview(gradientView)
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            label.bottomAnchor.constraint(equalTo: gradientView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        image.image = nil
        guard let key = name else { return }
        service?.cancelDownload(for: key)
        name = nil
    }
    
    func bind(_ item: BirdsListItem, service: ImageServiceProtocol) {
        label.text = item.name
        name = item.name
        self.service = service
        guard let url = item.url else {
            image.image = UIImage(systemName: "photo")
            return
        }
        service.image(for: url, key: item.name) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pic):
                    self?.image.image = pic
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

private class GradientView: UIView {
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.cgColor]
        return gradient
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}
