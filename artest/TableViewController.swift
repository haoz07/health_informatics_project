//
//  TableViewController.swift
//  artest
//
//  Created by Hao Zhang on 11/15/18.
//  Copyright © 2018 Hao Zhang. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TableViewController: UITableViewController {
    var datas = [RashLog]()
    
    var selectedUser: RashLog?
    
    let cellWithIdentifier = "InfoCell"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocalData()
        if datas.count == 0 {
            initData()
        }
//        print("count == ")
//        print(datas.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellWithIdentifier, for: indexPath)
        
        if let myCell = cell as? TableCell {
            myCell.label.text = "Rash started on " + datas[indexPath.row].dateField
            myCell.closeup.image = UIImage(data: datas[indexPath.row].closeup)
            return myCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = datas[indexPath.row]
        performSegue(withIdentifier: "toDetails", sender: selectedUser)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails",
            let vc = segue.destination as? LogDetailsController {
            vc.rashlog = sender as? RashLog
        }
    }
}

extension TableViewController {
    fileprivate func getLocalData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObectContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rash")
        
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                datas.removeAll()
                for result in results {
                    guard let user = translateData(from: result) else { return }
                    datas.insert(user, at: 0)
//                    datas.append(user)
                }
                print(datas.count)
                tableView.reloadData()
            }
            
        } catch  {
            fatalError("Unable to fetch data")
        }
    }
    
    fileprivate func initData() {
        let data1 = UIImage(named: "sample_hand copy 2")?.pngData()
        let user1 = RashLog(closeup: data1!, overview: data1!, desField: "Test Rash", dateField: "Jan 1, 2018", size: "Size: 0 cm x 0 cm")
        
        let user2 = RashLog(closeup: data1!, overview: data1!, desField: "Test Rash", dateField: "Jan 1, 2018", size: "Size: 0 cm x 0 cm")
        
        TableViewController.insertData(rash: user1)
        TableViewController.insertData(rash: user2)
        
        datas.append(user1)
        datas.append(user2)
    }
    
    class func insertData(rash: RashLog) {
        
        // get delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObectContext = appDelegate.persistentContainer.viewContext
        
        //
        let entity = NSEntityDescription.entity(forEntityName: "Rash", in: managedObectContext)
        let user = NSManagedObject(entity: entity!, insertInto: managedObectContext)
        
        //
        
        user.setValue(rash.closeup, forKey: "closeup")
        user.setValue(rash.overview, forKey: "overview")
        user.setValue(rash.dateField, forKey: "dateField")
        user.setValue(rash.desField, forKey: "desField")
        user.setValue(rash.size, forKey: "size")
        
        
        //
        do {
            try managedObectContext.save()
        } catch  {
            fatalError("Unable to save")
        }
    }
    
    
    fileprivate func translateData(from: NSManagedObject) -> (RashLog?) {
        if let overview = from.value(forKey: "overview") as? Data,
            let closeup = from.value(forKey: "closeup") as? Data,
            let desField = from.value(forKey: "desField") as? String,
            let dateField = from.value(forKey: "dateField") as? String,
            let size = from.value(forKey: "size") as? String
        {
            let rashlog = RashLog(closeup: closeup, overview: overview, desField: desField, dateField: dateField, size: size)
//            print("It works")
            return rashlog
        }
//        print("not working")
        return nil
    }
}
