import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    let customAlert = CustomAlert()
    let context = CoreDataHelper.shared.persistentContainer.viewContext
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupUI()
        customAlert.delegate = self
        loadCategories()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupUI() {
        let addCategory = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addClick))
        self.navigationItem.rightBarButtonItem = addCategory
    }
    @objc private func addClick() {
        customAlert.showAlert(with: "Add New Category", message: "", on: self)
    }
    @objc func dismissAlert() {
        customAlert.dismissAlert()
        customAlert.addItem()
    }
    private func saveCategories() {
        do {
            try CoreDataHelper.shared.saveContext()
        }catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    private func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }


    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let categoriesItem = categories[indexPath.row]
        content.text = categoriesItem.name
        cell.contentConfiguration = content
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
}

extension CategoryViewController: passUserTextDelegate {
    func addItemText(userText: String) {
        if userText != "" {
            let addCategories = Category(context: self.context)
            addCategories.name = userText
            categories.append(addCategories)
            saveCategories()
        }else {
            return
        }
    }
}
