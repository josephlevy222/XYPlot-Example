//
//  Settings+CoreDataProperties.swift
//  XYPlot-Example
//
//  Created by Joseph Levy on 1/8/23.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var autoScale: Bool
    @NSManaged public var format: String?
    @NSManaged public var independentsTics: Bool
    @NSManaged public var legendPosX: Double
    @NSManaged public var legendPosY: Double
    @NSManaged public var sAxisTitle: String?
    @NSManaged public var showLegend: Bool
    @NSManaged public var sizeMajor: Double
    @NSManaged public var sizeMinor: Double
    @NSManaged public var sMajor: Int64
    @NSManaged public var sMax: Double
    @NSManaged public var sMin: Double
    @NSManaged public var sMinor: Int64
    @NSManaged public var title: String?
    @NSManaged public var useSecondary: Bool
    @NSManaged public var xAxisTitle: String?
    @NSManaged public var xMajor: Int64
    @NSManaged public var xMax: Double
    @NSManaged public var xMin: Double
    @NSManaged public var xMinor: Int64
    @NSManaged public var yAxisTitle: String?
    @NSManaged public var yMajor: Int64
    @NSManaged public var yMax: Double
    @NSManaged public var yMin: Double
    @NSManaged public var yMinor: Int64
    @NSManaged public var attribute: Data?

}

extension Settings : Identifiable {

}
