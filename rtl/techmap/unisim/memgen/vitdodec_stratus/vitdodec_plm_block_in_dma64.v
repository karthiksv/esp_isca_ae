//
// Created with the ESP Memory Generator
//
// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// @author Paolo Mantovani <paolo@cs.columbia.edu>
//

`timescale  1 ps / 1 ps

module vitdodec_plm_block_in_dma64(
    CLK,
    CE0,
    A0,
    D0,
    WE0,
    WEM0,
    CE1,
    A1,
    D1,
    WE1,
    WEM1,
    CE2,
    A2,
    D2,
    WE2,
    WEM2,
    CE3,
    A3,
    D3,
    WE3,
    WEM3,
    CE4,
    A4,
    D4,
    WE4,
    WEM4,
    CE5,
    A5,
    D5,
    WE5,
    WEM5,
    CE6,
    A6,
    D6,
    WE6,
    WEM6,
    CE7,
    A7,
    D7,
    WE7,
    WEM7,
    CE8,
    A8,
    Q8
  );
  input CLK;
  input CE0;
  input [14:0] A0;
  input [7:0] D0;
  input WE0;
  input [7:0] WEM0;
  input CE1;
  input [14:0] A1;
  input [7:0] D1;
  input WE1;
  input [7:0] WEM1;
  input CE2;
  input [14:0] A2;
  input [7:0] D2;
  input WE2;
  input [7:0] WEM2;
  input CE3;
  input [14:0] A3;
  input [7:0] D3;
  input WE3;
  input [7:0] WEM3;
  input CE4;
  input [14:0] A4;
  input [7:0] D4;
  input WE4;
  input [7:0] WEM4;
  input CE5;
  input [14:0] A5;
  input [7:0] D5;
  input WE5;
  input [7:0] WEM5;
  input CE6;
  input [14:0] A6;
  input [7:0] D6;
  input WE6;
  input [7:0] WEM6;
  input CE7;
  input [14:0] A7;
  input [7:0] D7;
  input WE7;
  input [7:0] WEM7;
  input CE8;
  input [14:0] A8;
  output [7:0] Q8;
  genvar d, h, v, hh;

  reg               bank_CE  [0:0][3:0][0:0][3:0][1:0];
  reg        [12:0] bank_A   [0:0][3:0][0:0][3:0][1:0];
  reg         [1:0] bank_D   [0:0][3:0][0:0][3:0][1:0];
  reg               bank_WE  [0:0][3:0][0:0][3:0][1:0];
  reg         [1:0] bank_WEM [0:0][3:0][0:0][3:0][1:0];
  wire        [1:0] bank_Q   [0:0][3:0][0:0][3:0][1:0];
  wire        [0:0] ctrld    [8:8];
  wire        [1:0] ctrlh    [8:0];
  wire        [0:0] ctrlv    [8:0];
  reg         [0:0] seld     [8:8];
  reg         [1:0] selh     [8:8];
  reg         [0:0] selv     [8:8];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][3:0][0:0][3:0][1:0];

  task check_access;
    input integer iface;
    input integer d;
    input integer h;
    input integer v;
    input integer hh;
    input integer p;
  begin
    if ((check_bank_access[d][h][v][hh][p] != -1) &&
        (check_bank_access[d][h][v][hh][p] != iface)) begin
      $display("ASSERTION FAILED in %m: port conflict on bank", h, "h", v, "v", hh, "hh", " for port", p, " involving interfaces", check_bank_access[d][h][v][hh][p], iface);
      $finish;
    end
    else begin
      check_bank_access[d][h][v][hh][p] = iface;
    end
  end
  endtask
// synopsys translate_on
// synthesis translate_on

  assign ctrld[8] = 0;
  assign ctrlh[0] = A0[1:0];
  assign ctrlh[1] = A1[1:0];
  assign ctrlh[2] = A2[1:0];
  assign ctrlh[3] = A3[1:0];
  assign ctrlh[4] = A4[1:0];
  assign ctrlh[5] = A5[1:0];
  assign ctrlh[6] = A6[1:0];
  assign ctrlh[7] = A7[1:0];
  assign ctrlh[8] = A8[1:0];
  assign ctrlv[0] = 0;
  assign ctrlv[1] = 0;
  assign ctrlv[2] = 0;
  assign ctrlv[3] = 0;
  assign ctrlv[4] = 0;
  assign ctrlv[5] = 0;
  assign ctrlv[6] = 0;
  assign ctrlv[7] = 0;
  assign ctrlv[8] = 0;

  always @(posedge CLK) begin
    seld[8] <= ctrld[8];
    selh[8] <= ctrlh[8];
    selv[8] <= ctrlv[8];
  end

  generate
  for (h = 0; h < 4; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 1; v = v + 1) begin : gen_ctrl_vbanks
      for (hh = 0; hh < 4; hh = hh + 1) begin : gen_ctrl_hhbanks

        always @(*) begin : handle_ops

// synthesis translate_off
// synopsys translate_off
          // Prevent assertions to trigger with false positive
          # 1
// synopsys translate_on
// synthesis translate_on

          /** Default **/
// synthesis translate_off
// synopsys translate_off
          check_bank_access[0][h][v][hh][0] = -1;
// synopsys translate_on
// synthesis translate_on
          bank_CE[0][h][v][hh][0]  = 0;
          bank_A[0][h][v][hh][0]   = 0;
          bank_D[0][h][v][hh][0]   = 0;
          bank_WE[0][h][v][hh][0]  = 0;
          bank_WEM[0][h][v][hh][0] = 0;
// synthesis translate_off
// synopsys translate_off
          check_bank_access[0][h][v][hh][1] = -1;
// synopsys translate_on
// synthesis translate_on
          bank_CE[0][h][v][hh][1]  = 0;
          bank_A[0][h][v][hh][1]   = 0;
          bank_D[0][h][v][hh][1]   = 0;
          bank_WE[0][h][v][hh][1]  = 0;
          bank_WEM[0][h][v][hh][1] = 0;

          /** Handle 8w:0r **/
          // Duplicated bank set 0
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(0, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[14:2];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D0[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D0[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE0;
            end
            if (ctrlh[1] == h && ctrlv[1] == v && CE1 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(1, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE1;
                bank_A[0][h][v][hh][1]   = A1[14:2];
              if (hh != 3) begin
                bank_D[0][h][v][hh][1]   = D1[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][1] = WEM1[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][1]   = D1[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][1] = WEM1[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][1]  = WE1;
            end
            if (ctrlh[2] == h && ctrlv[2] == v && CE2 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(2, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE2;
                bank_A[0][h][v][hh][0]   = A2[14:2];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D2[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM2[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D2[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM2[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE2;
            end
            if (ctrlh[3] == h && ctrlv[3] == v && CE3 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(3, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE3;
                bank_A[0][h][v][hh][1]   = A3[14:2];
              if (hh != 3) begin
                bank_D[0][h][v][hh][1]   = D3[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][1] = WEM3[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][1]   = D3[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][1] = WEM3[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][1]  = WE3;
            end
            if (ctrlh[4] == h && ctrlv[4] == v && CE4 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(4, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE4;
                bank_A[0][h][v][hh][1]   = A4[14:2];
              if (hh != 3) begin
                bank_D[0][h][v][hh][1]   = D4[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][1] = WEM4[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][1]   = D4[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][1] = WEM4[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][1]  = WE4;
            end
            if (ctrlh[5] == h && ctrlv[5] == v && CE5 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(5, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE5;
                bank_A[0][h][v][hh][0]   = A5[14:2];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D5[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM5[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D5[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM5[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE5;
            end
            if (ctrlh[6] == h && ctrlv[6] == v && CE6 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(6, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE6;
                bank_A[0][h][v][hh][1]   = A6[14:2];
              if (hh != 3) begin
                bank_D[0][h][v][hh][1]   = D6[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][1] = WEM6[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][1]   = D6[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][1] = WEM6[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][1]  = WE6;
            end
            if (ctrlh[7] == h && ctrlv[7] == v && CE7 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(7, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE7;
                bank_A[0][h][v][hh][0]   = A7[14:2];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D7[2 * (hh + 1) - 1:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM7[2 * (hh + 1) - 1:2 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D7[1 + 2 * hh:2 * hh];
                bank_WEM[0][h][v][hh][0] = WEM7[1 + 2 * hh:2 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE7;
            end

          /** Handle 0w:1r **/
          // Always choose duplicated bank set 0
            if (ctrlh[8] == h && ctrlv[8] == v && CE8 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(8, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE8;
                bank_A[0][h][v][hh][0]   = A8[14:2];
            end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 4; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 3 && (hh + 1) * 2 > 8) begin : gen_q_assign_hhbanks_last_8 
       assign Q8[7:2 * hh] = bank_Q[seld[8]][selh[8]][selv[8]][hh][0][1:0];
    end else begin : gen_q_assign_hhbanks_others_8 
      assign Q8[2 * (hh + 1) - 1:2 * hh] = bank_Q[seld[8]][selh[8]][selv[8]][hh][0];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 4; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 1; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 4; hh = hh + 1) begin : gen_wires_hhbanks

          BRAM_8192x2 bank_i(
              .CLK(CLK),
              .CE0(bank_CE[d][h][v][hh][0]),
              .A0(bank_A[d][h][v][hh][0]),
              .D0(bank_D[d][h][v][hh][0]),
              .WE0(bank_WE[d][h][v][hh][0]),
              .WEM0(bank_WEM[d][h][v][hh][0]),
              .Q0(bank_Q[d][h][v][hh][0]),
              .CE1(bank_CE[d][h][v][hh][1]),
              .A1(bank_A[d][h][v][hh][1]),
              .D1(bank_D[d][h][v][hh][1]),
              .WE1(bank_WE[d][h][v][hh][1]),
              .WEM1(bank_WEM[d][h][v][hh][1]),
              .Q1(bank_Q[d][h][v][hh][1])
            );

// synthesis translate_off
// synopsys translate_off
            always @(posedge CLK) begin
              if ((bank_CE[d][h][v][hh][0] & bank_CE[d][h][v][hh][1]) &&
                  (bank_WE[d][h][v][hh][0] | bank_WE[d][h][v][hh][1]) &&
                  (bank_A[d][h][v][hh][0] == bank_A[d][h][v][hh][1])) begin
                $display("ASSERTION FAILED in %m: address conflict on bank", h, "h", v, "v", hh, "hh");
                $finish;
              end
            end
// synopsys translate_on
// synthesis translate_on

        end
      end
    end
  end
  endgenerate

endmodule
