import UIKit

class TodoTableViewController: UITableViewController {
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!

    var viewModel = TodosViewModel(todos: []) {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        filterSegmentedControl.addTarget(self, action: #selector(TodoTableViewController.filterValueChanged), for: .valueChanged)

        store.activeFilter.producer.startWithValues { filter in
            self.filterSegmentedControl.selectedSegmentIndex = filter.rawValue
        }

        store.activeTodos.startWithValues { todos in
            self.viewModel = TodosViewModel(todos: todos)
        }
    }
}

// MARK: Actions
extension TodoTableViewController {
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Create", message: "Create a new todo item", preferredStyle: .alert)

        alertController.addTextField() { textField in
            textField.placeholder = "Name"
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        alertController.addAction(UIAlertAction(title: "Create", style: .default) { _ in
            guard let name = alertController.textFields?.first?.text else { return }

            store.dispatch(CreateTodoAction(name: name))
        })

        present(alertController, animated: false, completion: nil)
    }

    func filterValueChanged() {
        guard let newFilter = TodoFilter(rawValue: filterSegmentedControl.selectedSegmentIndex)
        else { return }

        store.dispatch(SetFilterAction(filter: newFilter))
    }
}

// MARK: UITableViewController
extension TodoTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoTableViewCell
        let todo = viewModel.todoForIndexPath(indexPath)

        cell.configure(todo)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = viewModel.todoForIndexPath(indexPath)
        store.dispatch(ToggleCompletedAction(todo: todo))
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todo = viewModel.todoForIndexPath(indexPath)
            store.dispatch(DeleteTodoAction(todo: todo))
        }
    }
}
