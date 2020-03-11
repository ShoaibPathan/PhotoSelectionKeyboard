//
//  PhotosTVC.swift
//  PhotoSelectionKeyboard
//
//  Created by Anoop M on 2020-02-07.
//  Copyright © 2020 Anoop M. All rights reserved.
//

import UIKit

class PhotosCollectionCell: UICollectionViewCell {
    private var currentImage: UIImage!
    var photoImageView = UIImageView(frame: .zero)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCellWith(image: UIImage) {
        photoImageView.image = image
        currentImage = image
    }

    func getCurrentImage() -> UIImage {
        return currentImage
    }

    private func setupView() {
        addSubview(photoImageView)
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        NSLayoutConstraint.activate([
            photoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            photoImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }
}
