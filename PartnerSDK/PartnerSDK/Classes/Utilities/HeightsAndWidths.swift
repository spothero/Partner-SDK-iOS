//
//  HeightsAndWidths.swift
//  Pods
//
//  Created by Matthew Reed on 8/1/16.
//  Copyright © 2016 SpotHero. All rights reserved.
//

import Foundation
import UIKit

enum HeightsAndWidths {
    static let standardCornerRadius: CGFloat = 5
    
    enum Margins {
        static let Small: CGFloat = 4
        static let Standard: CGFloat = 8
        static let Large: CGFloat = 16
    }
    
    enum Toolbar {
        static let StandardHeight: CGFloat = 44
    }
    
    enum Borders {
        static let Standard: CGFloat = 1
    }
    
    enum Shadow {
        
        //swiftlint:disable nesting
        enum Radius {
            static let Standard: CGFloat = 3
        }
        
        //swiftlint:disable nesting
        enum Opacity {
            static let Standard: Float = 0.25
        }
    }
    
    enum LineHeight {
        static let Standard: CGFloat = 24
    }
    
    // Eyeballed from design
    static let AnnotationSize = CGSize(width: 40, height: 50)
}
