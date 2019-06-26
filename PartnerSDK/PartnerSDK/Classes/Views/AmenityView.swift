//
//  AmenityView.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 12/20/17.
//

import UIKit

/// A collection of Amenity names in rounded grey bubble outlines
class AmenityView: UIStackView {
    
    /// Create a multi-line version that shows all amenities
    ///
    /// - Parameters:
    ///   - amenities: The amenities to show in this view
    ///   - width: the width of this view
    convenience init(multilineAmenities amenities: [Amenity], width: CGFloat) {
        self.init()
        self.axis = .vertical
        self.alignment = .leading
        self.distribution = .fill
        self.spacing = HeightsAndWidths.Margins.Standard
        let lineSpacing = HeightsAndWidths.Margins.Small
        
        let names = self.namesFromAmenities(amenities)
        let linesOfNames = self.splitNamesIntoLines(names: names,
                                                    spacing: lineSpacing,
                                                    width: width)
        for lineOfNames in linesOfNames {
            let line = AmenityView(amenityNames: lineOfNames,
                                   spacing: lineSpacing,
                                   width: width,
                                   height: 20)
            self.addArrangedSubview(line)
        }
    }
    
    /// Create a single line bubble amenity view
    ///
    /// - Parameters:
    ///   - amenityNames: The amenity names to show
    ///   - spacing: The spacing between each name
    ///   - width: The total width of the view
    convenience init(amenityNames: [String],
                     spacing: CGFloat,
                     width: CGFloat,
                     height: CGFloat = 16) {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: width,
                           height: height)
        self.init(frame: frame)
        self.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        self.axis = .horizontal
        self.alignment = .fill
        self.distribution = .fillProportionally
        self.spacing = spacing
        self.configureWithAmenityNames(amenityNames)
    }
    
    private func splitNamesIntoLines(names: [String],
                                     spacing: CGFloat,
                                     width: CGFloat) -> [[String]] {
        var lines = [[String]]()
        var currentLine = [String]()
        var remainingLineWidth = width
        for name in names {
            let nameWidth = self.amenityCellWidth(name)
            guard width > nameWidth else {
                assertionFailure("width of amenity \(name) is too big (\(nameWidth) > \(width))")
                //in production, don't add the too long amenity
                continue
            }
            remainingLineWidth -= nameWidth
            if !currentLine.isEmpty {
                remainingLineWidth -= spacing
            }
            if remainingLineWidth >= 0 {
                //keep going on the current line
                currentLine.append(name)
            } else {
                //append the existing current line
                lines.append(currentLine)
                //create a new line
                currentLine = [name]
                remainingLineWidth = width - nameWidth
            }
        }
        lines.append(currentLine)
        
        return lines
    }
    
    func removeAllAmenities() {
        self.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func configureWithRate(_ rate: Rate) {
        let amenities = rate.appVisibleAmenities
        let names = self.namesFromAmenities(amenities)
        self.configureWithAmenityNames(names)
    }
    
    private func namesFromAmenities(_ amenities: [Amenity]) -> [String] {
        var names = amenities.map { $0.name } // get all amenity names.
        //there isn't an Uncovered amenity, so look for the absence of the Covered amentity
        if !amenities.contains(where: { $0.slug == "covered-parking" }) {
            names.append(LocalizedStrings.Uncovered)
        }
        return names
    }
    
    func configureWithAmenityNames(_ spotAmenities: [String]) {
        var overflowAmenities = 0
        
        //precalculate all the widths of the amenity names
        let widths = spotAmenities.map { self.amenityCellWidth($0) }
        let availableWidth = self.frame.width
        var totalWidth: CGFloat = widths.reduce(0, +)
        totalWidth += (self.spacing * CGFloat(widths.count - 1)) //add in spacing between each width
        if totalWidth > availableWidth {
            //too many amenities, reduce until there's enough room for the overflow label
            let overflowLabelWidth = self.amenityCellWidth(String(format: LocalizedStrings.MoreAmenitiesFormat, "0"), margins: 0)
            let remainingWidth = availableWidth - (overflowLabelWidth + self.spacing)
            while totalWidth > remainingWidth {
                //remove amenities until we have enough remaining width
                overflowAmenities += 1
                let widthToRemove = widths[widths.count - overflowAmenities]
                totalWidth -= widthToRemove + self.spacing
                if totalWidth < 0 {
                    break
                }
            }
        }
        
        let amenitiesAndWidths = zip(spotAmenities.dropLast(overflowAmenities), widths)
        for (amenity, width) in amenitiesAndWidths {
            let amenityLabel = CaptionInputLabel()
            amenityLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
            amenityLabel.layer.borderWidth = HeightsAndWidths.Borders.Standard
            amenityLabel.textAlignment = .center
            amenityLabel.layer.borderColor = UIColor.shp_pavement.cgColor
            amenityLabel.layer.cornerRadius = self.frame.height / 2 //fully rounded corners
            amenityLabel.text = amenity
            amenityLabel.setContentHuggingPriority(.required, for: .horizontal)
            self.addArrangedSubview(amenityLabel)
        }
        if overflowAmenities > 0 {
            let additionalAmenitiesLabel = CaptionInputLabel()
            additionalAmenitiesLabel.text = String(format:LocalizedStrings.MoreAmenitiesFormat, "\(overflowAmenities)")
            additionalAmenitiesLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            additionalAmenitiesLabel.allowsDefaultTighteningForTruncation = true
            self.addArrangedSubview(additionalAmenitiesLabel)
        } else {
            self.addArrangedSubview(UIView()) //Add empty view so the amenities don't stretch
        }
    }
    
    //Cache for string widths
    private static var cachedCellWidth = [String: CGFloat]()
    
    private func amenityCellWidth(_ amenity: String, margins: CGFloat = HeightsAndWidths.Margins.Standard) -> CGFloat {
        let cacheKey = "\(amenity)\(margins)"
        if let cachedWidth = AmenityView.cachedCellWidth[cacheKey] {
            return cachedWidth
        }
        let font = UIFont.shp_captionInput
        var size = font.shp_sizeOfString(amenity, constrainedToHeight: self.frame.height)
        size.width += (2 * margins)
        let width = ceil(size.width)
        AmenityView.cachedCellWidth[cacheKey] = width
        return width
    }
    
}
