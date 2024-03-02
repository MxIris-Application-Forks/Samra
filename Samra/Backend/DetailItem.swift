//
//  DetailItem.swift
//  Samra
//
//  Created by Serena on 21/02/2023.
// 

import Cocoa
import AssetCatalogWrapper

struct DetailItem: Hashable {
    /// The Primary Text, such as "Height"
    let primaryText: String
    
    /// The Secondary Text, such as the height itself in String form
    let secondaryText: String
    
    init(primaryText: String, secondaryText: String) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
    }
    
    init<T: CustomStringConvertible>(primaryText: String, secondaryText: T?, fallback: String = "Unknown") {
        self.primaryText = primaryText
        self.secondaryText = secondaryText?.description ?? fallback
    }
}

struct DetailItemSection: Hashable {
    let sectionHeader: String
    let items: [DetailItem]
    
    static func from(assetStorage: CUICommonAssetStorage) -> [DetailItemSection] {
        let toolSection = DetailItemSection(sectionHeader: "Authoring Tool", items: [
            DetailItem(primaryText: "Tool", secondaryText: assetStorage.authoringTool()),
            DetailItem(primaryText: "Version", secondaryText: String(cString: assetStorage.versionString())),
        ])
        
        let argumentsSection = DetailItemSection(sectionHeader: "Arguments", items: [
            DetailItem(primaryText: "Thinning Arguments", secondaryText: assetStorage.thinningArguments())
        ])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy h:mm a"
        let date = Date(timeIntervalSince1970: TimeInterval(assetStorage.storageTimestamp()))
        
        let dateSection = DetailItemSection(sectionHeader: "Date", items: [
            DetailItem(primaryText: "Date", secondaryText: dateFormatter.string(from: date)),
            DetailItem(primaryText: "UNIX Timestamp", secondaryText: assetStorage.storageTimestamp())
        ])
        
        let coreUIVersionText: CustomStringConvertible = assetStorage.responds(to: #selector(CUICommonAssetStorage.coreuiVersion)) ? assetStorage.coreuiVersion() : "Unknown"
        let coreUISection = DetailItemSection(sectionHeader: "Other", items: [
            DetailItem(primaryText: "CoreUI Version", secondaryText: coreUIVersionText),
            DetailItem(primaryText: "Schema Version", secondaryText: assetStorage.schemaVersion()),
        ])
        
        return [toolSection, argumentsSection, dateSection, coreUISection]
    }
    
    static func from(rendition: Rendition) -> [DetailItemSection] {
        var items = [
            DetailItemSection(sectionHeader: "Name", items: [
                DetailItem(primaryText: "Rendition Name", secondaryText: rendition.cuiRend.name()),
                DetailItem(primaryText: "Lookup Name", secondaryText: rendition.namedLookup.name),
            ])
        ]
        
        switch rendition.representation {
        case .color(let cgColor):
            let nsColor = NSColor(cgColor: cgColor)?.usingColorSpace(.deviceRGB)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            nsColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            items.append(DetailItemSection(sectionHeader: "Color Info", items: [
                DetailItem(primaryText: "Red", secondaryText: Int(red * 255)),
                DetailItem(primaryText: "Blue", secondaryText: Int(blue * 255)),
                DetailItem(primaryText: "Green", secondaryText: Int(green * 255)),
            ]))
        default:
            break
        }
        
        if rendition.type != .color {
            let size = rendition.cuiRend.unslicedSize()
            items.append(DetailItemSection(sectionHeader: "Dimensions", items: [
                DetailItem(primaryText: "Width", secondaryText: size.width),
                DetailItem(primaryText: "Height", secondaryText: size.height),
                DetailItem(primaryText: "Scale", secondaryText: rendition.cuiRend.scale())
            ]))
        }
        
        let key = rendition.namedLookup.key
        items.append(DetailItemSection(sectionHeader: "Rendition Information", items: [
            DetailItem(primaryText: "Display Gamut", secondaryText: Rendition.DisplayGamut(key)),
            DetailItem(primaryText: "Appearance", secondaryText: rendition.namedLookup.appearance),
            DetailItem(primaryText: "Idiom", secondaryText: Rendition.Idiom(key))
        ]))
        
        return items
    }
}
