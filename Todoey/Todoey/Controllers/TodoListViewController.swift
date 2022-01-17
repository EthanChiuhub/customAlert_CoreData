import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    let customAlert = CustomAlert()
    let searchBar = UISearchBar()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = CoreDataHelper.shared.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        customAlert.delegate = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var contentOffset: CGPoint = self.tableView.contentOffset
        contentOffset.y += (self.tableView.tableHeaderView?.frame)!.height
        self.tableView.contentOffset = contentOffset
    }
    
    private func setupUI() {
        let addList = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickAddList))
        self.navigationItem.rightBarButtonItem = addList
        addList.tintColor = .white
        searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchBar
    }
    
    @objc private func clickAddList() {
        customAlert.showAlert(with: "Add New Todoey Item", message: "", on: self)
    }
    
    @objc func dismissAlert() {
        customAlert.dismissAlert()
        customAlert.addItem()
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            let item = itemArray[indexPath.row]
            content.text = item.title
            
            //Ternary operator ==>
            //value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
            cell.contentConfiguration = content
        } else {
            // Fallback on earlier versions
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        //Core Data Delet
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - Model Manupulation Methods
    
    func saveItems() {
        //        let newFloderUrl = dataFilePath!
        //        let encoder = PropertyListEncoder()
        do {
            //            let data = try encoder.encode(itemArray)
            //            try data.write(to: self.dataFilePath!)
            try CoreDataHelper.shared.saveContext()
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [addtionalPredicate])
        }else {
            request.predicate = categoryPredicate
        }
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

// MARK: - CustomAlert Delegate
extension TodoListViewController: passUserTextDelegate {
    func addItemText(userText: String) {
            let newItem = Item(context: self.context)
            newItem.title = userText
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            itemArray.append(newItem)
            saveItems()
        tableView.reloadData()
    }}

// MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
