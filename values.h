#ifndef VALUES_H
#define VALUES_H

#include <stdbool.h>
#include <stddef.h>


// These are defined so they can be configured
typedef double longest_float;
typedef long long longest_int;


typedef struct Type;

typedef struct {
} Void_Type;

typedef struct {
} Bool_Type;

typedef struct {
    unsigned long size_in_bits;
    bool is_unsigned;
} Int_Type;

typedef struct {
} Str_Type;

typedef struct {
    Type *value_type;
} Ref_Type;

typedef struct {
    Type *value_type;
} Ptr_Type;

typedef struct {
    Type *element_type;
    size_t number_of_elements;
} Array_Type;

typedef struct {
    const char *name;
    Type *type;
    size_t offset_in_bytes;
    bool is_mixin;
} Struct_Item_Type;

typedef struct {
    const char *name;
    Struct_Item_Type *item_types;
} Struct_Type;

typedef struct
{
    Type *return_type;
    Type *parameter_types;
} Func_Type;

typedef struct {
} Dict_Type;

struct Type {
    enum {
        VOID_TYPE,
        BOOL_TYPE,
        INT_TYPE,
        STR_TYPE,
        TYPE,
        REF_TYPE,
        PTR_TYPE,
        ARRAY_TYPE,
        STRUCT_TYPE,
        FUNC_TYPE,
        DICT_TYPE
    } tag;
    union {
        Void_Type as_void_type;
        Bool_Type as_bool_type;
        Int_Type as_int_type;
        Str_Type as_str_type;
        Ref_Type as_ref_type;
        Ptr_Type as_ptr_type;
        Array_Type as_array_type;
        Struct_Type as_struct_type;
        Func_Type as_func_type;
        Dict_Type as_dict_type;
    };
};

typedef union Value Value;
typedef struct Typed_Value Typed_Value;

typedef struct {
    Typed_Value value;
    struct {
        Value value;
        Type *type;
        int next;               // offset of next definition in dictionary
    } key;
} Def;

typedef struct {
    Typed_Value *array_values;  // array part of dict
    Def *defs;
} Dict;

union Value {
    // void as_void;
    bool as_bool;
    longest_float as_float;
    longest_int as_int;
    const char *as_str;
    Type *as_type;
    void *as_ref;
    void *as_ptr;
    void *as_array;
    void *as_struct;
    void *as_func;
    Dict *as_dict;
};

struct Typed_Value {
    Value value;
    Type *type;
};


#endif