#include <stddef.h>
#include <stdlib.h>

#ifndef max
#define max(x, y) ((x) > (y) ? (x) : (y))
#endif

#define array_header(array) \
    ((Array_Header *)(array ? (char *)array - sizeof(Array_Header) : NULL))

#define array_capacity(array) (array ? array_header(array)->capacity : 0)

#define array_length(array) (array ? array_header(array)->length : 0)

#define increase_array_length(array, amount) \
    (array_length(array) + (amount) > array_capacity(array) ? \
     set_array_length(array, array_length(array) + (amount)) : \
     (array_header(array)->length++, array))

#define set_array_length(array, length) \
    array = set_array(array, (length), sizeof(*array))

#define add_array_element(array, element) \
    (increase_array_length(array, 1), \
     array[array_length(array) - 1] = (element))

#define delete_array(array) \
    (array ? free(array_header(array)), array = NULL : 0)

typedef struct {
    size_t capacity;
    size_t length;
} Array_Header;

static inline void *set_array(const void *array, size_t length, size_t element_size) {
    size_t capacity = max(1 + 2 * array_capacity(array), length);
    size_t size = sizeof(Array_Header) + capacity * element_size;
    Array_Header *header;
    if (array)
        header = (Array_Header *)realloc(array_header(array), size);
    else {
        header = (Array_Header *)malloc(size);
    }
    header->capacity = capacity;
    header->length = length;
    return header + 1;
}
