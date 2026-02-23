//
//  KlipyGifController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23. 2. 2026..
//

import Combine
import Kingfisher
import UIKit
import FLAnimatedImage

class KlipyGifController: UIViewController, Themeable {

    var gifSelectedCallback: ((KlipyGIF) -> Void)

    private let manager = KlipyManager()
    private var cancellables = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(gifSelectedCallback: @escaping ((KlipyGIF) -> Void)) {
        self.gifSelectedCallback = gifSelectedCallback
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Views

    private let searchField = UITextField()
    private let cancelButton = UIButton()

    private let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    private let gifCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()

    private let attributionLabel = UILabel("Powered by KLIPY", color: .foreground3, font: .appFont(withSize: 13, weight: .regular), multiline: true)

    private var selectedCategoryIndex: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setBindings()
    }

    func updateTheme() {
        view.backgroundColor = .background

        searchField.backgroundColor = .background3
        searchField.textColor = .foreground
        searchField.attributedPlaceholder = NSAttributedString(
            string: "Search KLIPY",
            attributes: [.foregroundColor: UIColor.foreground4]
        )

        cancelButton.setTitleColor(.foreground, for: .normal)

        categoryCollectionView.backgroundColor = .background
        gifCollectionView.backgroundColor = .background

        attributionLabel.textColor = .foreground4

        categoryCollectionView.reloadData()
    }
}

// MARK: - Setup

private extension KlipyGifController {
    func setup() {
        setupSearchBar()
        setupCategoryBar()
        setupGIFGrid()
        setupAttribution()
        setupLayout()
        updateTheme()
    }

    func setupSearchBar() {
        let searchIcon = UIImageView(image: UIImage(named: "searchIconSmall"))
        searchIcon.tintColor = .foreground4
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.constrainToSize(20)
        searchIcon.isUserInteractionEnabled = true
        searchIcon.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in self?.searchField.becomeFirstResponder() }))

        let searchStack = UIStackView([searchIcon, searchField])
        searchStack.alignment = .center
        searchStack.spacing = 8

        let searchContainer = UIView()
        searchContainer.addSubview(searchStack)
        searchStack.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview()
        searchContainer.layer.cornerRadius = 18
        searchContainer.constrainToSize(height: 36)
        searchContainer.backgroundColor = .background3

        searchField.font = .appFont(withSize: 16, weight: .regular)
        searchField.autocorrectionType = .no
        searchField.returnKeyType = .search
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .appFont(withSize: 16, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)

        let topStack = UIStackView([searchContainer, cancelButton])
        topStack.spacing = 12
        topStack.alignment = .center
        topStack.tag = 100

        view.addSubview(topStack)
        topStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .top, padding: 12, safeArea: true)
    }

    func setupCategoryBar() {
        categoryCollectionView.register(KlipyCategoryCell.self, forCellWithReuseIdentifier: "category")
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.constrainToSize(height: 36)
        categoryCollectionView.tag = 200

        view.addSubview(categoryCollectionView)
    }

    func setupGIFGrid() {
        gifCollectionView.register(KlipyGIFCell.self, forCellWithReuseIdentifier: "gif")
        gifCollectionView.dataSource = self
        gifCollectionView.delegate = self
        gifCollectionView.keyboardDismissMode = .onDrag
        gifCollectionView.tag = 300

        view.addSubview(gifCollectionView)
    }

    func setupAttribution() {
        attributionLabel.constrainToSize(height: 32)
        attributionLabel.tag = 400

        view.addSubview(attributionLabel)
    }

    func setupLayout() {
        let topStack = view.viewWithTag(100)!

        categoryCollectionView
            .pinToSuperview(edges: .horizontal)
        categoryCollectionView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 12).isActive = true

        gifCollectionView
            .pinToSuperview(edges: .horizontal)
        gifCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8).isActive = true

        attributionLabel
            .pinToSuperview(edges: .horizontal)
        attributionLabel.topAnchor.constraint(equalTo: gifCollectionView.bottomAnchor).isActive = true
        attributionLabel.pinToSuperview(edges: .bottom, safeArea: true)
    }

    func setBindings() {
        manager.$results.withPrevious()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (old, new) in
                if old.count < new.count {
                    self?.gifCollectionView.insertItems(at: (old.count..<new.count).map { IndexPath(row: $0, section: 0) })
                } else {
                    self?.gifCollectionView.reloadData()
                }
            }
            .store(in: &cancellables)

        manager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Can be used to show/hide loading indicator
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions

private extension KlipyGifController {
    @objc func searchTextChanged() {
        let text = searchField.text ?? ""

        if text.isEmpty {
            selectedCategoryIndex = 0
            categoryCollectionView.reloadData()
            manager.loadTrending()
        } else {
            selectedCategoryIndex = -1
            categoryCollectionView.reloadData()
            manager.searchDebounced(text)
        }
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension KlipyGifController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let text = textField.text ?? ""
        if !text.isEmpty {
            manager.search(text)
        }
        return true
    }
}

// MARK: - Category CollectionView

extension KlipyGifController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return KlipyManager.categories.count
        }
        return manager.results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! KlipyCategoryCell
            let category = KlipyManager.categories[indexPath.item]
            cell.configure(title: category, isSelected: indexPath.item == selectedCategoryIndex)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gif", for: indexPath) as! KlipyGIFCell
        let gif = manager.results[indexPath.item]
        cell.configure(with: gif)

        if indexPath.item >= manager.results.count - 6 {
            manager.loadNextPage()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategoryIndex = indexPath.item
            categoryCollectionView.reloadData()

            let category = KlipyManager.categories[indexPath.item]
            searchField.text = category == "Trending" ? "" : category
            searchField.resignFirstResponder()
            manager.loadCategory(category)
        } else {
            let gif = manager.results[indexPath.item]
            manager.registerShare(gif: gif)
            gifSelectedCallback(gif)
            dismiss(animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            let text = KlipyManager.categories[indexPath.item] as NSString
            let textWidth = text.size(withAttributes: [.font: UIFont.appFont(withSize: 15, weight: .semibold)]).width
            return CGSize(width: textWidth + 28, height: 32)
        }

        let spacing: CGFloat = 2 * 2
        let width = (collectionView.bounds.width - spacing) / 3
        return CGSize(width: floor(width), height: floor(width))
    }
}

// MARK: - Category Cell

final class KlipyCategoryCell: UICollectionViewCell, Themeable {
    private let label = UILabel()
    private var isSelectedCategory = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        label.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 14)

        label.font = .appFont(withSize: 15, weight: .semibold)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        layer.cornerRadius = 16
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, isSelected: Bool) {
        label.text = title
        isSelectedCategory = isSelected
        updateTheme()
    }

    func updateTheme() {
        if isSelectedCategory {
            backgroundColor = .foreground
            label.textColor = .background
        } else {
            backgroundColor = .background3
            label.textColor = .foreground
        }
    }
}

// MARK: - GIF Cell

final class KlipyGIFCell: UICollectionViewCell {
    private let imageView = FLAnimatedImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        imageView.pinToSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .background3
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }

    var currentURL: String?
    func configure(with gif: KlipyGIF) {
        guard let url = gif.tinygifURL ?? gif.mediumgifURL ?? gif.gifURL else {
            imageView.animatedImage = nil
            return
        }
        
        currentURL = url.absoluteString
        CachingManager.instance.getAnimatedImage(url) { [weak self] res in
            guard let self, self.currentURL == url.absoluteString, case .success(let image) = res else { return }
            self.imageView.animatedImage = image
        }
    }
}
