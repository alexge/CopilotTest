//
//  BirdDetailViewController.swift
//  TakeHome
//
//  Created by Alexander Ge on 3/4/25.
//

import UIKit

class BirdDetailViewController: UIViewController {
    private let id: String
    private var bird: BirdDetailItem?

    private let apiService: ApiServiceProtocol
    private let imageService = ImageService.shared
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var imageHeight: NSLayoutConstraint = imageView.heightAnchor.constraint(equalToConstant: 350)
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.contentInset = UIEdgeInsets(top: 0, left: 64, bottom: 84, right: 64)
        tv.register(BirdDetailNoteCell.self, forCellReuseIdentifier: "BirdDetailNoteCell")
        return tv
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("add a note", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        return button
    }()
    
    init(id: String, name: String, service: ApiServiceProtocol = ApiService()) {
        self.id = id
        self.apiService = service
        super.init(nibName: nil, bundle: nil)
        
        imageView.image =  imageService.image(for: name)
        label.text = name
        
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchDetails(id)
    }
    
    private func setup() {
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            imageHeight,
            containerView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 80),
            addButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    private func fetchDetails(_ id: String) {
        apiService.fetchBird(for: id) { [weak self] result in
            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    self?.bird = item
                    self?.tableView.reloadData()
                    self?.label.text = item.name
                }
                guard let url = item.url else { return }
                self?.imageService.image(for: url, key: item.name) { [weak self] result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func addNote() {
        
    }
}

extension BirdDetailViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        <#code#>
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        <#code#>
//    }
}

extension BirdDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bird?.notes.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BirdDetailNoteCell", for: indexPath) as? BirdDetailNoteCell else {
            return UITableViewCell()
        }
        cell.bind(bird?.notes[indexPath.row].comment ?? "")
        return cell
    }
}
