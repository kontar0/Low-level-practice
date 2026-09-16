def rolling_hash(s):
    mask = 0xFFFFFFFF
    uVar5 = 0x811C9DC5
    uVar4 = 0

    for char in s:
        uVar5 = (
            ((uVar5 ^ (ord(char) & 0xFF)) * 0x01000193) & mask
        ) ^ uVar4
        uVar5 &= mask

        uVar4 = (uVar4 + 0x9E3779B9) & mask

    return uVar5 == 0x7DB85890
secret = [0xEA, 0x9E, 0xEF, 0x82, 0xE8, 0x88, 0xE8, 0x81, 0x99, 0xFE, 0x82, 0xE6]
res = ""
for i in range(12):
    key = (i + 172) & 0xFF
    res += ( chr(secret[i] ^ key))

res = "CM-" + "*" + res + "*"
print(res)
checksum = 0
for i in range(0, len(res), 2):
    checksum += ord(res[i])
checksum -= ord("*")
print("checksum:", checksum)
unfilled = 578 - checksum
chars = []
print("unfilled:",unfilled)

res = res[:16] + chr(unfilled)
print(res)
for i in range(48,58):
    res2 = res
    res2 = res2[:3] + chr(i) + res2[4:]
    if rolling_hash(res2): print(res2)
for i in range(65,91):
    res2 = res
    res2 = res2[:3] + chr(i) + res2[4:]
    if rolling_hash(res2): print(res2)

# just simple script for crackme