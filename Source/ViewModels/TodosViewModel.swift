import Foundation
import ReactiveCocoa

struct TodosViewModel {
    let todos: [Todo]

    func todoForIndexPath(_ indexPath: IndexPath) -> Todo {
        return todos[indexPath.row]
    }
}
