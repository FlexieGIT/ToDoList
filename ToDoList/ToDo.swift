//
//  ToDo.swift
//  ToDoList
//
//  Created by Алексей Красиков on 10.02.2021.
//

import Foundation

struct ToDo: Equatable, Codable{
    var id = UUID()
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    static let archiveURL = documentsDirectory?.appendingPathComponent("todos").appendingPathExtension("plist")
    
    static let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    static func ==(lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    static func loadToDos() -> [ToDo]? {
        guard let codedToDos = try? Data(contentsOf: archiveURL!) else {return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<ToDo>.self, from: codedToDos)
    }
    
    
    static func loadSampleToDos() -> [ToDo] {
        let todo1 = ToDo(title: "Первая задача", isComplete: false, dueDate: Date(), notes: "Примечание 1")
        let todo2 = ToDo(title: "Вторая задача", isComplete: false, dueDate: Date(), notes: "Примечание 2")
        let todo3 = ToDo(title: "Третья задача", isComplete: false, dueDate: Date(), notes: "Примечание 3")
        return [todo1, todo2, todo3]
    }
    
    static func saveToDos(_ todos: [ToDo]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedToDos = try? propertyListEncoder.encode(todos)
        try? codedToDos?.write(to: archiveURL!, options: .noFileProtection)
    }
}
