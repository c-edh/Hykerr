//
//  LinkedList.swift
//  Hyker
//
//  Created by Corey Edh on 6/26/22.
//

import Foundation
import MapKit

class LinkedList{
    
    var startTown : String
    var endTown : String
    
    var head : Node
    var tail : Node
    var length: Int
    
    init(_ value:Any) {
        self.startTown = ""
        self.endTown = ""
        self.head = Node(value)
        self.tail = self.head
        self.length = 0
        
    }
    
    func append(_ value: Any){
        let newNode = Node(value)
        //Start the linklist as nil,
        if self.length == 0{
            self.head = newNode
            self.tail = self.head
            self.length = 1
        }else{
            self.tail.next = newNode
            self.tail = newNode
            self.length+=1
        }
        
    }
    
    func tranverseToIndex(_ index: Int) -> Node{
        var i = 1
        var goTo = index
        if index > self.length{
            goTo = self.length
        }
        var currentNode = self.head
        while(i<goTo){
            currentNode = currentNode.next!
            i+=1
        }
        return currentNode
    }
    
    func toArray() -> [[String:String]]{
        var printArray = [[String:String]]()
        var currentNode = self.head
        var i = 0
        
        while(i<self.length-1){
            printArray.append(["Long": String((currentNode.value as! CLLocationCoordinate2D).longitude), "Lat": String((currentNode.value as! CLLocationCoordinate2D).latitude)])
            currentNode = currentNode.next!
            i+=1
        }
        return printArray
    }
    
    func mapPath() -> [CLLocationCoordinate2D]{
        var pathArray = [CLLocationCoordinate2D]()
        var currentNode = self.head
        var i = 0
        
        while(i<self.length-1){
            pathArray.append(currentNode.value as! CLLocationCoordinate2D)
            currentNode = currentNode.next!
            i+=1
        }
        return pathArray
    }
}

class Node{
    var value: Any
    var next: Node?
    init(_ value: Any) {
        self.value = value
    }
}
