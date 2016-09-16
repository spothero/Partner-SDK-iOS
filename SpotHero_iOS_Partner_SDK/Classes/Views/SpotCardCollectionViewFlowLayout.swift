//
//  SpotCardCollectionViewFlowLayout.swift
//  Pods
//
//  Created by Husein Kareem on 9/9/16.
//
//

import UIKit

class SpotCardCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private let collectionViewHeight: CGFloat = SpotCardCollectionViewCell.ItemHeight
    private let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    
    var itemWidth: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.itemWidth = screenWidth - 40
        self.itemSize = CGSize(width: self.itemWidth, height: SpotCardCollectionViewCell.ItemHeight)
        self.minimumInteritemSpacing = SpotCardCollectionViewCell.ItemSpacing
        self.scrollDirection = .Horizontal
        self.collectionView?.backgroundColor = .clearColor()
        let inset = (self.screenWidth - CGFloat(self.itemSize.width)) / 2
        self.collectionView?.contentInset = UIEdgeInsets(top: 0,
                                                         left: inset,
                                                         bottom: 0,
                                                         right: inset)
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        //this logic is for centering the cell when paging 
        var offsetAdjustment = CGFloat.max
        let horizontalOffset = proposedContentOffset.x + ((self.screenWidth - self.itemSize.width) / 2)
        let targetRect = CGRect(x: proposedContentOffset.x,
                                y: 0,
                                width: self.screenWidth,
                                height: self.collectionViewHeight)
        
        if let layoutAttributesForElements = super.layoutAttributesForElementsInRect(targetRect) {
            for layoutAttributes in layoutAttributesForElements {
                let itemOffset = layoutAttributes.frame.origin.x
                if (abs(itemOffset - horizontalOffset) < abs(offsetAdjustment)) {
                    offsetAdjustment = itemOffset - horizontalOffset
                }
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
