import ReactiveCocoa
import ReactiveSwift
import Delta

extension MutableProperty: Delta.ObservablePropertyType {
    public typealias ValueType = Value
}
