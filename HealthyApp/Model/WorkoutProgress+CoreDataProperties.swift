//
//  WorkoutProgress+CoreDataProperties.swift
//  HealthyApp
//
//  Created by Christian Willson on 15/11/21.
//  Copyright © 2021 Christian Willson. All rights reserved.
//
//

import Foundation
import CoreData


extension WorkoutProgress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutProgress> {
        return NSFetchRequest<WorkoutProgress>(entityName: "WorkoutProgress")
    }

    @NSManaged public var date: String?
    @NSManaged public var images: [Data]?

}
