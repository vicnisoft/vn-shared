//
//  VNCoreDataHelper.swift
//  FFSwift
//
//  Created by Cong Can NGO on 7/27/16.
//  Copyright © 2016 Vicnisoft. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    
    class func classNameAsString() -> String {
        
        let nameSpaceClassName =  NSStringFromClass(self)
        let className = nameSpaceClassName.componentsSeparatedByString(".").last! as String
        
        return className
        
    }
    
    static func findFirst()-> AnyObject? {
        
        return CDHelper.sharedInstance.findFirst(self.classNameAsString())
        
    }
    
    
    static func findFirst(orderBy: String , ascending: Bool)-> AnyObject? {
        return CDHelper.sharedInstance.findFirst(self.classNameAsString(), orderBy: orderBy, ascending: ascending)
    }
    
    static func findFirst(attribute: String, value : String) -> AnyObject? {
        
        return CDHelper.sharedInstance.findFirst(self.classNameAsString(), attribute: attribute, value: value)
        
    }
    
    static func findAll(orderBy: String , ascending: Bool)-> [AnyObject]? {
        
        return CDHelper.sharedInstance.findAll(self.classNameAsString(), orderBy: orderBy, ascending: ascending)
    }
    
    static func findAll(sortDescriptors sortDescriptors: Array<NSSortDescriptor>?)-> [AnyObject]? {
        
        return CDHelper.sharedInstance.findAll(self.classNameAsString(), sortDescriptors: sortDescriptors)
    }
    
    
    static func findAll(sortDescriptors sortDescriptors: Array<NSSortDescriptor>?,  predicate: NSPredicate)-> [AnyObject]? {
        
        return CDHelper.sharedInstance.findAll(self.classNameAsString(), sortDescriptors: sortDescriptors, predicate: predicate)
    }
    
    
    
    static func findAll(orderBy: String , ascending: Bool, predicate: NSPredicate)-> [AnyObject]? {
        
       return CDHelper.sharedInstance.findAll(self.classNameAsString(), orderBy: orderBy, ascending: ascending, predicate: predicate)
    }
    
    static  func findAll(orderBy: String , ascending: Bool, groupBy: String)-> [AnyObject]? {
        
        return CDHelper.sharedInstance.findAll(self.classNameAsString(), orderBy: orderBy, ascending: ascending, groupBy: groupBy)
        
    }
    
    
    static func create()->AnyObject? {
        return CDHelper.sharedInstance.create(self.classNameAsString())
    }
    
}

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsStr = self as NSString
        return nsStr.stringByAppendingPathComponent(path)
    }
}

class CDHelper {
    
    static let sharedInstance = CDHelper()
    
    private var modelName = "VNCoreDataA"
    private var modelType = "sqlite"
    
    func setModel(name: String, type: String){
        self.modelName = name
        self.modelType = type
    }
    
    
    private lazy var managedObjectContext : NSManagedObjectContext? = {
        
        if let coordinator = self.persistentStoreCoordinator {
            
            let context : NSManagedObjectContext = NSManagedObjectContext.init(concurrencyType: .PrivateQueueConcurrencyType)
            context.undoManager = NSUndoManager.init()
            context.persistentStoreCoordinator = coordinator
            return context
            
        }
        
        return nil
    }()
    
    private lazy var managedObjectModel : NSManagedObjectModel? = {
        
        return NSManagedObjectModel.mergedModelFromBundles(nil)
    }()
    
    private lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator? = {
        
        if let storePath = self.applicationLibraryDirectory()?.stringByAppendingPathComponent(String.init(format: "%@.%@", self.modelName,self.modelType)){
            
            let storeURL = NSURL.fileURLWithPath(storePath)
            
            print("storeURL = \(storeURL)")
            
            let fileMananger = NSFileManager.defaultManager()
            
            if fileMananger.fileExistsAtPath(storePath) == false {
                
                if let defaulStorePath = NSBundle.mainBundle().pathForResource(self.modelName, ofType: self.modelType){
                    if fileMananger.fileExistsAtPath(defaulStorePath) {
                        do {
                            try
                            
                                fileMananger.copyItemAtPath(defaulStorePath, toPath: storePath)
                            print("Success to copy ");

                            
                        } catch {
                            print("error to copy");
                            
                        }
                    }
                }
                
                
            }
            
            if let objectModel = self.managedObjectModel {
                
//                NSPersistentStoreCoordinator *coordinator = [EncryptedStore makeStore:[self managedObjectModel]:@"SOME_PASSCODE"];
                
                
                let coordinator : NSPersistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel:objectModel )
//                let coordinator : NSPersistentStoreCoordinator = EncryptedStore.makeSo
                
//                [EncryptedStore makeStoreWithOptions:options managedObjectModel:[self managedObjectModel]];
                
                //            remove journal_mode in ios >= 7.0
                let pragmaOptions = ["journal_mode" : "DELETE"]
                let options = [NSMigratePersistentStoresAutomaticallyOption : NSNumber(bool: true) , NSInferMappingModelAutomaticallyOption : NSNumber(bool: true), NSSQLitePragmasOption : pragmaOptions ]
                
                do {
                    try
                        coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
                    
                    return coordinator

                } catch {
                    
                }
                
            }
            
        }
        
        return nil
    }()
    
    

//    MARK: Publics Function Fetch
    
    func findFirst(entityName: String)-> AnyObject?{
        
        if let request : NSFetchRequest = NSFetchRequest.init(entityName: entityName){
            do {
                if let objects = try self.managedObjectContext?.executeFetchRequest(request){
                    return objects.count != 0 ? objects[0] : nil
                }
                
            } catch {
                
            }
        }
        
        return nil
    }
    
    func findFirst(entityName: String, orderBy: String, ascending: Bool)-> AnyObject?{
        
        if let request : NSFetchRequest = NSFetchRequest.init(entityName: entityName){
            
            let sortDescription = NSSortDescriptor(key: orderBy, ascending: ascending)
            
            request.sortDescriptors = [sortDescription]
            
            do {
                if let objects = try self.managedObjectContext?.executeFetchRequest(request){
                    return objects.count != 0 ? objects[0] : nil
                }
                
            } catch {
                
            }
        }
        
        return nil
    }
    
    func findFirst(entityName: String, attribute: String, value : String) -> AnyObject? {
        if let request : NSFetchRequest = NSFetchRequest.init(entityName: entityName){
            do {
                let predicate = NSPredicate(format: "%K = %@", attribute, value)
                request.predicate = predicate
                
                if let objects = try self.managedObjectContext?.executeFetchRequest(request){
                    return objects.count != 0 ? objects[0] : nil
                }
                
            } catch {
                
            }
        }
        
        return nil
    }

    func findAll(entityName: String, orderBy: String , ascending: Bool)-> [AnyObject]? {
        
        if let request : NSFetchRequest = NSFetchRequest.init(entityName: entityName){
            do {
                let sortDescription = NSSortDescriptor(key: orderBy, ascending: ascending)
                
                request.sortDescriptors = [sortDescription]
                
                if let objects = try self.managedObjectContext?.executeFetchRequest(request){
                    return objects.count == 0 ? nil : objects
                }
                
            } catch {
                
            }
        }
        
        return nil;
    }
    
    func findAll(entityName: String, sortDescriptors: Array<NSSortDescriptor>?)-> [AnyObject]? {
        
        if let request : NSFetchRequest = NSFetchRequest.init(entityName: entityName){
            do {
                
                request.sortDescriptors = sortDescriptors
                
                if let objects = try self.managedObjectContext?.executeFetchRequest(request){
                    return objects.count == 0 ? nil : objects
                }
                
            } catch {
                
            }
        }
        
        return nil;
    }
    
    
    func findAll(entityName: String, sortDescriptors: Array<NSSortDescriptor>?,  predicate: NSPredicate)-> [AnyObject]? {
        
        if let request : NSFetchRequest = NSFetchRequest.init(entityName: entityName){
            do {
                
                request.sortDescriptors = sortDescriptors
                request.predicate = predicate
                
                if let objects = try self.managedObjectContext?.executeFetchRequest(request){
                    return objects.count == 0 ? nil : objects
                }
                
            } catch {
                
            }
        }
        
        return nil;
    }

    
    
    func findAll(entityName: String, orderBy: String , ascending: Bool, predicate: NSPredicate)-> [AnyObject]? {
        
        if let request : NSFetchRequest = NSFetchRequest.init(entityName: entityName){
            do {
                let sortDescription = NSSortDescriptor(key: orderBy, ascending: ascending)
            
                request.predicate = predicate
                request.sortDescriptors = [sortDescription]
                
                if let objects = try self.managedObjectContext?.executeFetchRequest(request){
                    return objects.count == 0 ? nil : objects
                }
                
            } catch {
                
            }
        }
        
        return nil;
    }
    
    func findAll(entityName: String, orderBy: String , ascending: Bool, groupBy: String)-> [AnyObject]? {
        
        
        if let context = self.managedObjectContext {
            
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
            
            if let attributeDescriptions = entity?.attributesByName{
                
                if let typeDescription = attributeDescriptions[groupBy] {
                    
                    let keyPathExpression = NSExpression.init(forKeyPath: groupBy)
                    let countExpression = NSExpression.init(forFunction: "count:", arguments: [keyPathExpression])
                    let expressionDescription = NSExpressionDescription()
                    expressionDescription.name = "count"
                    expressionDescription.expression = countExpression
                    expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
                    
                    
                    
                    if let request : NSFetchRequest = NSFetchRequest.init(entityName: entityName){
                        do {
                            request.propertiesToGroupBy = [typeDescription]
                            
                            request.propertiesToFetch = [expressionDescription, typeDescription]
                            
                            let sortDescription = NSSortDescriptor(key: orderBy, ascending: ascending)
                            
                            
                            request.sortDescriptors = [sortDescription]
                            
                            request.resultType = .DictionaryResultType
                            
                            if let objects = try self.managedObjectContext?.executeFetchRequest(request){
                                return objects.count == 0 ? nil : objects
                            }
                            
                        } catch {
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
        return nil;
    }
    
    

    
    
//    MARK: Create Entity
    
    func create(entityName: String)-> AnyObject?{
        
        if let context =  self.managedObjectContext {
            return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)

        }
        return nil
        
    }
    
//    MARK: Delete Entity
    
    func deleteEntity(entity: NSManagedObject!){
        self.managedObjectContext?.deleteObject(entity)
    }
    
    
    
//    MARK : Save Context
    
    func saveContext() -> Bool {
             
        if let context = self.managedObjectContext {
            
            if context.hasChanges {
                
                context.performBlockAndWait({
                    do {
                        try context.save()
                        
                    } catch {
                        
                    }
                })
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    //    MARK: Path to store SQLite file
    
    func applicationLibraryDirectory() -> String? {
        
        return NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).last
    }
    
    func applicationLibraryDictectoryPath() -> NSURL? {
        
        return NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).last
        
    }
    
//    func findFirstEntity(entityName: String)-> AnyObject {
//        
//        
//        
//    }
    
    
    
}