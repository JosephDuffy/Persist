import Foundation

public protocol PersistLogger {
    /**
     Log a message capturing information about things that might result in a failure.

     The system's default behavior is to store the default messages in memory buffers. When the
     memory buffers are full, the system compresses those buffers and moves them to the data store.
     They remain there until a storage quota is exceeded, at which point the system purges the
     oldest messages.
     */
    func `default`(_ message: StaticString, _ args: CVarArg...)

    /**
     Log a message capturing information that may be helpful, but isn’t essential, for
     troubleshooting errors.

     The system's default behavior is to store info messages in memory buffers. The system purges
     these messages when the memory buffers are full.

     When a piece of code logs an error or fault message, the info messages are also copied to the
     data store. They remain there until a storage quota is exceeded, at which point the system
     purges the oldest messages.
     */
    func info(_ message: StaticString, _ args: CVarArg...)

    /**
     Use this level to capture verbose information that may be useful during development or while
     troubleshooting a specific problem. Debug logging is intended for use in a development
     environment and not in shipping software.

     The system's default behavior is to discard debug messages; it only captures them when you
     enable debug logging using the tools or a custom configuration.
     */
    func debug(_ message: StaticString, _ args: CVarArg...)

    /**
     Use this level to capture information about process-level errors.

     The system always saves error messages in the data store. They remain there until a storage
     quota is exceeded, at which point the system purges the oldest messages.

     When you log an error message, the system saves other messages to the data store. If an
     activity object exists, the system captures information for the entire process chain related to
     that activity.
     */
    func error(_ message: StaticString, _ args: CVarArg...)

    /**
     Use this level only when you want to capture information about system-level or multi-process
     errors.

     The system always saves fault messages in the data store. They remain there until a storage
     quota is exceeded, at which point, the oldest messages are purged.

     When you log an fault message, the system saves other messages to the data store. If an
     activity object exists, the system captures information for the entire process chain related to
     that activity.
     */
    func fault(_ message: StaticString, _ args: CVarArg...)
}
