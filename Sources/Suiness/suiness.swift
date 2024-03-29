// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!
import Foundation

// Depending on the consumer's build setup, the low-level FFI code
// might be in a separate module, or it might be compiled inline into
// this module. This is a bit of light hackery to work with both.
#if canImport(suinessFFI)
import suinessFFI
#endif

fileprivate extension RustBuffer {
    // Allocate a new buffer, copying the contents of a `UInt8` array.
    init(bytes: [UInt8]) {
        let rbuf = bytes.withUnsafeBufferPointer { ptr in
            RustBuffer.from(ptr)
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    static func from(_ ptr: UnsafeBufferPointer<UInt8>) -> RustBuffer {
        try! rustCall { ffi_suiness_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_suiness_rustbuffer_free(self, $0) }
    }
}

fileprivate extension ForeignBytes {
    init(bufferPointer: UnsafeBufferPointer<UInt8>) {
        self.init(len: Int32(bufferPointer.count), data: bufferPointer.baseAddress)
    }
}

// For every type used in the interface, we provide helper methods for conveniently
// lifting and lowering that type from C-compatible data, and for reading and writing
// values of that type in a buffer.

// Helper classes/extensions that don't change.
// Someday, this will be in a library of its own.

fileprivate extension Data {
    init(rustBuffer: RustBuffer) {
        // TODO: This copies the buffer. Can we read directly from a
        // Rust buffer?
        self.init(bytes: rustBuffer.data!, count: Int(rustBuffer.len))
    }
}

// Define reader functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.
//
// With external types, one swift source file needs to be able to call the read
// method on another source file's FfiConverter, but then what visibility
// should Reader have?
// - If Reader is fileprivate, then this means the read() must also
//   be fileprivate, which doesn't work with external types.
// - If Reader is internal/public, we'll get compile errors since both source
//   files will try define the same type.
//
// Instead, the read() method and these helper functions input a tuple of data

fileprivate func createReader(data: Data) -> (data: Data, offset: Data.Index) {
    (data: data, offset: 0)
}

// Reads an integer at the current offset, in big-endian order, and advances
// the offset on success. Throws if reading the integer would move the
// offset past the end of the buffer.
fileprivate func readInt<T: FixedWidthInteger>(_ reader: inout (data: Data, offset: Data.Index)) throws -> T {
    let range = reader.offset..<reader.offset + MemoryLayout<T>.size
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    if T.self == UInt8.self {
        let value = reader.data[reader.offset]
        reader.offset += 1
        return value as! T
    }
    var value: T = 0
    let _ = withUnsafeMutableBytes(of: &value, { reader.data.copyBytes(to: $0, from: range)})
    reader.offset = range.upperBound
    return value.bigEndian
}

// Reads an arbitrary number of bytes, to be used to read
// raw bytes, this is useful when lifting strings
fileprivate func readBytes(_ reader: inout (data: Data, offset: Data.Index), count: Int) throws -> Array<UInt8> {
    let range = reader.offset..<(reader.offset+count)
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    var value = [UInt8](repeating: 0, count: count)
    value.withUnsafeMutableBufferPointer({ buffer in
        reader.data.copyBytes(to: buffer, from: range)
    })
    reader.offset = range.upperBound
    return value
}

// Reads a float at the current offset.
fileprivate func readFloat(_ reader: inout (data: Data, offset: Data.Index)) throws -> Float {
    return Float(bitPattern: try readInt(&reader))
}

// Reads a float at the current offset.
fileprivate func readDouble(_ reader: inout (data: Data, offset: Data.Index)) throws -> Double {
    return Double(bitPattern: try readInt(&reader))
}

// Indicates if the offset has reached the end of the buffer.
fileprivate func hasRemaining(_ reader: (data: Data, offset: Data.Index)) -> Bool {
    return reader.offset < reader.data.count
}

// Define writer functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.  See the above discussion on Readers for details.

fileprivate func createWriter() -> [UInt8] {
    return []
}

fileprivate func writeBytes<S>(_ writer: inout [UInt8], _ byteArr: S) where S: Sequence, S.Element == UInt8 {
    writer.append(contentsOf: byteArr)
}

// Writes an integer in big-endian order.
//
// Warning: make sure what you are trying to write
// is in the correct type!
fileprivate func writeInt<T: FixedWidthInteger>(_ writer: inout [UInt8], _ value: T) {
    var value = value.bigEndian
    withUnsafeBytes(of: &value) { writer.append(contentsOf: $0) }
}

fileprivate func writeFloat(_ writer: inout [UInt8], _ value: Float) {
    writeInt(&writer, value.bitPattern)
}

fileprivate func writeDouble(_ writer: inout [UInt8], _ value: Double) {
    writeInt(&writer, value.bitPattern)
}

// Protocol for types that transfer other types across the FFI. This is
// analogous go the Rust trait of the same name.
fileprivate protocol FfiConverter {
    associatedtype FfiType
    associatedtype SwiftType

    static func lift(_ value: FfiType) throws -> SwiftType
    static func lower(_ value: SwiftType) -> FfiType
    static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType
    static func write(_ value: SwiftType, into buf: inout [UInt8])
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
fileprivate protocol FfiConverterPrimitive: FfiConverter where FfiType == SwiftType { }

extension FfiConverterPrimitive {
    public static func lift(_ value: FfiType) throws -> SwiftType {
        return value
    }

    public static func lower(_ value: SwiftType) -> FfiType {
        return value
    }
}

// Types conforming to `FfiConverterRustBuffer` lift and lower into a `RustBuffer`.
// Used for complex types where it's hard to write a custom lift/lower.
fileprivate protocol FfiConverterRustBuffer: FfiConverter where FfiType == RustBuffer {}

extension FfiConverterRustBuffer {
    public static func lift(_ buf: RustBuffer) throws -> SwiftType {
        var reader = createReader(data: Data(rustBuffer: buf))
        let value = try read(from: &reader)
        if hasRemaining(reader) {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    public static func lower(_ value: SwiftType) -> RustBuffer {
          var writer = createWriter()
          write(value, into: &writer)
          return RustBuffer(bytes: writer)
    }
}
// An error type for FFI errors. These errors occur at the UniFFI level, not
// the library level.
fileprivate enum UniffiInternalError: LocalizedError {
    case bufferOverflow
    case incompleteData
    case unexpectedOptionalTag
    case unexpectedEnumCase
    case unexpectedNullPointer
    case unexpectedRustCallStatusCode
    case unexpectedRustCallError
    case unexpectedStaleHandle
    case rustPanic(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .bufferOverflow: return "Reading the requested value would read past the end of the buffer"
        case .incompleteData: return "The buffer still has data after lifting its containing value"
        case .unexpectedOptionalTag: return "Unexpected optional tag; should be 0 or 1"
        case .unexpectedEnumCase: return "Raw enum value doesn't match any cases"
        case .unexpectedNullPointer: return "Raw pointer value was null"
        case .unexpectedRustCallStatusCode: return "Unexpected RustCallStatus code"
        case .unexpectedRustCallError: return "CALL_ERROR but no errorClass specified"
        case .unexpectedStaleHandle: return "The object in the handle map has been dropped already"
        case let .rustPanic(message): return message
        }
    }
}

fileprivate let CALL_SUCCESS: Int8 = 0
fileprivate let CALL_ERROR: Int8 = 1
fileprivate let CALL_PANIC: Int8 = 2
fileprivate let CALL_CANCELLED: Int8 = 3

fileprivate extension RustCallStatus {
    init() {
        self.init(
            code: CALL_SUCCESS,
            errorBuf: RustBuffer.init(
                capacity: 0,
                len: 0,
                data: nil
            )
        )
    }
}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: nil)
}

private func rustCallWithError<T>(
    _ errorHandler: @escaping (RustBuffer) throws -> Error,
    _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: errorHandler)
}

private func makeRustCall<T>(
    _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T,
    errorHandler: ((RustBuffer) throws -> Error)?
) throws -> T {
    uniffiEnsureInitialized()
    var callStatus = RustCallStatus.init()
    let returnedVal = callback(&callStatus)
    try uniffiCheckCallStatus(callStatus: callStatus, errorHandler: errorHandler)
    return returnedVal
}

private func uniffiCheckCallStatus(
    callStatus: RustCallStatus,
    errorHandler: ((RustBuffer) throws -> Error)?
) throws {
    switch callStatus.code {
        case CALL_SUCCESS:
            return

        case CALL_ERROR:
            if let errorHandler = errorHandler {
                throw try errorHandler(callStatus.errorBuf)
            } else {
                callStatus.errorBuf.deallocate()
                throw UniffiInternalError.unexpectedRustCallError
            }

        case CALL_PANIC:
            // When the rust code sees a panic, it tries to construct a RustBuffer
            // with the message.  But if that code panics, then it just sends back
            // an empty buffer.
            if callStatus.errorBuf.len > 0 {
                throw UniffiInternalError.rustPanic(try FfiConverterString.lift(callStatus.errorBuf))
            } else {
                callStatus.errorBuf.deallocate()
                throw UniffiInternalError.rustPanic("Rust panic")
            }

        case CALL_CANCELLED:
                throw CancellationError()

        default:
            throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

// Public interface members begin here.


fileprivate struct FfiConverterUInt64: FfiConverterPrimitive {
    typealias FfiType = UInt64
    typealias SwiftType = UInt64

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> UInt64 {
        return try lift(readInt(&buf))
    }

    public static func write(_ value: SwiftType, into buf: inout [UInt8]) {
        writeInt(&buf, lower(value))
    }
}

fileprivate struct FfiConverterString: FfiConverter {
    typealias SwiftType = String
    typealias FfiType = RustBuffer

    public static func lift(_ value: RustBuffer) throws -> String {
        defer {
            value.deallocate()
        }
        if value.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: value.data!, count: Int(value.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    public static func lower(_ value: String) -> RustBuffer {
        return value.utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                return RustBuffer.from(buf)
            }
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> String {
        let len: Int32 = try readInt(&buf)
        return String(bytes: try readBytes(&buf, count: Int(len)), encoding: String.Encoding.utf8)!
    }

    public static func write(_ value: String, into buf: inout [UInt8]) {
        let len = Int32(value.utf8.count)
        writeInt(&buf, len)
        writeBytes(&buf, value.utf8)
    }
}

fileprivate struct FfiConverterData: FfiConverterRustBuffer {
    typealias SwiftType = Data

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> Data {
        let len: Int32 = try readInt(&buf)
        return Data(try readBytes(&buf, count: Int(len)))
    }

    public static func write(_ value: Data, into buf: inout [UInt8]) {
        let len = Int32(value.count)
        writeInt(&buf, len)
        writeBytes(&buf, value)
    }
}


public struct KeyDetails {
    public var address: String
    public var sk: String
    public var phrase: String

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(address: String, sk: String, phrase: String) {
        self.address = address
        self.sk = sk
        self.phrase = phrase
    }
}


extension KeyDetails: Equatable, Hashable {
    public static func ==(lhs: KeyDetails, rhs: KeyDetails) -> Bool {
        if lhs.address != rhs.address {
            return false
        }
        if lhs.sk != rhs.sk {
            return false
        }
        if lhs.phrase != rhs.phrase {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
        hasher.combine(sk)
        hasher.combine(phrase)
    }
}


public struct FfiConverterTypeKeyDetails: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> KeyDetails {
        return try KeyDetails(
            address: FfiConverterString.read(from: &buf), 
            sk: FfiConverterString.read(from: &buf), 
            phrase: FfiConverterString.read(from: &buf)
        )
    }

    public static func write(_ value: KeyDetails, into buf: inout [UInt8]) {
        FfiConverterString.write(value.address, into: &buf)
        FfiConverterString.write(value.sk, into: &buf)
        FfiConverterString.write(value.phrase, into: &buf)
    }
}


public func FfiConverterTypeKeyDetails_lift(_ buf: RustBuffer) throws -> KeyDetails {
    return try FfiConverterTypeKeyDetails.lift(buf)
}

public func FfiConverterTypeKeyDetails_lower(_ value: KeyDetails) -> RustBuffer {
    return FfiConverterTypeKeyDetails.lower(value)
}

// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.
public enum OidcProvider {
    
    case google
    case facebook
    case apple
    case kakao
    case slack
    case twitch
}

public struct FfiConverterTypeOIDCProvider: FfiConverterRustBuffer {
    typealias SwiftType = OidcProvider

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> OidcProvider {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        
        case 1: return .google
        
        case 2: return .facebook
        
        case 3: return .apple
        
        case 4: return .kakao
        
        case 5: return .slack
        
        case 6: return .twitch
        
        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: OidcProvider, into buf: inout [UInt8]) {
        switch value {
        
        
        case .google:
            writeInt(&buf, Int32(1))
        
        
        case .facebook:
            writeInt(&buf, Int32(2))
        
        
        case .apple:
            writeInt(&buf, Int32(3))
        
        
        case .kakao:
            writeInt(&buf, Int32(4))
        
        
        case .slack:
            writeInt(&buf, Int32(5))
        
        
        case .twitch:
            writeInt(&buf, Int32(6))
        
        }
    }
}


public func FfiConverterTypeOIDCProvider_lift(_ buf: RustBuffer) throws -> OidcProvider {
    return try FfiConverterTypeOIDCProvider.lift(buf)
}

public func FfiConverterTypeOIDCProvider_lower(_ value: OidcProvider) -> RustBuffer {
    return FfiConverterTypeOIDCProvider.lower(value)
}


extension OidcProvider: Equatable, Hashable {}



public enum SuiError {

    
    
    // Simple error enums only carry a message
    case UnsupportedFeatureError(message: String)
    
    // Simple error enums only carry a message
    case SignatureKeyGenError(message: String)
    
    // Simple error enums only carry a message
    case InvalidAddress(message: String)
    
    // Simple error enums only carry a message
    case KeyConversionError(message: String)
    
    // Simple error enums only carry a message
    case InvalidSignature(message: String)
    
    // Simple error enums only carry a message
    case InvalidSecreteKey(message: String)
    
    // Simple error enums only carry a message
    case JwtParseValidationError(message: String)
    
    // Simple error enums only carry a message
    case SeedAddressGenError(message: String)
    
    // Simple error enums only carry a message
    case ZkLoginAddressGenError(message: String)
    
    // Simple error enums only carry a message
    case AddressByteParseError(message: String)
    
    // Simple error enums only carry a message
    case InvalidPublicKey(message: String)
    
    // Simple error enums only carry a message
    case NonceGenerationFailed(message: String)
    
    // Simple error enums only carry a message
    case InvalidB64Encoding(message: String)
    
    // Simple error enums only carry a message
    case InvalidHexEncoding(message: String)
    
    // Simple error enums only carry a message
    case KeyDerivationFailed(message: String)
    
    // Simple error enums only carry a message
    case WordlistError(message: String)
    
    // Simple error enums only carry a message
    case InvalidWordlist(message: String)
    
    // Simple error enums only carry a message
    case MalformedInput(message: String)
    
    // Simple error enums only carry a message
    case ZkLoginInputsError(message: String)
    
    // Simple error enums only carry a message
    case BcsError(message: String)
    

    fileprivate static func uniffiErrorHandler(_ error: RustBuffer) throws -> Error {
        return try FfiConverterTypeSuiError.lift(error)
    }
}


public struct FfiConverterTypeSuiError: FfiConverterRustBuffer {
    typealias SwiftType = SuiError

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SuiError {
        let variant: Int32 = try readInt(&buf)
        switch variant {

        

        
        case 1: return .UnsupportedFeatureError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 2: return .SignatureKeyGenError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 3: return .InvalidAddress(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 4: return .KeyConversionError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 5: return .InvalidSignature(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 6: return .InvalidSecreteKey(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 7: return .JwtParseValidationError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 8: return .SeedAddressGenError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 9: return .ZkLoginAddressGenError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 10: return .AddressByteParseError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 11: return .InvalidPublicKey(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 12: return .NonceGenerationFailed(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 13: return .InvalidB64Encoding(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 14: return .InvalidHexEncoding(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 15: return .KeyDerivationFailed(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 16: return .WordlistError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 17: return .InvalidWordlist(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 18: return .MalformedInput(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 19: return .ZkLoginInputsError(
            message: try FfiConverterString.read(from: &buf)
        )
        
        case 20: return .BcsError(
            message: try FfiConverterString.read(from: &buf)
        )
        

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: SuiError, into buf: inout [UInt8]) {
        switch value {

        

        
        case .UnsupportedFeatureError(_ /* message is ignored*/):
            writeInt(&buf, Int32(1))
        case .SignatureKeyGenError(_ /* message is ignored*/):
            writeInt(&buf, Int32(2))
        case .InvalidAddress(_ /* message is ignored*/):
            writeInt(&buf, Int32(3))
        case .KeyConversionError(_ /* message is ignored*/):
            writeInt(&buf, Int32(4))
        case .InvalidSignature(_ /* message is ignored*/):
            writeInt(&buf, Int32(5))
        case .InvalidSecreteKey(_ /* message is ignored*/):
            writeInt(&buf, Int32(6))
        case .JwtParseValidationError(_ /* message is ignored*/):
            writeInt(&buf, Int32(7))
        case .SeedAddressGenError(_ /* message is ignored*/):
            writeInt(&buf, Int32(8))
        case .ZkLoginAddressGenError(_ /* message is ignored*/):
            writeInt(&buf, Int32(9))
        case .AddressByteParseError(_ /* message is ignored*/):
            writeInt(&buf, Int32(10))
        case .InvalidPublicKey(_ /* message is ignored*/):
            writeInt(&buf, Int32(11))
        case .NonceGenerationFailed(_ /* message is ignored*/):
            writeInt(&buf, Int32(12))
        case .InvalidB64Encoding(_ /* message is ignored*/):
            writeInt(&buf, Int32(13))
        case .InvalidHexEncoding(_ /* message is ignored*/):
            writeInt(&buf, Int32(14))
        case .KeyDerivationFailed(_ /* message is ignored*/):
            writeInt(&buf, Int32(15))
        case .WordlistError(_ /* message is ignored*/):
            writeInt(&buf, Int32(16))
        case .InvalidWordlist(_ /* message is ignored*/):
            writeInt(&buf, Int32(17))
        case .MalformedInput(_ /* message is ignored*/):
            writeInt(&buf, Int32(18))
        case .ZkLoginInputsError(_ /* message is ignored*/):
            writeInt(&buf, Int32(19))
        case .BcsError(_ /* message is ignored*/):
            writeInt(&buf, Int32(20))

        
        }
    }
}


extension SuiError: Equatable, Hashable {}

extension SuiError: Error { }

public func decodeBase64(data: String) throws -> Data {
    return try  FfiConverterData.lift(
        try rustCallWithError(FfiConverterTypeSuiError.lift) {
    uniffi_suiness_fn_func_decode_base64(
        FfiConverterString.lower(data),$0)
}
    )
}

public func decodeHex(data: String) throws -> Data {
    return try  FfiConverterData.lift(
        try rustCallWithError(FfiConverterTypeSuiError.lift) {
    uniffi_suiness_fn_func_decode_hex(
        FfiConverterString.lower(data),$0)
}
    )
}

public func deriveNewKey(keyScheme: String = "ED25519", derivationPath: String = "", wordLength: String = "12") throws -> KeyDetails {
    return try  FfiConverterTypeKeyDetails.lift(
        try rustCallWithError(FfiConverterTypeSuiError.lift) {
    uniffi_suiness_fn_func_derive_new_key(
        FfiConverterString.lower(keyScheme),
        FfiConverterString.lower(derivationPath),
        FfiConverterString.lower(wordLength),$0)
}
    )
}

public func encodeBase64(data: Data)  -> String {
    return try!  FfiConverterString.lift(
        try! rustCall() {
    uniffi_suiness_fn_func_encode_base64(
        FfiConverterData.lower(data),$0)
}
    )
}

public func encodeHex(data: Data)  -> String {
    return try!  FfiConverterString.lift(
        try! rustCall() {
    uniffi_suiness_fn_func_encode_hex(
        FfiConverterData.lower(data),$0)
}
    )
}

public func genAddressSeed(salt: String, name: String, value: String, aud: String) throws -> String {
    return try  FfiConverterString.lift(
        try rustCallWithError(FfiConverterTypeSuiError.lift) {
    uniffi_suiness_fn_func_gen_address_seed(
        FfiConverterString.lower(salt),
        FfiConverterString.lower(name),
        FfiConverterString.lower(value),
        FfiConverterString.lower(aud),$0)
}
    )
}

public func generateNonce(sk: String, maxEpoch: UInt64, randomness: String) throws -> String {
    return try  FfiConverterString.lift(
        try rustCallWithError(FfiConverterTypeSuiError.lift) {
    uniffi_suiness_fn_func_generate_nonce(
        FfiConverterString.lower(sk),
        FfiConverterUInt64.lower(maxEpoch),
        FfiConverterString.lower(randomness),$0)
}
    )
}

public func generateRandomness()  -> String {
    return try!  FfiConverterString.lift(
        try! rustCall() {
    uniffi_suiness_fn_func_generate_randomness($0)
}
    )
}

public func generateZkLoginAddress(provider: OidcProvider, jwt: String, salt: String) throws -> String {
    return try  FfiConverterString.lift(
        try rustCallWithError(FfiConverterTypeSuiError.lift) {
    uniffi_suiness_fn_func_generate_zk_login_address(
        FfiConverterTypeOIDCProvider.lower(provider),
        FfiConverterString.lower(jwt),
        FfiConverterString.lower(salt),$0)
}
    )
}

public func getExtendedEphemeralPublicKey(sk: String) throws -> String {
    return try  FfiConverterString.lift(
        try rustCallWithError(FfiConverterTypeSuiError.lift) {
    uniffi_suiness_fn_func_get_extended_ephemeral_public_key(
        FfiConverterString.lower(sk),$0)
}
    )
}

public func getZkLoginSig(value: String, addressSeed: String, maxEpoch: UInt64, userSig: String) throws -> String {
    return try  FfiConverterString.lift(
        try rustCallWithError(FfiConverterTypeSuiError.lift) {
    uniffi_suiness_fn_func_get_zk_login_sig(
        FfiConverterString.lower(value),
        FfiConverterString.lower(addressSeed),
        FfiConverterUInt64.lower(maxEpoch),
        FfiConverterString.lower(userSig),$0)
}
    )
}

private enum InitializationResult {
    case ok
    case contractVersionMismatch
    case apiChecksumMismatch
}
// Use a global variables to perform the versioning checks. Swift ensures that
// the code inside is only computed once.
private var initializationResult: InitializationResult {
    // Get the bindings contract version from our ComponentInterface
    let bindings_contract_version = 24
    // Get the scaffolding contract version by calling the into the dylib
    let scaffolding_contract_version = ffi_suiness_uniffi_contract_version()
    if bindings_contract_version != scaffolding_contract_version {
        return InitializationResult.contractVersionMismatch
    }
    if (uniffi_suiness_checksum_func_decode_base64() != 50529) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_decode_hex() != 38968) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_derive_new_key() != 6820) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_encode_base64() != 22846) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_encode_hex() != 12627) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_gen_address_seed() != 17526) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_generate_nonce() != 10366) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_generate_randomness() != 2431) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_generate_zk_login_address() != 24070) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_get_extended_ephemeral_public_key() != 22990) {
        return InitializationResult.apiChecksumMismatch
    }
    if (uniffi_suiness_checksum_func_get_zk_login_sig() != 18901) {
        return InitializationResult.apiChecksumMismatch
    }

    return InitializationResult.ok
}

private func uniffiEnsureInitialized() {
    switch initializationResult {
    case .ok:
        break
    case .contractVersionMismatch:
        fatalError("UniFFI contract version mismatch: try cleaning and rebuilding your project")
    case .apiChecksumMismatch:
        fatalError("UniFFI API checksum mismatch: try cleaning and rebuilding your project")
    }
}