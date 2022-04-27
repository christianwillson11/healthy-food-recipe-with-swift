//
//  Recipe+CoreDataProperties.swift
//  HealthyApp
//
//  Created by Christian Willson on 04/11/21.
//  Copyright © 2021 Christian Willson. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var category: String?
    @NSManaged public var cook_time: String?
    @NSManaged public var descriptions: String?
    @NSManaged public var images: [Data]?
    @NSManaged public var ingredients: [String]?
    @NSManaged public var instructions: [String]?
    @NSManaged public var name: String?

}
