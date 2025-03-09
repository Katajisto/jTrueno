#import "Basic";

strlen :: (s: *u8) -> s64 {  // Return the length of s, a C-style zero-terminated string.
    count: s64 = 0;
    while <<s {
        count += 1;
        s += 1;
    }
    return count;
}

u8_to_string :: (ptr: *u8) -> string {
	str : string;
	str.data = ptr;
	str.count = strlen(ptr);
	return str;
}

hlo :: () {
	print("Hello!!!");
}
