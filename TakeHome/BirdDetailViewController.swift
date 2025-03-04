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
    private lazy var containerTop: NSLayoutConstraint = containerView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 372)
    
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
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84, right: 0)
        tv.register(BirdDetailNoteCell.self, forCellReuseIdentifier: "BirdDetailNoteCell")
        tv.showsVerticalScrollIndicator = false
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
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = true
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        view.delegate = self
        view.returnKeyType = .done
        return view
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spin = UIActivityIndicatorView(style: .large)
        spin.translatesAutoresizingMaskIntoConstraints = false
        return spin
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
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            imageHeight,
            containerTop,
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 80),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        textView.isEditable = true
        containerView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
        textView.becomeFirstResponder()
    }
}

extension BirdDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = BirdDetailTableHeaderView()
        return header
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageHeight.constant = max(350 - scrollView.contentOffset.y, 150)
        containerTop.constant = max(372 - scrollView.contentOffset.y, 172)
    }
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

extension BirdDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n" else { return true }
        textView.resignFirstResponder()
        textView.isEditable = false
        textView.addSubview(spinner)
        spinner.topAnchor.constraint(equalTo: textView.topAnchor, constant: 4).isActive = true
        spinner.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        apiService.addNote(textView.text, for: id, timestamp: Int(Date().timeIntervalSince1970)) { [weak self] result in
            switch result {
            case .success:
                self?.fetchDetails(self?.id ?? "")
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self?.spinner.removeFromSuperview()
                self?.textView.removeFromSuperview()
                self?.textView.text = nil
            }
        }
        return false
    }
}
