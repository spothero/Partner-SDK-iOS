//
//  SpotCardCollectionViewFlowLayout.swift
//  Pods
//
//  Created by Husein Kareem on 9/9/16.
//
//

import UIKit

protocol SpotCardCollectionViewFlowLayoutDelegate: AnyObject {
    func didSwipeCollectionView(_ direction: UISwipeGestureRecognizer.Direction, currentIndex: Int)
}

class SpotCardCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private static let margin: CGFloat = 40
    
    weak var delegate: SpotCardCollectionViewFlowLayoutDelegate?
    
    private let collectionViewHeight: CGFloat = SpotCardCollectionViewCell.ItemHeight
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    private var cardWidth: CGFloat {
        return self.itemSize.width + self.minimumLineSpacing
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.itemSize = CGSize(
            width: self.screenWidth - SpotCardCollectionViewFlowLayout.margin,
            height: SpotCardCollectionViewCell.ItemHeight
        )
        self.minimumInteritemSpacing = SpotCardCollectionViewCell.ItemSpacing
        self.scrollDirection = .horizontal
        self.collectionView?.backgroundColor = .clear
        let inset = (self.screenWidth - CGFloat(self.itemSize.width)) / 2
        self.collectionView?.contentInset = UIEdgeInsets(top: 0,
                                                         left: inset,
                                                         bottom: 0,
                                                         right: inset)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        self.collectionView?.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        self.collectionView?.addGestureRecognizer(swipeLeft)
    }
    
    @objc
    func respondToSwipeGesture(_ recognizer: UISwipeGestureRecognizer) {
        let currentOffset = self.collectionView?.contentOffset.x ?? 0
        let currentIndex = round(currentOffset / self.cardWidth)
        self.delegate?.didSwipeCollectionView(recognizer.direction, currentIndex: Int(currentIndex))
    }
}
