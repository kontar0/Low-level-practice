def main(pass_str): 
    if len(pass_str) < 5 or len(pass_str) > 32:
        return False
    for char in pass_str:
        if 0x30 <= ord(char) <= 0x76:
            continue
        else:
            return False
    fnv_hash = 0x811c9dc5
    salt = 0x9e3779b9
    simple_hash = 0xcbf29ce4
    index = 0
    for i in range(len(pass_str)):
        fnv_hash = (fnv_hash ^ ord(pass_str[i])) * 0x1000193
        fnv_hash = fnv_hash & 0xffffffff
        simple_hash = simple_hash + ((ord(pass_str[i]) * (i+1)) & 0xffffffff)
        simple_hash = simple_hash & 0xffffffff
        simple_hash = ((simple_hash * 0x80) & 0xffffffff) | simple_hash >> 0x19
        salt = ((ord(pass_str[i]) << (index & 0xf)) & 0xffffffff)  ^ salt
        salt = ((salt << 0xd ) & 0xffffffff)| salt >> 0x13
        index += 3
    fnv_hash = ((((fnv_hash ^ 0xdeadbeef) >> 0x10 ) & 0xffffffff) ^ fnv_hash ^ 0xdeadbeef) * 0x7feb352d
    fnv_hash = fnv_hash & 0xffffffff
    fnv_hash =  (fnv_hash ^ fnv_hash >> 0xf) * 0x846ca68b
    fnv_hash = fnv_hash & 0xffffffff
    fnv_hash = fnv_hash ^ fnv_hash >> 0x10;
    simple_hash = simple_hash ^ fnv_hash

    simple_hash = (simple_hash >> 0x10 ^ simple_hash) * 0x7feb352d;
    simple_hash = simple_hash & 0xffffffff
    simple_hash = (simple_hash ^ simple_hash >> 0xf) * 0x846ca68b;
    simple_hash = simple_hash & 0xffffffff
    simple_hash = simple_hash ^ simple_hash >> 0x10;
    salt = salt ^ simple_hash ^ 0xcafebabe;
    salt = (salt >> 0x10 ^ salt) * 0x7feb352d;
    salt = salt & 0xffffffff
    salt = (salt ^ salt >> 0xf) * 0x846ca68b;
    salt = salt & 0xffffffff
    salt = salt ^ salt >> 0x10;
    fnv_hash = fnv_hash ^ salt;
    print(f"{fnv_hash:08x}{simple_hash^fnv_hash:08x}{salt:08x}")
    return True
if (__name__ == "__main__"):
    main("hello")