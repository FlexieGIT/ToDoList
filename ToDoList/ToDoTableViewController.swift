//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Алексей Красиков on 10.02.2021.
//

import UIKit

class ToDoTableViewController: UITableViewController, ToDoCellDelegate, UISearchBarDelegate {
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender)
        {
            var todo = currentTodos[indexPath.row]
            todo.isComplete.toggle()
            todos[todos.firstIndex(of: currentTodos[indexPath.row])!] = todo
            currentTodos[indexPath.row] = todo
            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(todos)
        }
    }
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    var todos = [ToDo]()
    var currentTodos = [ToDo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .systemOrange
        self.editButtonItem.title = "Изменить"
        if let savedToDos = ToDo.loadToDos() {
            todos = savedToDos
        } else {
            todos = ToDo.loadSampleToDos()
        }
        setUpSearchBar()
    }
    
    @IBAction func unwindToDoList(segue: UIStoryboardSegue){
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! ToDoDetailTableViewController
        
        currentTodos = todos
        tableView.reloadData()
        
        if let todo = sourceViewController.todo {
            if let indexOfExistingToDo = todos.firstIndex(of: todo) {
                todos[indexOfExistingToDo] = todo
                currentTodos[indexOfExistingToDo] = todo
                tableView.reloadRows(at: [IndexPath(row:
                   indexOfExistingToDo, section: 0)], with: .automatic)
            } else {
                let newIndexPath = IndexPath(row: todos.count, section: 0)
                todos.append(todo)
                currentTodos.append(todo)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        ToDo.saveToDos(todos)
        searchBar.resignFirstResponder()
    }
    
    
    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        tableView.deselectRow(at: indexPath, animated: true)
        let detailController = ToDoDetailTableViewController(coder: coder)
        detailController?.todo = currentTodos[indexPath.row]
        
        return detailController
    }
    
    private func setUpSearchBar() {
        searchBar.delegate = self
        currentTodos = todos
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentTodos = todos
            tableView.reloadData()
            return
        }
        currentTodos = todos.filter({ ToDo -> Bool in
            guard let text = searchBar.text else {return false}
            return ToDo.title.lowercased().contains(text.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTodos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell

        let todo = currentTodos[indexPath.row]
        cell.titleLabel?.text = todo.title
        cell.isCompleteButton.isSelected = todo.isComplete
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            todos.remove(at: todos.firstIndex(of: currentTodos[indexPath.row])!)
            currentTodos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(todos)
        }   
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        if (editing) {
            self.editButtonItem.title = "Завершить"
        } else {
            self.editButtonItem.title = "Изменить"
        }
    }

}
