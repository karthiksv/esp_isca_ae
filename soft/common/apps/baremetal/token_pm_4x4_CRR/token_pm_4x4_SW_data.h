#define P_TOTAL 450
#define max_power_GEMM 113
#define max_power_CONV 145
#define max_power_NV 72
//TODO to add values
#define min_power_GEMM 10
#define min_power_CONV 10
#define min_power_NV 10

//#define NACC 6 //Already define in main .h
#define LUT_SIZE 64

//TODO to add values
#define max_tokens_GEMM 38
#define max_tokens_CONV 48
#define max_tokens_NV 24

	const unsigned lut_data_const_GEMM[LUT_SIZE] = {  11<<4,  11<<4,  11<<4,  11<<4,  11<<4,  10<<4,  10<<4,  10<<4,   9<<4,   9<<4,   9<<4,   8<<4,   8<<4,   7<<4,   7<<4,
					       	        	6<<4,   6<<4,   6<<4,   5<<4,   5<<4,   5<<4,   5<<4,   5<<4,   4<<4,   4<<4,   4<<4,   4<<4,   4<<4,   4<<4,   3<<4,
					  	        	3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
							        2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   2<<4,   2<<4};
						
								
	const unsigned lut_data_const_CONV[LUT_SIZE] = {  11<<4,  11<<4,  11<<4,  11<<4,  11<<4,  11<<4,  10<<4,  10<<4,  10<<4,   9<<4,   9<<4,   9<<4,   8<<4,   8<<4,   8<<4,
								7<<4,   7<<4,   6<<4,   6<<4,   6<<4,   6<<4,   5<<4,   5<<4,   5<<4,   5<<4,   4<<4,   4<<4,   4<<4,   4<<4,   4<<4,
								3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,
								1<<4,   1<<4,   1<<4,   1<<4};

	const unsigned lut_data_const_NV[LUT_SIZE] = {  11<<4,  11<<4,  11<<4,  10<<4,  10<<4,   9<<4,   8<<4,   8<<4,   7<<4,   6<<4,   6<<4,   5<<4,   5<<4,   5<<4,   4<<4,
								4<<4,   4<<4,   4<<4,   4<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   2<<4,   2<<4};
