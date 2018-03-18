//
//  StoryboardImpl.swift
//  VKAppNew
//
//  Created by  Artem Mazheykin on 04.11.2017.
//  Copyright © 2017 Morodin. All rights reserved.
//

import UIKit

class StoryboardImpl: Storyboard{
    
    var storyboard: UIStoryboard
    
    init(){
        self.storyboard = UIStoryboard(name: "Story", bundle: Bundle.main)
    }
    
    func getViewController(type: StoryboardViewControllerType) -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: type.identifier)
    }

}
