//
//  Settings+CoreDataProperties.swift
//  XYPlot-Example
//
//  Created by Joseph Levy on 1/1/23.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var independentsTics: Bool
    @NSManaged public var legendPosX: Double
    @NSManaged public var legendPosY: Double
    @NSManaged public var sAxisTitle: AttributedString?
    @NSManaged public var sMajor: Int64
    @NSManaged public var sMinor: Int64
    @NSManaged public var title: AttributedString?
    @NSManaged public var useSecondary: Bool
    @NSManaged public var xAxisTitle: AttributedString?
    @NSManaged public var xMajor: Int64
    @NSManaged public var xMax: Double
    @NSManaged public var xMin: Double
    @NSManaged public var xMinor: Int64
    @NSManaged public var yAxisTitle: AttributedString?
    @NSManaged public var yMajor: Int64
    @NSManaged public var yMax: Double
    @NSManaged public var yMin: Double
    @NSManaged public var yMinor: Int64

}
