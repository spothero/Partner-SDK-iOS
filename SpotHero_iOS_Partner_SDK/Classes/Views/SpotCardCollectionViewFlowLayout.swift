//
//  SpotCardCollectionViewFlowLayout.swift
//  Pods
//
//  Created by Husein Kareem on 9/9/16.
//
//

import UIKit

protocol SpotCardCollectionViewFlowLayoutDelegate: class {
    func didSwipeCollectionView(_ direction: UISwipeGestureRecognizerDirection)
}

class SpotCardCollectionViewFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: SpotCardCollectionViewFlowLayoutDelegate?
    private let collectionViewHeight: CGFloat = SpotCardCollectionViewCell.ItemHeight
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    var itemWidth: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.itemWidth = screenWidth - 40
        self.itemSize = CGSize(width: self.itemWidth, height: SpotCardCollectionViewCell.ItemHeight)
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
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        //this logic is for centering the cell when paging 
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + ((self.screenWidth - self.itemSize.width) / 2)
        let targetRect = CGRect(x: proposedContentOffset.x,
                                y: 0,
                                width: self.screenWidth,
                                height: self.collectionViewHeight)
        
        if let layoutAttributesForElements = super.layoutAttributesForElements(in: targetRect) {
            for layoutAttributes in layoutAttributesForElements {
                let itemOffset = layoutAttributes.frame.origin.x
                if abs(itemOffset - horizontalOffset) < abs(offsetAdjustment) {
                    offsetAdjustment = itemOffset - horizontalOffset
                }
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    func respondToSwipeGesture(_ recognizer: UISwipeGestureRecognizer) {
        self.delegate?.didSwipeCollectionView(recognizer.direction)
    }
}
