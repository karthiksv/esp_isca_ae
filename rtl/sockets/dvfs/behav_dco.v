//`default_nettype none

// Author: Martin Cochet
//Behavioral DCO model



`timescale 1fs/1fs

module behav_dco(EN,CC_SEL,FC_SEL,EXT_CLK,CLK_SEL,DIV_SEL,FREQ_SEL,CLK,CLK_DIV,RSTN);
input RSTN;
wire RSTN;
input EN;
wire EN;
input EXT_CLK, CLK_SEL;
wire EXT_CLK, CLK_SEL;
input [5:0] CC_SEL;
wire [5:0] CC_SEL;
input [2:0] DIV_SEL;
wire [2:0] DIV_SEL;
input [1:0] FREQ_SEL;
wire [1:0] FREQ_SEL;
output CLK;
wire CLK;
output CLK_DIV;
wire CLK_DIV;
//fine-tune inter-mux cap load
// TODO only using 6:1, keeping it as 6:0 for compatibility (LSB floating)
input [5:0] FC_SEL;
wire [5:0] FC_SEL;





reg [255:0] clk_int;
wire [7:0] LDO_IN;

assign LDO_IN[7:6]=FREQ_SEL;
assign LDO_IN[5:0]=CC_SEL;
wire LDO_IN_with_U_forced_to_0 = (LDO_IN === 8'bXXXXXXXX || LDO_IN === 8'bZZZZZZZZ) ? 8'b00000000 : LDO_IN;
assign CLK=clk_int[unsigned'(LDO_IN_with_U_forced_to_0)];
assign CLK_DIV=1'b0;

localparam TIME_PERIOD= 10;
localparam TIME_PERIOD_HALF= TIME_PERIOD/2;
//1600MHz to 44.5MHz
parameter integer DELAYS [0 : 255]   = {625000,627392,629802,632231,634679,637146,639632,642137,644662,647207,649773,652358,654965,657592,660240,662910,665602,668315,671051,673809,676590,679394,682221,685072,687947,690846,693770,696718,699692,702691,705716,708767,711845,714950,718081,721241,724428,727643,730887,734160,737463,740796,744158,747552,750976,754432,757920,761441,764994,768580,772201,775855,779545,783269,787030,790826,794660,798531,802439,806387,810373,814399,818465,822571,826720,830910,835143,839419,843739,848104,852515,856971,861475,866026,870625,875274,879972,884721,889521,894374,899281,904241,909256,914328,919456,924642,929887,935191,940557,945984,951475,957029,962649,968335,974089,979912,985804,991768,997805,1003915,1010101,1016363,1022704,1029124,1035626,1042209,1048878,1055632,1062473,1069404,1076426,1083541,1090750,1098056,1105461,1112966,1120574,1128286,1136105,1144034,1152074,1160227,1168497,1176886,1185396,1194030,1202790,1211681,1220703,1229861,1239157,1248595,1258178,1267909,1277792,1287830,1298027,1308387,1318913,1329610,1340483,1351534,1362769,1374193,1385809,1397624,1409642,1421868,1434309,1446969,1459854,1472971,1486326,1499925,1513775,1527884,1542258,1556905,1571833,1587050,1602564,1618385,1634521,1650982,1667779,1684920,1702417,1720282,1738526,1757160,1776199,1795655,1815541,1835873,1856665,1877934,1899696,1921968,1944769,1968117,1992032,2016536,2041650,2067397,2093802,2120891,2148689,2177226,2206531,2236636,2267574,2299379,2332090,2365744,2400384,2436054,2472799,2510670,2549720,2590003,2631579,2674512,2718869,2764722,2812148,2861230,2912056,2964720,3019324,3075977,3134796,3195909,3259452,3325574,3394433,3466205,3541076,3619254,3700962,3786445,3875969,3969829,4068348,4171882,4280822,4395604,4516712,4644682,4780115,4923683,5076142,5238345,5411255,5595971,5793743,6006006,6234414,6480881,6747638,7037298,7352941,7698229,8077544,8496177,8960573,9478673,10060362,10718114,11467890,12330456,13333333,14513788,15923567,17636684,19762846,22471910};

//parameter integer DELAYS [1 : 0]   = {2000,2000};



	//localparam DELAYH=DELAYS[i]/2;

genvar i;

generate
for (i = 0; i < 256 ; i = i + 1) begin
	localparam TIME_PERIODI=8.0*DELAYS[i]/2.0;
	initial 
	begin
	clk_int[i]=0;
    forever #TIME_PERIODI clk_int[i]=(~clk_int[i])&&EN;
	end
end
endgenerate


endmodule

//`default_nettype wire
