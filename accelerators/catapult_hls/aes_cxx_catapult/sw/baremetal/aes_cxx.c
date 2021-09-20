/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#include <stdlib.h>

#include <fixed_point.h>
#include <math.h>

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef uint32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}

#define SLD_AES_CXX 0x089
#define DEV_NAME "sld,aes_cxx_catapult"

/* <<--params-->> */
static unsigned tag_bytes;
static unsigned aad_bytes;
static unsigned in_bytes;
static unsigned out_bytes;
static unsigned iv_bytes;
static unsigned key_bytes;
static unsigned encryption;
static unsigned oper_mode;

static unsigned key_words;
static unsigned iv_words;
static unsigned in_words;
static unsigned out_words;
static unsigned aad_words;
static unsigned tag_words;

static unsigned key_size;
static unsigned iv_size;
static unsigned in_size;
static unsigned out_size;
static unsigned aad_size;
static unsigned tag_size;

static unsigned mem_size;

const unsigned aes_key_size = 8;
const unsigned aes_iv_size = 4;
const unsigned aes_in_size = 40;
const unsigned aes_out_size = 40;
const unsigned aes_aad_size = 32;
const unsigned aes_tag_size = 4;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?        \
        (_sz / CHUNK_SIZE) :        \
        (_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define AES_CXX_OPER_MODE_REG 0x40
#define AES_CXX_ENCRYPTION_REG 0x44
#define AES_CXX_KEY_BYTES_REG 0x48
#define AES_CXX_INPUT_BYTES_REG 0x4C
#define AES_CXX_IV_BYTES_REG 0x50
#define AES_CXX_AAD_BYTES_REG 0x54
#define AES_CXX_TAG_BYTES_REG 0x58

/* Possible values of 'encryption' */
//#define ENCRYPTION_MODE 1
//#define DECRYPTION_MODE 2

/* Possible values of 'oper_mode' */
//#define AES_ECB_OPERATION_MODE 1
//#define AES_CTR_OPERATION_MODE 2
//#define AES_CBC_OPERATION_MODE 3
//#define GCM_OPERATION_MODE 4

#if !(defined(AES_ECB_OPERATION_MODE) || defined(AES_CTR_OPERATION_MODE) || defined(AES_CBC_OPERATION_MODE) || defined(GCM_OPERATION_MODE))
#error "AES mode is not defined!"
#error "Compilation flags: [-DAES_ECB_OPERATION_MODE=1 | -DAES_CTR_OPERATION_MODE=2 | -DAES_CBC_OPERATION_MODE=3 | -DGCM_OPERATION_MODE=4]"
#endif

#ifdef AES_ECB_OPERATION_MODE
/* aes32/tests/aesmmt/ECBMMT128.rsp */
#define N_TESTS 10

#define OPERATION_MODE AES_ECB_OPERATION_MODE

static unsigned ecb_raw_encrypt_count[N_TESTS] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

static unsigned ecb_raw_encrypt_key[N_TESTS][4] = {
    {0xedfdb257, 0xcb37cdf1, 0x82c5455b, 0x0c0efebb},
    {0x7723d87d, 0x773a8bbf, 0xe1ae5b08, 0x1235b566},
    {0x280afe06, 0x3216a10b, 0x9cad9b20, 0x95552b16},
    {0xef60fb14, 0x00c83936, 0x414a2565, 0x1eb51a1b},
    {0xc5805cd1, 0xc4a7b98a, 0x715badb7, 0x09720bf4},
    {0x4c35be02, 0x8e147527, 0x8346eae5, 0x31cbee5c},
    {0x00cc73c9, 0x90d376b8, 0x2246e45e, 0xa3ae2e37},
    {0x0a53aa7a, 0x3e4a4f36, 0x4e8c6c72, 0x24af5501},
    {0xb80bcc92, 0x9052cb54, 0x50479442, 0xe2b809ce},
    {0xebea9c6a, 0x82213a00, 0xac1d22fa, 0xea22116f}};
static unsigned ecb_raw_encrypt_key_bytes[N_TESTS] = {4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4};
static unsigned ecb_raw_encrypt_key_words[N_TESTS] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4};

static unsigned ecb_raw_encrypt_plaintext[N_TESTS][40] = {
    {0x1695fe47, 0x5421cace, 0x3557daca, 0x01f445ff},
    {0x1b0a69b7, 0xbc534c16, 0xcecffae0, 0x2cc53231, 0x90ceb413, 0xf1db3e9f, 0x0f79ba65, 0x4c54b60e},
    {0x6f172bb6, 0xec364833, 0x411841a8, 0xf9ea2051, 0x735d6005, 0x38a9ea5e, 0x8cd2431a, 0x432903c1, 0xd6178988, 0xb616ed76, 0xe00036c5, 0xb28ccd8b},
    {0x59355931, 0x8cc66bf6, 0x95e49feb, 0x42794bdf, 0xb66bce89, 0x5ec222ca, 0x2609b133, 0xecf66ac7, 0x344d1302, 0x1e01e11a, 0x969c4684, 0xcbe20aba, 0xe2b19d3c, 0xeb2cacd4, 0x1419f21f, 0x1c865149},
    {0x84f809fc, 0x5c846523, 0x76cc0df1, 0x0095bc00, 0xb9f0547f, 0xa91a2d33, 0x10a0adbc, 0x9cc6191a, 0xde2aaa6f, 0xffa5e406, 0xaf722395, 0x5f9277bf, 0xb06eb1dd, 0x2bbfbefe, 0x32ab342c, 0x36302bf2, 0x2bc64e1b, 0x394032bb, 0xb5f4e674, 0x4f1bcbf2},
    {0x7adcf4a4, 0x94f6b097, 0x90c82c8b, 0xb97db62c, 0x5d3fa403, 0x2f06dfec, 0xeaad9ecb, 0x374b747b, 0xd1c08d07, 0xe78e351d, 0xc2eb99bf, 0xa714d23c, 0xffe31f5f, 0xb5a472e6, 0xe0252f35, 0xa20c304c, 0x4f6d0cf7, 0xd29c9944, 0x4d40af3a, 0x00a92fc8, 0x6c6444fc, 0xb80ce976, 0x5362ac1b, 0xdba0b10e},
    {0x37a1205e, 0xa929355d, 0x2e4ee52d, 0x5e1d9cda, 0x279ae01e, 0x640287cc, 0xb153276e, 0x7e0ecf2d, 0x633cf4f2, 0xb3afaecb, 0x548a2590, 0xce0445c6, 0xa168bac3, 0xdc601813, 0xeb74591b, 0xb1ce8dfc, 0xd740cdbb, 0x6388719e, 0x8cd283d9, 0xcc7e7369, 0x38240b41, 0x0dd5a6a4, 0x8ba49dd2, 0x066503e6, 0x3ab592ff, 0xdf3be49e, 0x7d2de74f, 0x82158b8c},
    {0xeaf1760c, 0x0f25310d, 0xada6debe, 0xb966304d, 0xb7a9f1b2, 0xd1c3af92, 0x2623b263, 0x649031d2, 0x99b3c561, 0x46d61d55, 0xb6ebf4cf, 0x8dd04039, 0xa4d1ace3, 0x146f49ee, 0x915f806a, 0xfad64cbb, 0x2d04a641, 0x20de4038, 0x2e2175dc, 0xae9480d1, 0xca8dedc3, 0x8fb64e4a, 0x40112f10, 0xf03a4c35, 0x4fed01f2, 0xc5c7017d, 0xbd514b2d, 0x443a5adf, 0xd2e49c98, 0x6723266c, 0xda41a69e, 0x6e459908},
    {0x8177d79c, 0x8f239178, 0x186b4dc5, 0xf1df2ea7, 0xfee7d0db, 0x535489ef, 0x983aefb3, 0xb2029aeb, 0xa0bb2b46, 0xa2b18c94, 0xa1417a33, 0xcbeb41ca, 0x7ea9c73a, 0x677fccd2, 0xeb5470c3, 0xc500f6d3, 0xf1a6c755, 0xc944ba58, 0x6f88921f, 0x6ae6c9d1, 0x94e78c72, 0x33c40612, 0x6633e144, 0xc3810ad2, 0x3ee1b5af, 0x4c04a22d, 0x49e99e70, 0x17f74c23, 0x09492569, 0xff49be17, 0xd2804920, 0xf2ac5f51, 0x4d13fd3e, 0x7318cc7c, 0xf80ca510, 0x1a465428},
    {0x451f4566, 0x3b44fd00, 0x5f3c288a, 0xe57b3838, 0x83f02d9a, 0xd3dc1715, 0xf9e3d694, 0x8564257b, 0x9b06d7dd, 0x51935fee, 0x580a96bb, 0xdfefb918, 0xb4e6b1da, 0xac809847, 0x465578cb, 0x8b5356ed, 0x38556f80, 0x1ff7c11e, 0xcba9cdd2, 0x63039c15, 0xd05900fc, 0x228e1caf, 0x302d261d, 0x7fb56cee, 0x663595b9, 0x6f192a78, 0xff445539, 0x3a5fe816, 0x2170a066, 0xfdaeac35, 0x019469f2, 0x2b347068, 0x6bced2f0, 0x07a1a2e4, 0x3e01b456, 0x2caaa502, 0xed541b82, 0x05874ec1, 0xffb1c8b2, 0x55766942}};
static unsigned ecb_raw_encrypt_plaintext_bytes[N_TESTS] = {4*4, 8*4, 12*4, 16*4, 20*4, 24*4, 28*4, 32*4, 36*4, 40*4};
static unsigned ecb_raw_encrypt_plaintext_words[N_TESTS] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};

static unsigned ecb_raw_encrypt_ciphertext[N_TESTS][40] = {
    {0x7888beae, 0x6e7a4263, 0x32a7eaa2, 0xf808e637},
    {0xad5b0895, 0x15e78210, 0x87c61652, 0xdc477ab1, 0xf2cc6331, 0xa70dfc59, 0xc9ffb0c7, 0x23c682f6},
    {0x4cc2a8f1, 0x3c8c7c36, 0xed6a814d, 0xb7f26900, 0xc7e04df4, 0x9cbad916, 0xce6a44d0, 0xae4fe7ed, 0xc0b40279, 0x4675b369, 0x4933ebbc, 0x356525d8},
    {0x3ea6f430, 0x5217bd47, 0xeebe773d, 0xa4b57854, 0x9cac744c, 0x00cbd8f9, 0xd596d380, 0x10304bd8, 0x50cc2f4b, 0x19a91c2e, 0x022eabf1, 0x00266185, 0xca270512, 0x7815dfd4, 0x6efbe4ec, 0xd46a3058},
    {0xa6dc096b, 0xc21b0658, 0xe416a0f6, 0x79fefc6e, 0x958e9c56, 0xe3ce04fd, 0xf6e392c2, 0xdb770a60, 0xd9523c25, 0x5925e14a, 0x3e02a100, 0x2bf3875c, 0x2e501bac, 0x618bee1f, 0x55f98504, 0x54854eef, 0x9d693d90, 0x937cc838, 0x7b6f4c44, 0x14e2080b},
    {0x22217953, 0xf71932ab, 0x4360d97e, 0xf4950815, 0x59f1fcb0, 0x9caca41f, 0xa0c65f7b, 0x1792b560, 0xeabe18f3, 0xb3b06ef8, 0x0c41886f, 0x24c5d6d3, 0x2d20427e, 0x83d8b556, 0x4d9ac743, 0x5a2842c1, 0xcf7c6fcc, 0x229eb7f5, 0x18d3e016, 0x7d510efb, 0xaee39a04, 0x38fc800e, 0xb6acfc20, 0x3c93280c},
    {0xc88e0338, 0x3ba9da6f, 0x982c057f, 0xe92c0bb3, 0xed5b9cd1, 0x8295a100, 0xe13a4e12, 0xd440b919, 0xbbb8b221, 0xabead362, 0x902ce44d, 0x30d0b80e, 0x56bee1f6, 0x6a7d8de0, 0xb1e1b4db, 0xf76c90c1, 0x807a3bc5, 0xf277e981, 0x4c82ab12, 0x0f7e1021, 0x7dfdf609, 0x2ce4958f, 0x8906c5e3, 0x2279c653, 0x7dd1fbae, 0x20cb7a1d, 0x9f89d049, 0x0b6aefc1},
    {0x5ece70a4, 0x4da41bc7, 0xcfb9b582, 0xea9ce098, 0x0030ec4a, 0xf331e764, 0x99961f88, 0x860aa055, 0x4aba3ecb, 0xf77ca429, 0x3a3fee85, 0x4a2caf3a, 0xe800343f, 0xb4521388, 0xb16b6dc5, 0x99b3d60b, 0xf82777f9, 0x8e1a8d04, 0xab9cd54d, 0xd9a24809, 0x5795d4df, 0xe4858bfd, 0x9a05f54c, 0x795bb086, 0xe15f7c22, 0x228184ec, 0x66a9ca10, 0xb1cf71a6, 0xbb9303c5, 0xcd1dcc05, 0x6460a86d, 0xf651f053},
    {0x5befb306, 0x2a7a7246, 0xaf1f77b0, 0xec0ac614, 0xe28be06a, 0xc2c81b19, 0xe5a0481b, 0xf160f9f2, 0xbc43f28f, 0x65487876, 0x39e4ce3e, 0x0f1e9547, 0x5f0e81ce, 0xb793004c, 0x8e46670e, 0xbd48b866, 0xd5b43d10, 0x4874ead4, 0xbe8a236b, 0xf90b48f8, 0x62f7e252, 0xdec4475f, 0xdbb841a6, 0x62efcd25, 0xed64b291, 0x0e9baaea, 0x9466e413, 0xa4241438, 0xb31df0bd, 0x3df9a16f, 0x46416367, 0x54e25986, 0x1728aa7d, 0xdf435cc5, 0x1f54f79a, 0x1db25f52},
    {0x01043053, 0xf832ef9b, 0x911ed387, 0xba577451, 0xe30d51d4, 0xb6b11f31, 0x9d4cd539, 0xd067b7f4, 0xf9b4f41f, 0x7f3d4e92, 0x0c57cbe2, 0xb5e1885a, 0xa66203ae, 0x493e93a1, 0xdf63793a, 0x9563c176, 0xbc6775dd, 0x09cc9161, 0xe278a01b, 0xeb8fd8a1, 0x9200326b, 0xd95abc5f, 0x716768e3, 0x4f90b505, 0x23d30fda, 0xbb103a3b, 0xc020afbb, 0xb0cb3bd2, 0xad512a6f, 0xea79f8d6, 0x4cef3474, 0x58dec48b, 0xe89451cb, 0x0b807d73, 0x593f273d, 0x9fc521b7, 0x89a77524, 0x404f43e0, 0x0f20b3b7, 0x7b938b1a}};
static unsigned ecb_raw_encrypt_ciphertext_bytes[N_TESTS] = {4*4, 8*4, 12*4, 16*4, 20*4, 24*4, 28*4, 32*4, 36*4, 40*4};
static unsigned ecb_raw_encrypt_ciphertext_words[N_TESTS] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
#endif


#ifdef AES_CTR_OPERATION_MODE
/* aes32/tests/simple/CTRSimple128.rsp */
#define N_TESTS 4

#define OPERATION_MODE AES_CTR_OPERATION_MODE

static unsigned ctr_raw_encrypt_count[N_TESTS] = {0, 1, 2, 3};

static unsigned ctr_raw_encrypt_key[N_TESTS][4] = {
    {0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c},
    {0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c},
    {0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c},
    {0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c}};
static unsigned ctr_raw_encrypt_key_bytes[N_TESTS] = {4*4, 4*4, 4*4, 4*4};
static unsigned ctr_raw_encrypt_key_words[N_TESTS] = {4, 4, 4, 4};

static unsigned ctr_raw_encrypt_iv[N_TESTS][4] = {
    {0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff},
    {0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff},
    {0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff},
    {0xf0f1f2f3, 0xf4f5f6f7, 0xf8f9fafb, 0xfcfdfeff}};
static unsigned ctr_raw_encrypt_iv_bytes[N_TESTS] = {4*4, 4*4, 4*4, 4*4};
static unsigned ctr_raw_encrypt_iv_words[N_TESTS] = {4, 4, 4, 4};

static unsigned ctr_raw_encrypt_plaintext[N_TESTS][40] = {
    {0x6bc1bee2, 0x2e409f96, 0xe93d7e11, 0x7393172a},
    {0x6bc1bee2, 0x2e409f96, 0xe93d7e11, 0x7393172a, 0xae2d8a57, 0x1e03ac9c, 0x9eb76fac, 0x45af8e51},
    {0x6bc1bee2, 0x2e409f96, 0xe93d7e11, 0x7393172a, 0xae2d8a57, 0x1e03ac9c, 0x9eb76fac, 0x45af8e51, 0x30c81c46, 0xa35ce411, 0xe5fbc119, 0x1a0a52ef}, 
    {0x6bc1bee2, 0x2e409f96, 0xe93d7e11, 0x7393172a, 0xae2d8a57, 0x1e03ac9c, 0x9eb76fac, 0x45af8e51, 0x30c81c46, 0xa35ce411, 0xe5fbc119, 0x1a0a52ef, 0xf69f2445, 0xdf4f9b17, 0xad2b417b, 0xe66c3710}};
static unsigned ctr_raw_encrypt_plaintext_bytes[N_TESTS] = {4*4, 8*4, 12*4, 16*4};
static unsigned ctr_raw_encrypt_plaintext_words[N_TESTS] = {4, 8, 12, 16};

static unsigned ctr_raw_encrypt_ciphertext[N_TESTS][40] = {
    {0x874d6191, 0xb620e326, 0x1bef6864, 0x990db6ce},
    {0x874d6191, 0xb620e326, 0x1bef6864, 0x990db6ce, 0x9806f66b, 0x7970fdff, 0x8617187b, 0xb9fffdff},
    {0x874d6191, 0xb620e326, 0x1bef6864, 0x990db6ce, 0x9806f66b, 0x7970fdff, 0x8617187b, 0xb9fffdff, 0x5ae4df3e, 0xdbd5d35e, 0x5b4f0902, 0x0db03eab},
    {0x874d6191, 0xb620e326, 0x1bef6864, 0x990db6ce, 0x9806f66b, 0x7970fdff, 0x8617187b, 0xb9fffdff, 0x5ae4df3e, 0xdbd5d35e, 0x5b4f0902, 0x0db03eab, 0x1e031dda, 0x2fbe03d1, 0x792170a0, 0xf3009cee}};
static unsigned ctr_raw_encrypt_ciphertext_bytes[N_TESTS] = {4*4, 8*4, 12*4, 16*4};
static unsigned ctr_raw_encrypt_ciphertext_words[N_TESTS] = {4, 8, 12, 16};
#endif

#ifdef AES_CBC_OPERATION_MODE
/* aes32/tests/aesmmt/CBCMMT128.rsp */
#define N_TESTS 10

#define OPERATION_MODE AES_CBC_OPERATION_MODE

static unsigned cbc_raw_encrypt_count[N_TESTS] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

static unsigned cbc_raw_encrypt_key[N_TESTS][4] = {
    {0x1f8e4973, 0x953f3fb0, 0xbd6b1666, 0x2e9a3c17},
    {0x0700d603, 0xa1c514e4, 0x6b6191ba, 0x430a3a0c},
    {0x3348aa51, 0xe9a45c2d, 0xbe33ccc4, 0x7f96e8de},
    {0xb7f3c957, 0x6e12dd0d, 0xb63e8f8f, 0xac2b9a39},
    {0xb6f9afbf, 0xe5a1562b, 0xba1368fc, 0x72ac9d9c},
    {0xbbe7b7ba, 0x07124ff1, 0xae7c3416, 0xfe8b465e},
    {0x89a55373, 0x0433f7e6, 0xd67d16d3, 0x73bd5360},
    {0xc491ca31, 0xf9170845, 0x8e29a925, 0xec558d78},
    {0xf6e87d71, 0xb0104d6e, 0xb06a68dc, 0x6a71f498},
    {0x2c144137, 0x51c31e27, 0x30570ba3, 0x361c786b}};
static unsigned cbc_raw_encrypt_key_bytes[N_TESTS] = {4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4};
static unsigned cbc_raw_encrypt_key_words[N_TESTS] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4};

static unsigned cbc_raw_encrypt_iv[N_TESTS][4] = {
    {0x2fe2b333, 0xceda8f98, 0xf4a99b40, 0xd2cd34a8},
    {0xaad1583c, 0xd91365e3, 0xbb2f0c34, 0x30d065bb},
    {0x19153c67, 0x3160df2b, 0x1d38c280, 0x60e59b96},
    {0xc80f095d, 0x8bb1a060, 0x699f7c19, 0x974a1aa0},
    {0x3f9d5ebe, 0x250ee7ce, 0x384b0d00, 0xee849322},
    {0x7f65b5ee, 0x3630bed6, 0xb84202d9, 0x7fb97a1e},
    {0xf724558d, 0xb3433a52, 0x3f4e51a5, 0xbea70497},
    {0x9ef93494, 0x6e5cd0ae, 0x97bd5853, 0x2cb49381},
    {0x1c245f26, 0x195b76eb, 0xebc2edca, 0xc412a2f8},
    {0x1dbbeb2f, 0x19abb448, 0xaf849796, 0x244a19d7}};
static unsigned cbc_raw_encrypt_iv_bytes[N_TESTS] = {4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4};
static unsigned cbc_raw_encrypt_iv_words[N_TESTS] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4};

static unsigned cbc_raw_encrypt_plaintext[N_TESTS][40] = {
    {0x45cf1296, 0x4fc824ab, 0x76616ae2, 0xf4bf0822},
    {0x068b25c7, 0xbfb1f8bd, 0xd4cfc908, 0xf69dffc5, 0xddc726a1, 0x97f0e5f7, 0x20f73039, 0x3279be91},
    {0x9b7cee82, 0x7a26575a, 0xfdbb7c7a, 0x329f8872, 0x38052e36, 0x01a79174, 0x56ba6125, 0x1c214763, 0xd5e1847a, 0x6ad5d541, 0x27a399ab, 0x07ee3599},
    {0x9ac19954, 0xce1319b3, 0x54d32204, 0x60f71c1e, 0x373f1cd3, 0x36240881, 0x160cfde4, 0x6ebfed2e, 0x791e8d5a, 0x1a136ebd, 0x1dc469de, 0xc00c4187, 0x722b841c, 0xdabcb22c, 0x1be8a146, 0x57da200e},
    {0xdb397ec2, 0x2718dbff, 0xb9c9d13d, 0xe0efcd46, 0x11bf792b, 0xe4fce0dc, 0x5f25d4f5, 0x77ed8cdb, 0xd4eb9208, 0xd593dda3, 0xd4653954, 0xab64f056, 0x76caa3ce, 0x9bfa795b, 0x08b67cee, 0xbc923fdc, 0x89a8c431, 0x188e9e48, 0x2d855398, 0x2cf304d1},
    {0x2aad0c2c, 0x4306568b, 0xad744746, 0x0fd3dac0, 0x54346d26, 0xfeddbc9a, 0xbd911091, 0x4011b479, 0x4be2a9a0, 0x0a519a51, 0xa5b51240, 0x14f4ed27, 0x35480db2, 0x1b434e99, 0xa911bb0b, 0x60fe0253, 0x763725b6, 0x28d5739a, 0x5117b7ee, 0x3aefafc5, 0xb4c1bf44, 0x6467e7bf, 0x5f78f31f, 0xf7caf187},
    {0x807bc4ea, 0x684eedcf, 0xdcca3018, 0x0680b0f1, 0xae2814f3, 0x5f36d053, 0xc5aea659, 0x5a386c14, 0x42770f4d, 0x7297d8b9, 0x1825ee72, 0x37241da8, 0x925dd594, 0xccf676ae, 0xcd46ca20, 0x68e8d37a, 0x3a0ec8a7, 0xd5185a20, 0x1e663b5f, 0xf36ae197, 0x110188a2, 0x3503763b, 0x8218826d, 0x23ced74b, 0x31e9f6e2, 0xd7fbfa6c, 0xb43420c7, 0x807a8625},
    {0xcb6a787e, 0x0dec56f9, 0xa165957f, 0x81af336c, 0xa6b40785, 0xd9e94093, 0xc6190e51, 0x52649f88, 0x2e874d79, 0xac5e167b, 0xd2a74ce5, 0xae088d2e, 0xe854f653, 0x9e0a9479, 0x6b1e1bd4, 0xc9fcdbc7, 0x9acbef4d, 0x01eeb897, 0x76d18af7, 0x1ae2a4fc, 0x47dd66df, 0x6c4dbe1d, 0x1850e466, 0x549a47b6, 0x36bcc7c2, 0xb3a62495, 0xb56bb67b, 0x6d455f1e, 0xebd9bfef, 0xecbca6c7, 0xf335cfce, 0x9b45cb9d},
    {0xf82bef3c, 0x73a6f7f8, 0x0db28572, 0x6d691db6, 0xbf55eec2, 0x5a859d3b, 0xa0e0445f, 0x26b9bb3b, 0x16a3161e, 0xd1866e4d, 0xd8f2e5f8, 0xecb4e46d, 0x74a7a78c, 0x20cdfc7b, 0xcc9e479b, 0xa7a0caba, 0x9438238a, 0xd0c01651, 0xd5d98de3, 0x7f03ddce, 0x6e6b4bd4, 0xab03cf9e, 0x8ed818ae, 0xdfa1cf96, 0x3b932067, 0xb97d776d, 0xce108719, 0x6e7e913f, 0x7448e382, 0x44509f0c, 0xaf36bd82, 0x17e15336, 0xd35c149f, 0xd4e41707, 0x893fdb84, 0x014f8729},
    {0x40d930f9, 0xa05334d9, 0x816fe204, 0x999c3f82, 0xa03f6a04, 0x57a8c475, 0xc94553d1, 0xd116693a, 0xdc618049, 0xf0a769a2, 0xeed6a6cb, 0x14c0143e, 0xc5cccdbc, 0x8dec4ce5, 0x60cfd206, 0x22570932, 0x6d4de794, 0x8e54d603, 0xd01b12d7, 0xfed752fb, 0x23f1aa44, 0x94fbb001, 0x30e9ded4, 0xe77e37c0, 0x79042d82, 0x8040c325, 0xb1a5efd1, 0x5fc842e4, 0x4014ca43, 0x74bf38f3, 0xc3fc3ee3, 0x27733b0c, 0x8aee1abc, 0xd055772f, 0x18dc0460, 0x3f7b2c1e, 0xa69ff662, 0x361f2be0, 0xa171bbdc, 0xea1e5d3f}};
static unsigned cbc_raw_encrypt_plaintext_bytes[N_TESTS] = {4*4, 8*4, 12*4, 16*4, 20*4, 24*4, 28*4, 32*4, 36*4, 40*4};
static unsigned cbc_raw_encrypt_plaintext_words[N_TESTS] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};

static unsigned cbc_raw_encrypt_ciphertext[N_TESTS][40] = {
    {0x0f61c4d4, 0x4c5147c0, 0x3c195ad7, 0xe2cc12b2},
    {0xc4dc61d9, 0x725967a3, 0x020104a9, 0x738f2386, 0x8527ce83, 0x9aab1752, 0xfd8bdb95, 0xa82c4d00},
    {0xd5aed6c9, 0x622ec451, 0xa15db128, 0x19952b67, 0x52501cf0, 0x5cdbf8cd, 0xa34a4577, 0x26ded978, 0x18e1f127, 0xa28d72db, 0x5652749f, 0x0c6afee5},
    {0x19b96097, 0x72c63f33, 0x8608bf6e, 0xb52ca10b, 0xe65097f8, 0x9c1e0905, 0xc42401fd, 0x47791ae2, 0xc5440b2d, 0x473116ca, 0x78bd9ff2, 0xfb6015cf, 0xd316524e, 0xae7dcb95, 0xae738ebe, 0xae84a467},
    {0x10ea27b1, 0x9e16b93a, 0xf169c4a8, 0x8e06e35c, 0x99d8b420, 0x980b058e, 0x34b4b8f1, 0x32b13766, 0xf7272820, 0x2b089f42, 0x8fecdb41, 0xc79f8aa0, 0xd0ef68f5, 0x786481cc, 0xa29e2126, 0xf69bc141, 0x60f1ae21, 0x87878ba5, 0xc49cf396, 0x1e1b7ee9},
    {0x3b8611bf, 0xc4973c5c, 0xd8e982b0, 0x73b33184, 0xcd261101, 0x59172e44, 0x988eb5ff, 0x5661a1e1, 0x6fad6725, 0x8fcbfee5, 0x5469267a, 0x12dc3748, 0x93b4e353, 0x3d36f563, 0x4c309558, 0x3596f135, 0xaa8cd113, 0x8dc898bc, 0x5651ee35, 0xa92ebf89, 0xab6aeb53, 0x66653bc6, 0x0a70e007, 0x4fc11efe},
    {0x406af142, 0x9a478c3d, 0x07e555c5, 0x287a6050, 0x0d37fc39, 0xb68e5bbb, 0x9bafd6dd, 0xb2238285, 0x61d6171a, 0x308d5b1a, 0x4551e8a5, 0xe7d57291, 0x8d25c968, 0xd3871848, 0xd2f16635, 0xcaa9847f, 0x38590b1d, 0xf58ab5ef, 0xb985f2c6, 0x6cfaf86f, 0x61b3f9c0, 0xafad6c96, 0x3c49cee9, 0xb8bc81a2, 0xddb06c96, 0x7f325515, 0xa4849eec, 0x37ce721a},
    {0x7b2931f5, 0x855f7171, 0x45e00f15, 0x2a9f4794, 0x359b1ffc, 0xb3e55f59, 0x4e33098b, 0x51c23a6c, 0x74a06c1d, 0x94fded7f, 0xd2ae42c7, 0xdb7acaef, 0x5844cb33, 0xaeddc685, 0x2585ed00, 0x20a6699d, 0x2cb53809, 0xcefd1691, 0x48ce4229, 0x2afab063, 0x44397830, 0x6c582c18, 0xb9ce0da3, 0xd084ce4d, 0x3c482cfd, 0x8fcf1a85, 0x084e89fb, 0x88b40a08, 0x4d5e9724, 0x66d07666, 0x126fb761, 0xf84078f2},
    {0xb09512f3, 0xeff9ed0d, 0x85890983, 0xa73dadbb, 0x7c3678d5, 0x2581be64, 0xa8a8fc58, 0x6f490f25, 0x21297a47, 0x8a059804, 0x0ebd0f55, 0x09fafb09, 0x69f9d9e6, 0x00eaef33, 0xb1b93eed, 0x99687b16, 0x7f89a506, 0x5aac439c, 0xe46f3b8d, 0x22d30865, 0xe64e45ef, 0x8cd30b69, 0x84353a84, 0x4a11c8cd, 0x60dba0e8, 0x866b3ee3, 0x0d24b3fa, 0x8a643b32, 0x8353e060, 0x10fa8273, 0xc8fd54ef, 0x0a2b6930, 0xe5520aae, 0x5cd5902f, 0x9b86a335, 0x92ca4365},
    {0x6be8a128, 0x00455a32, 0x0538853e, 0x0cba31bd, 0x2d80ea0c, 0x85164a4c, 0x5c261ae4, 0x85417d93, 0xeffe2ebc, 0x0d0a0b51, 0xd6ea1863, 0x3d210cf6, 0x3c0c4ddb, 0xc27607f2, 0xe81ed911, 0x3191ef86, 0xd56f3b99, 0xbe6c415a, 0x4150299f, 0xb846ce71, 0x60b40b63, 0xbaf1179d, 0x19275a2e, 0x83698376, 0xd28b9254, 0x8c68e06e, 0x6d994e2c, 0x1501ed29, 0x7014e702, 0xcdefee2f, 0x65644770, 0x6009614d, 0x801de1ca, 0xaf73f8b7, 0xfa56cf1b, 0xa94b6319, 0x33bbe577, 0x62438085, 0x0f117435, 0xa0355b2b}};
static unsigned cbc_raw_encrypt_ciphertext_bytes[N_TESTS] = {4*4, 8*4, 12*4, 16*4, 20*4, 24*4, 28*4, 32*4, 36*4, 40*4};
static unsigned cbc_raw_encrypt_ciphertext_words[N_TESTS] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
#endif

static void init_buf(unsigned idx, token_t *inputs, token_t * gold_outputs, unsigned *raw_encrypt_key_words, unsigned *raw_encrypt_iv_words, unsigned *raw_encrypt_plaintext_words, unsigned *raw_encrypt_ciphertext_words, unsigned raw_encrypt_key[][4], unsigned raw_encrypt_iv[][4], unsigned raw_encrypt_plaintext[][40], unsigned raw_encrypt_ciphertext[][40])
{
    int i, j;

    //printf("INFO:  input data @%p\n", inputs);
    //printf("INFO:  key_bytes %u\n", key_bytes);
    //printf("INFO:  in_bytes %u\n", in_bytes);
    //printf("INFO:  out_bytes %u\n", out_bytes);

    printf("INFO: raw_encrypt_key_words[%u] %u\n", idx, raw_encrypt_key_words[idx]);
#if defined(AES_CTR_OPERATION_MODE) || defined(AES_CBC_OPERATION_MODE)
    printf("INFO: raw_encrypt_iv_words[%u] %u\n", idx, raw_encrypt_iv_words[idx]);
#endif
    printf("INFO: raw_encrypt_plaintext_words[%u] %u\n", idx, raw_encrypt_plaintext_words[idx]);
    printf("INFO: raw_encrypt_ciphertext_words[%u] %u\n", idx, raw_encrypt_ciphertext_words[idx]);

    for (j = 0; j < raw_encrypt_key_words[idx]; j++)
    {
        inputs[j] = raw_encrypt_key[idx][j];
#ifdef __DEBUG__
        printf("INFO:  raw_encrypt_key[%u][%u]       | inputs[%u]@%p %x\n", idx, j, j, inputs + j, raw_encrypt_key[idx][j]);
#endif
    }

#if defined(AES_CTR_OPERATION_MODE) || defined(AES_CBC_OPERATION_MODE)
    for (i = 0; i < raw_encrypt_iv_words[idx]; i++, j++)
    {
        inputs[j] = raw_encrypt_iv[idx][i];
#ifdef __DEBUG__
        printf("INFO:  raw_encrypt_iv[%u][%u]        | inputs[%u]@%p %x\n", idx, i, j, inputs + j, raw_encrypt_iv[idx][i]);
#endif
    }
#endif

    for (i = 0; i < raw_encrypt_plaintext_words[idx]; i++, j++)
    {
        inputs[j] = raw_encrypt_plaintext[idx][i];
#ifdef __DEBUG__
        printf("INFO: raw_encrypt_plaintext[%u][%u] | inputs[%u]@%p %x\n", idx, i, j, inputs + j, raw_encrypt_plaintext[idx][i]);
#endif
    }

#ifdef __DEBUG__
    printf("INFO: gold output data @%p\n", gold_outputs);
#endif

    for (j = 0; j < raw_encrypt_ciphertext_words[idx]; j++) {
        gold_outputs[j] = raw_encrypt_ciphertext[idx][j];
#ifdef __DEBUG__
        printf("INFO: raw_encrypt_ciphertext[%u][%u] %x\n", idx, j, raw_encrypt_ciphertext[idx][j]);
#endif
    }
}

static int validate_buf(unsigned idx, token_t *out, token_t *gold, unsigned *raw_encrypt_ciphertext_words)
{
    int j;
    unsigned errors = 0;

    printf("INFO:  gold output data @%p\n", gold);
    printf("INFO:       output data @%p\n", out);

    for (j = 0; j < raw_encrypt_ciphertext_words[idx]; j++)
    {
        token_t gold_data = gold[j];
        token_t out_data = out[j];

        if (out_data != gold_data)
        {
            errors++;
#ifdef __DEBUG__
            printf("INFO: [%u] @%p %x (%x) %s\n", j, out + j, out_data, gold_data, ((out_data != gold_data)?" !!!":""));
#endif
        }
    }

    printf("INFO: total errors %u\n", errors);

    return errors;
}


int main(int argc, char * argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device *espdevs;
    struct esp_device *dev;
    unsigned done;
    unsigned **ptable;
    token_t *mem;
    token_t *gold;
    unsigned errors = 0;

    // Search for the device
    printf("INFO: Scanning device tree... \n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_AES_CXX, DEV_NAME);

    printf("INFO: Found %d devices: %s\n", ndev, DEV_NAME);

    if (ndev == 0) {
        printf("INFO: aes_cxx not found\n");
        return 0;
    }

    printf("INFO:   sizeof(token_t) = %u\n", sizeof(token_t));

    for (unsigned idx = 1; idx < N_TESTS; idx++) {

        printf("INFO: Test: %u / %u\n", idx, N_TESTS-1);

#ifdef AES_ECB_OPERATION_MODE
        printf("INFO: === ECB mode ===\n");
        key_bytes = ecb_raw_encrypt_key_bytes[idx];
        key_words = ecb_raw_encrypt_key_words[idx];
        key_size = key_words * sizeof(token_t);

        in_bytes = ecb_raw_encrypt_plaintext_bytes[idx];
        in_words = ecb_raw_encrypt_plaintext_words[idx];
        in_size = in_words * sizeof(token_t);

        tag_bytes = 0;
        aad_bytes = 0;
        iv_bytes = 0;

        out_bytes = in_bytes;
        out_words = in_words;
        out_size = out_words * sizeof(token_t);

        mem_size = key_size + in_size + out_size;
#endif

#ifdef AES_CTR_OPERATION_MODE
        printf("INFO: === CTR mode ===\n");
        key_bytes = ctr_raw_encrypt_key_bytes[idx];
        key_words = ctr_raw_encrypt_key_words[idx];
        key_size = key_words * sizeof(token_t);

        iv_bytes = ctr_raw_encrypt_iv_bytes[idx];
        iv_words = ctr_raw_encrypt_iv_words[idx];
        iv_size = iv_words * sizeof(token_t);

        in_bytes = ctr_raw_encrypt_plaintext_bytes[idx];
        in_words = ctr_raw_encrypt_plaintext_words[idx];
        in_size = in_words * sizeof(token_t);

        tag_bytes = 0;
        aad_bytes = 0;

        out_bytes = in_bytes;
        out_words = in_words;
        out_size = out_words * sizeof(token_t);

        mem_size = key_size + iv_size + in_size + out_size;
#endif

#ifdef AES_CBC_OPERATION_MODE
        printf("INFO: === CBC mode ===\n");
        key_bytes = cbc_raw_encrypt_key_bytes[idx];
        key_words = cbc_raw_encrypt_key_words[idx];
        key_size = key_words * sizeof(token_t);

        iv_bytes = cbc_raw_encrypt_iv_bytes[idx];
        iv_words = cbc_raw_encrypt_iv_words[idx];
        iv_size = iv_words * sizeof(token_t);

        in_bytes = cbc_raw_encrypt_plaintext_bytes[idx];
        in_words = cbc_raw_encrypt_plaintext_words[idx];
        in_size = in_words * sizeof(token_t);

        tag_bytes = 0;
        aad_bytes = 0;

        out_bytes = in_bytes;
        out_words = in_words;
        out_size = out_words * sizeof(token_t);

        mem_size = key_size + iv_size + in_size + out_size;
#endif

        // Allocate memory
        gold = aligned_malloc(out_size);
        mem = aligned_malloc(mem_size);
        printf("INFO: Memory buffer\n");
        printf("INFO:   - base address = %p\n", mem);
        printf("INFO:   - size = %u B\n", mem_size);
        printf("INFO: Golden buffer\n");
        printf("INFO:   - base address = %p\n", gold);
        printf("INFO:   - size = %u B\n", out_size);

        // Alocate and populate page table
        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
        //printf("INFO:  ptable = %p\n", ptable);
        //printf("INFO:  nchunk = %lu\n", NCHUNK(mem_size));

        printf("INFO: Generate input...\n");

#ifdef AES_ECB_OPERATION_MODE
        init_buf(idx, mem, gold, ecb_raw_encrypt_key_words, NULL, ecb_raw_encrypt_plaintext_words, ecb_raw_encrypt_ciphertext_words, ecb_raw_encrypt_key, NULL, ecb_raw_encrypt_plaintext, ecb_raw_encrypt_ciphertext);
#endif

#ifdef AES_CTR_OPERATION_MODE
        init_buf(idx, mem, gold, ctr_raw_encrypt_key_words, ctr_raw_encrypt_iv_words, ctr_raw_encrypt_plaintext_words, ctr_raw_encrypt_ciphertext_words, ctr_raw_encrypt_key, ctr_raw_encrypt_iv, ctr_raw_encrypt_plaintext, ctr_raw_encrypt_ciphertext);
#endif

#ifdef AES_CBC_OPERATION_MODE
        init_buf(idx, mem, gold, cbc_raw_encrypt_key_words, cbc_raw_encrypt_iv_words, cbc_raw_encrypt_plaintext_words, cbc_raw_encrypt_ciphertext_words, cbc_raw_encrypt_key, cbc_raw_encrypt_iv, cbc_raw_encrypt_plaintext, cbc_raw_encrypt_ciphertext);
#endif

        printf("INFO: Input ready!\n");

        // Pass common configuration parameters
        for (n = 0; n < ndev; n++) {

            dev = &espdevs[n];

            // Check DMA capabilities
            if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
                printf("ERROR: Scatter-gather DMA is disabled. Abort.\n");
                return 0;
            }

            if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
                printf("ERROR: Not enough TLB entries available. Abort.\n");
                return 0;
            }

            // Pass common configuration parameters
            iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
            iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);
            iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            //iowrite32(dev, SRC_OFFSET_REG, 0x0);
            //iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev, AES_CXX_OPER_MODE_REG, OPERATION_MODE);
            iowrite32(dev, AES_CXX_ENCRYPTION_REG, 1);
            iowrite32(dev, AES_CXX_KEY_BYTES_REG, key_bytes);
            iowrite32(dev, AES_CXX_INPUT_BYTES_REG, in_bytes);
            iowrite32(dev, AES_CXX_IV_BYTES_REG, iv_bytes);
            iowrite32(dev, AES_CXX_AAD_BYTES_REG, aad_bytes);
            iowrite32(dev, AES_CXX_TAG_BYTES_REG, tag_bytes);

            // Flush (customize coherence model here)
            //esp_flush(ACC_COH_NONE);

            // Start accelerators
            printf("INFO: Accelerator start...\n");

            iowrite32(dev, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            while (!done) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
            iowrite32(dev, CMD_REG, 0x0);

            printf("INFO: Accelerator done\n");
            printf("INFO: Validating...\n");

            /* Validation */
#ifdef AES_ECB_OPERATION_MODE
#ifdef __DEBUG__
            for (i = 0; i < key_words + in_words + out_words; i++) {
                printf("INFO: mem[%u] @%p %x\n", i, mem + i, mem[i]);
            }
#endif
            errors = validate_buf(idx, mem + key_words + in_words, gold, ecb_raw_encrypt_ciphertext_words);
#endif

#ifdef AES_CTR_OPERATION_MODE
#ifdef __DEBUG__
            for (i = 0; i < key_words + iv_words + in_words + out_words; i++) {
                printf("INFO: mem[%u] @%p %x\n", i, mem + i, mem[i]);
            }
#endif
            errors = validate_buf(idx, mem + key_words + iv_words + in_words, gold, ctr_raw_encrypt_ciphertext_words);
#endif

#ifdef AES_CBC_OPERATION_MODE
#ifdef __DEBUG__
            for (i = 0; i < key_words + iv_words + in_words + out_words; i++) {
                printf("INFO: mem[%u] @%p %x\n", i, mem + i, mem[i]);
            }
#endif
            errors = validate_buf(idx, mem + key_words + iv_words + in_words, gold, cbc_raw_encrypt_ciphertext_words);
#endif

            if (errors) {
                printf("ERROR: FAIL\n");
                aligned_free(ptable);
                aligned_free(mem);
                aligned_free(gold);
                return 1;
            } else
                printf("INFO: PASS\n");
        }

        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);
    }
#if defined(AES_ECB_OPERATION_MODE)
    printf("INFO: AES ECB DONE\n");
#elif defined(AES_CTR_OPERATION_MODE)
    printf("INFO: AES CTR DONE\n");
#elif defined(AES_CBC_OPERATION_MODE)
    printf("INFO: AES CBC DONE\n");
#endif

    return 0;
}
