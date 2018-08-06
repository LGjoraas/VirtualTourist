//
//  PhotoAlbumView+Extensions.swift
//  VirtualTourist
//
//  Created by Ryan Gjoraas on 8/5/18.
//  Copyright © 2018 Developed by Gjoraas. All rights reserved.
//

import UIKit
import CoreData

extension PhotoAlbumView {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndices = [IndexPath]()
        deletedIndices = [IndexPath]()
        updatedIndices = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndices.append(newIndexPath!)
            break
        case .delete:
            deletedIndices.append(indexPath!)
            break
        case .update:
            updatedIndices.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndices {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndices {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndices {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
}

extension PhotoAlbumView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumViewCell
        let imageData = try? Data(contentsOf: URL(string: photo.imageURL!)!)
        cell.imageView.image = UIImage(data: imageData!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController?.viewContext.delete(photoToDelete)
        do {
            try dataController?.viewContext.save()
        } catch {
            print("Unable to delete photo")
        }
    }
}


