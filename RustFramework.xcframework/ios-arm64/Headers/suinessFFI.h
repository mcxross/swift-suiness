// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// The following structs are used to implement the lowest level
// of the FFI, and thus useful to multiple uniffied crates.
// We ensure they are declared exactly once, with a header guard, UNIFFI_SHARED_H.
#ifdef UNIFFI_SHARED_H
    // We also try to prevent mixing versions of shared uniffi header structs.
    // If you add anything to the #else block, you must increment the version suffix in UNIFFI_SHARED_HEADER_V4
    #ifndef UNIFFI_SHARED_HEADER_V4
        #error Combining helper code from multiple versions of uniffi is not supported
    #endif // ndef UNIFFI_SHARED_HEADER_V4
#else
#define UNIFFI_SHARED_H
#define UNIFFI_SHARED_HEADER_V4
// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V4 in this file.           ⚠️

typedef struct RustBuffer
{
    int32_t capacity;
    int32_t len;
    uint8_t *_Nullable data;
} RustBuffer;

typedef int32_t (*ForeignCallback)(uint64_t, int32_t, const uint8_t *_Nonnull, int32_t, RustBuffer *_Nonnull);

// Task defined in Rust that Swift executes
typedef void (*UniFfiRustTaskCallback)(const void * _Nullable, int8_t);

// Callback to execute Rust tasks using a Swift Task
//
// Args:
//   executor: ForeignExecutor lowered into a size_t value
//   delay: Delay in MS
//   task: UniFfiRustTaskCallback to call
//   task_data: data to pass the task callback
typedef int8_t (*UniFfiForeignExecutorCallback)(size_t, uint32_t, UniFfiRustTaskCallback _Nullable, const void * _Nullable);

typedef struct ForeignBytes
{
    int32_t len;
    const uint8_t *_Nullable data;
} ForeignBytes;

// Error definitions
typedef struct RustCallStatus {
    int8_t code;
    RustBuffer errorBuf;
} RustCallStatus;

// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V4 in this file.           ⚠️
#endif // def UNIFFI_SHARED_H

// Continuation callback for UniFFI Futures
typedef void (*UniFfiRustFutureContinuation)(void * _Nonnull, int8_t);

// Scaffolding functions
RustBuffer uniffi_suiness_fn_func_decode_base64(RustBuffer data, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_suiness_fn_func_decode_hex(RustBuffer data, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_suiness_fn_func_derive_new_key(RustBuffer key_scheme, RustBuffer derivation_path, RustBuffer word_length, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_suiness_fn_func_encode_base64(RustBuffer data, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_suiness_fn_func_encode_hex(RustBuffer data, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_suiness_fn_func_generate_nonce(RustBuffer pk, uint64_t max_epoch, RustBuffer randomness, RustCallStatus *_Nonnull out_status
);
RustBuffer uniffi_suiness_fn_func_generate_randomness(RustCallStatus *_Nonnull out_status
    
);
RustBuffer uniffi_suiness_fn_func_generate_zk_login_address(RustBuffer provider, RustBuffer jwt, RustBuffer salt, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_suiness_rustbuffer_alloc(int32_t size, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_suiness_rustbuffer_from_bytes(ForeignBytes bytes, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rustbuffer_free(RustBuffer buf, RustCallStatus *_Nonnull out_status
);
RustBuffer ffi_suiness_rustbuffer_reserve(RustBuffer buf, int32_t additional, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_continuation_callback_set(UniFfiRustFutureContinuation _Nonnull callback
);
void ffi_suiness_rust_future_poll_u8(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_u8(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_u8(void* _Nonnull handle
);
uint8_t ffi_suiness_rust_future_complete_u8(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_i8(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_i8(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_i8(void* _Nonnull handle
);
int8_t ffi_suiness_rust_future_complete_i8(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_u16(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_u16(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_u16(void* _Nonnull handle
);
uint16_t ffi_suiness_rust_future_complete_u16(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_i16(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_i16(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_i16(void* _Nonnull handle
);
int16_t ffi_suiness_rust_future_complete_i16(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_u32(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_u32(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_u32(void* _Nonnull handle
);
uint32_t ffi_suiness_rust_future_complete_u32(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_i32(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_i32(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_i32(void* _Nonnull handle
);
int32_t ffi_suiness_rust_future_complete_i32(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_u64(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_u64(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_u64(void* _Nonnull handle
);
uint64_t ffi_suiness_rust_future_complete_u64(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_i64(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_i64(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_i64(void* _Nonnull handle
);
int64_t ffi_suiness_rust_future_complete_i64(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_f32(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_f32(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_f32(void* _Nonnull handle
);
float ffi_suiness_rust_future_complete_f32(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_f64(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_f64(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_f64(void* _Nonnull handle
);
double ffi_suiness_rust_future_complete_f64(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_pointer(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_pointer(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_pointer(void* _Nonnull handle
);
void*_Nonnull ffi_suiness_rust_future_complete_pointer(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_rust_buffer(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_rust_buffer(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_rust_buffer(void* _Nonnull handle
);
RustBuffer ffi_suiness_rust_future_complete_rust_buffer(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
void ffi_suiness_rust_future_poll_void(void* _Nonnull handle, void* _Nonnull uniffi_callback
);
void ffi_suiness_rust_future_cancel_void(void* _Nonnull handle
);
void ffi_suiness_rust_future_free_void(void* _Nonnull handle
);
void ffi_suiness_rust_future_complete_void(void* _Nonnull handle, RustCallStatus *_Nonnull out_status
);
uint16_t uniffi_suiness_checksum_func_decode_base64(void
    
);
uint16_t uniffi_suiness_checksum_func_decode_hex(void
    
);
uint16_t uniffi_suiness_checksum_func_derive_new_key(void
    
);
uint16_t uniffi_suiness_checksum_func_encode_base64(void
    
);
uint16_t uniffi_suiness_checksum_func_encode_hex(void
    
);
uint16_t uniffi_suiness_checksum_func_generate_nonce(void
    
);
uint16_t uniffi_suiness_checksum_func_generate_randomness(void
    
);
uint16_t uniffi_suiness_checksum_func_generate_zk_login_address(void
    
);
uint32_t ffi_suiness_uniffi_contract_version(void
    
);
