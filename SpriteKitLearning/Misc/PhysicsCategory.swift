
struct PhysicsCategory: OptionSet {
    let rawValue: UInt32

    static let none   = PhysicsCategory([])
    static let player = PhysicsCategory(rawValue: 1 << 1)
    static let enemy  = PhysicsCategory(rawValue: 1 << 2)
    static let wall  = PhysicsCategory(rawValue: 1 << 3)
    static let all    = PhysicsCategory(rawValue: UInt32.max)
    static let guide = PhysicsCategory(rawValue: 1 << 4)
}
