//
//  CategoryTableViewController.swift
//  ToDoey
//
//  Created by Ahmed Mokhtar on 5/31/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
import SwipeCellKit

class CategoryTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var categoryArray = [Category]()
    let context = DataPersistent.persistentContainer.viewContext
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        loadData()
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categoryArray[indexPath.row].title
        cell.backgroundColor = UIColor(hexString: categoryArray[indexPath.row].cellColor)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //MARK: - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VC = segue.destination as! TodoListViewController
        
        let indexPath = tableView.indexPathForSelectedRow
        if (indexPath?.row) != nil{
            index = (indexPath?.row)!
        }
        VC.selectedCategory = categoryArray[index]
        VC.itemCellColor = UIColor(hexString: categoryArray[index].cellColor)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
            self.saveData()
        }
        
        
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        
        return options
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.flatGreenColorDark()
    }

    
    
    //MARK: - Data Mainpulation
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "Enter new category", preferredStyle: .alert)
        
        var textField = UITextField()
        
        alert.addTextField { (textfiled) in
            textField = textfiled
        }
        
        let act = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            
            newCategory.title = textField.text!
            newCategory.cellColor = UIColor.randomFlat()?.hexValue()
            
            self.categoryArray.append(newCategory)
            
            self.saveData()
            
            self.tableView.reloadData()
        }
        alert.addAction(act)
        present(alert, animated: true)
    }
    
    func saveData(){
        do{
            try context.save()
        }
        catch{
            print("Error saving data: \(error)")
        }
    }
    
    func loadData(){
        let fetchedData : NSFetchRequest<Category> = Category.fetchRequest()
        do{
            try categoryArray = context.fetch(fetchedData)
        }
        catch{
            print("Error fetching data: \(error)")
        }
    }
}
