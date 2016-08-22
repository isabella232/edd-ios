//
//  FileDownloadLogsController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

class FileDownloadLogsController: UITableViewController, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    
}
