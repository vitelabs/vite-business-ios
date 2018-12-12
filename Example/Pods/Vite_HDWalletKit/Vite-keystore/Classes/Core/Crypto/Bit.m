//
//  Bit.m
//  Vite-keystore
//
//  Created by Water on 2018/9/20.
//

#import "Bit.h"
#import <CommonCrypto/CommonCrypto.h>

static inline void BTCMnemonicSetBit(uint8_t* buf, int bitIndex) {
    int value = ((int) buf[bitIndex / 8]) & 0xFF;
    value = value | (1 << (7 - (bitIndex % 8)));
    buf[bitIndex / 8] = (uint8_t) value;
}

static inline void BTCMnemonicIntegerTo11Bits(uint8_t* buf, int bitIndex, int integer) {
    for (int i = 0; i < 11; i++) {
        if ((integer & 0x400) == 0x400) {
            BTCMnemonicSetBit(buf, bitIndex + i);
        }
        integer = integer << 1;
    }
}

// This is designed to be not optimized out by compiler like memset
void *BTCSecureMemset(void *v, unsigned char c, size_t n) {
    if (!v) return v;
    volatile unsigned char *p = v;
    while (n--)
        *p++ = c;

    return v;
}

NSMutableData* BTCSHA256(NSData* data) {
    if (!data) return nil;
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];

    __block CC_SHA256_CTX ctx;
    CC_SHA256_Init(&ctx);
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        CC_SHA256_Update(&ctx, bytes, (CC_LONG)byteRange.length);
    }];
    CC_SHA256_Final(digest, &ctx);

    NSMutableData* result = [NSMutableData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    BTCSecureMemset(digest, 0, CC_SHA256_DIGEST_LENGTH);
    return result;
}


@implementation Bit

+ (NSData*) entropyFromWords:(NSArray*)words wordLists:(NSArray *)wordList {
    if (!words) return nil;

    //Vite only support 12 or 24 words
    //    words.count != 15 &&
    //    words.count != 18 &&
    //    words.count != 21 &&
    if (words.count == 12 || words.count == 24) {
        // Words count should be between 12 and 24 and be divisible by 13.
        int bitLength = (int)words.count * 11;

        NSMutableData* buf = [NSMutableData dataWithLength:bitLength / 8 + ((bitLength % 8) > 0 ? 1 : 0)];

        for (int i = 0; i < words.count; i++) {
            NSString* word = words[i];
            NSUInteger wordIndex = [wordList indexOfObject:word];

            if (wordIndex == NSNotFound) {
                return nil;
            }

            BTCMnemonicIntegerTo11Bits((uint8_t*)buf.mutableBytes, i * 11, (int)wordIndex);
        }

        NSData* entropy = [buf subdataWithRange:NSMakeRange(0, buf.length - 1)];

        // Calculate the checksum
        NSUInteger checksumLength = bitLength / 32;
        NSData* checksumHash = BTCSHA256(entropy);
        uint8_t checksumByte = (uint8_t) (((0xFF << (8 - checksumLength)) & 0xFF) & (0xFF & ((int) ((uint8_t*)checksumHash.bytes)[0] )));

        uint8_t lastByte = ((uint8_t*)buf.bytes)[buf.length - 1];

        // Verify the checksum
        if (lastByte != checksumByte) {
            return nil;
        }

        return entropy;
    }else{
        return nil;
    }
}

@end
