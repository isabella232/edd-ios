//
//  SyncCoordinator.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 04/06/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public final class SyncCoordinator: NSObject {
    
    public static let sharedInstance: SyncCoordinator = {
        return SyncCoordinator()
    }()
    
    private let managedObjectContext: NSManagedObjectContext!
    private let site: Site!
    
    private override init() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        site = Site.activeSite()
    }
    
}