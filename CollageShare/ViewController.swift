//
//  ViewController.swift
//  CollageShare
//
//  Created by Lin Cheng on 13/06/2017.
//  Copyright © 2017 Lin Cheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .white
        navigationItem.title = "Collage Sharing"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        view.addInteraction(UIDropInteraction(delegate: self))
        view.addInteraction(UIDragInteraction(delegate: self))
    }
    
    @objc func handleShare() {
        print("Sharing Image")
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsBeginImageContext()
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let touchPoint = session.location(in: self.view)
        if let touchedImageView = self.view.hitTest(touchPoint, with: nil) as? UIImageView {
            let touchedImage = touchedImageView.image
            let itemProvide = NSItemProvider(object: touchedImage!)
            let dragItem = UIDragItem(itemProvider: itemProvide)
            dragItem.localObject = touchedImageView
            return [dragItem]
        }
        
        return []
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        
        session.items.forEach { (dragItem) in
            if let touchedImageView = dragItem.localObject as? UIView {
                touchedImageView.removeFromSuperview()
            }
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        
        self.view.addSubview(item.localObject as! UIView)
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForCancelling item: UIDragItem, withDefault defaultPreview: UITargetedDragPreview) -> UITargetedDragPreview? {
        
        return UITargetedDragPreview(view: item.localObject as! UIView)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (obj, err) in
                
                if let err = err {
                    print("Failed to load our dragged item:", err)
                    return
                }
                
                guard let draggedImage = obj as? UIImage else { return }
                
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: draggedImage)
                    imageView.isUserInteractionEnabled = true
                    imageView.layer.borderWidth = 4
                    imageView.layer.borderColor = UIColor.black.cgColor
                    imageView.layer.shadowRadius = 5
                    imageView.layer.shadowOpacity = 0.3
                    self.view.addSubview(imageView)
                    imageView.frame = CGRect(x: 0, y: 0, width: draggedImage.size.width, height: draggedImage.size.height)
                    
                    let centerPoint = session.location(in: self.view)
                    imageView.center = centerPoint
                }
            })
        }
    }

}

