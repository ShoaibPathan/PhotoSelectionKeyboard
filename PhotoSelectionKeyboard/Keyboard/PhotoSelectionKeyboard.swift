//
//  PhotoSelectionKeyboard.swift
//  PhotoSelectionKeyboard
//
//  Created by Anoop M on 2020-2-07.
//  Copyright © 2020 Anoop M. All rights reserved.
//

import Photos
import UIKit

class PhotoSelectionKeyboard: UIInputView {
    private let imageRequestOptions = PHImageRequestOptions()
    private var imageAsset: PHFetchResult<PHAsset>!
    private var noAccessView: UIView!
    private let photosCellIdentifier = "photosCollectionCell"
    private let cellSize = CGSize(width: 200, height: 200)
    
    lazy var photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        layout.itemSize = cellSize
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = true
        view.layer.cornerRadius = 0
        view.backgroundColor = UIColor.white
        view.register(PhotosCollectionCell.self, forCellWithReuseIdentifier: photosCellIdentifier)
        return view
    }()
    
    init(withAccessPermission granted: Bool) {
        super.init(frame: .zero, inputViewStyle: .default)
        initializeImageFetch()
        if granted {
            setupView()
        } else {
            configureNoAccessView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.intrinsicHeight)
    }
    var intrinsicHeight: CGFloat = 250 {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    private func setupView() {
        addSubview(photosCollectionView)
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photosCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            photosCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            photosCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            photosCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }
    
    private func configureNoAccessView() {
        translatesAutoresizingMaskIntoConstraints = false
        noAccessView = UIView(frame: .zero)
        noAccessView.backgroundColor = UIColor.white
        noAccessView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(noAccessView)
        let titleLabel = createUILabel(with: UIFont.boldSystemFont(ofSize: 18.0), textColor: UIColor.darkText, align: .center)
        titleLabel.text = "Select a Photo"
        
        let settingsButton = UIButton(frame: .zero)
        settingsButton.setTitle("Open Settings", for: .normal)
        settingsButton.setTitleColor(UIColor.darkText, for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        settingsButton.backgroundColor = UIColor.lightGray
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = createUILabel(with: UIFont.systemFont(ofSize: 15.0), textColor: UIColor.lightGray, align: .center)
        messageLabel.text = "Go to iPhone settings and enable access to photos."
        
        noAccessView.addSubview(titleLabel)
        noAccessView.addSubview(messageLabel)
        noAccessView.addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            noAccessView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            noAccessView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            noAccessView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            noAccessView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 75),
            messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -75),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: messageLabel.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10),
            
            settingsButton.centerXAnchor.constraint(equalTo: messageLabel.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            settingsButton.widthAnchor.constraint(equalToConstant: 134),
            settingsButton.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
    
    private func createUILabel(with font: UIFont = UIFont.boldSystemFont(ofSize: 10.0), textColor color: UIColor = UIColor.black, align alignment: NSTextAlignment = NSTextAlignment.natural) -> UILabel {
        let textLabel = UILabel()
        textLabel.textColor = color
        textLabel.textAlignment = alignment
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = font
        textLabel.numberOfLines = 0
        
        return textLabel
    }
    
    @objc private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
    
    private func initializeImageFetch() {
        imageRequestOptions.isSynchronous = false
        imageRequestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        imageAsset = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
}

extension PhotoSelectionKeyboard: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if imageAsset != nil {
            count = imageAsset.count
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photosCellIdentifier, for: indexPath) as! PhotosCollectionCell
        
        let asset: PHAsset = imageAsset[indexPath.item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: imageRequestOptions) { image, _ in
            if let receivedImage = image {
                cell.configureCellWith(image: receivedImage)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 1
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotosCollectionCell
        let selectedImage = cell.getCurrentImage()
    }
}
