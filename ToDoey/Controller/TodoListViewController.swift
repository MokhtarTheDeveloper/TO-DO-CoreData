//
//  ViewController.swift
//  ToDoey
//
//  Created by Ahmed Mokhtar on 5/28/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import CoreData
class TodoListViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [Item]()
    var itemCellColor : UIColor?
    var context = DataPersistent.persistentContainer.viewContext
    
    var selectedCategory :Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let colour = itemCellColor {
            navigationController?.navigationBar.barTintColor = colour
            navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: colour, isFlat: true)
            searchBar.barTintColor = colour
            title = selectedCategory?.title
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title ?? "No items added yet!"
        cell.accessoryType = item.done ? .checkmark : .none
        cell.backgroundColor = itemCellColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count))
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: itemCellColor, isFlat: true)
        return cell
    }
    //MARK: - TableView Delgate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveData()
        tableView.reloadData()
    }
    
    
    //MARK: - Adding New Items
    
    
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        var itemText = UITextField()
        
        let alert = UIAlertController(title: "Add New Task", message: "Add new item", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            let newItem = Item(context: self.context)
            
            newItem.title = itemText.text!
            newItem.done = false
            newItem.toCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveData()
          
            self.tableView.reloadData()
        }
        alert.addTextField { (textFiled) in
            itemText = textFiled}
        alert.addAction(action )
        present(alert,animated: true)
    }
    
    
    
    func saveData(){
        do{
            try context.save()
        }
        catch{
            print("There is an error: \(error)")
        }
    }

    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
      
        let categoryPredicate = NSPredicate(format: "toCategory.title MATCHES %@", selectedCategory!.title!)
        
        if let parPredicate = predicate{
            let compoundPrdicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, parPredicate])
            request.predicate = compoundPrdicate
        }
        else{
            request.predicate = categoryPredicate
        }
        
        do{
            try itemArray = context.fetch(request)
            print(itemArray.count)
        }
        catch{
         print("Erro fetching data: \(error)")
        }
        tableView.reloadData()
    }
    
    
}

extension TodoListViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
     query(text: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            searchBar.resignFirstResponder()
        }
        else{
            query(text: searchBar.text!)
        }

    }


    
    
    func query(text : String){
        let predict = NSPredicate(format: "title CONTAINS[cd] %@", text)
        loadItems(predicate: predict)
    }
}
