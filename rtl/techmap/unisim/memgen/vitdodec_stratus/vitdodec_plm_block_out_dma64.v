//
// Created with the ESP Memory Generator
//
// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// @author Paolo Mantovani <paolo@cs.columbia.edu>
//

`timescale  1 ps / 1 ps

module vitdodec_plm_block_out_dma64(
    CLK,
    CE0,
    A0,
    D0,
    WE0,
    WEM0,
    CE1,
    A1,
    Q1,
    CE2,
    A2,
    Q2,
    CE3,
    A3,
    Q3,
    CE4,
    A4,
    Q4,
    CE5,
    A5,
    Q5,
    CE6,
    A6,
    Q6,
    CE7,
    A7,
    Q7,
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
  output [7:0] Q1;
  input CE2;
  input [14:0] A2;
  output [7:0] Q2;
  input CE3;
  input [14:0] A3;
  output [7:0] Q3;
  input CE4;
  input [14:0] A4;
  output [7:0] Q4;
  input CE5;
  input [14:0] A5;
  output [7:0] Q5;
  input CE6;
  input [14:0] A6;
  output [7:0] Q6;
  input CE7;
  input [14:0] A7;
  output [7:0] Q7;
  input CE8;
  input [14:0] A8;
  output [7:0] Q8;
  genvar d, h, v, hh;

  reg               bank_CE  [0:0][3:0][2:0][0:0][1:0];
  reg        [10:0] bank_A   [0:0][3:0][2:0][0:0][1:0];
  reg         [7:0] bank_D   [0:0][3:0][2:0][0:0][1:0];
  reg               bank_WE  [0:0][3:0][2:0][0:0][1:0];
  reg         [7:0] bank_WEM [0:0][3:0][2:0][0:0][1:0];
  wire        [7:0] bank_Q   [0:0][3:0][2:0][0:0][1:0];
  wire        [0:0] ctrld    [8:1];
  wire        [1:0] ctrlh    [8:0];
  wire        [1:0] ctrlv    [8:0];
  reg         [0:0] seld     [8:1];
  reg         [1:0] selh     [8:1];
  reg         [1:0] selv     [8:1];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][3:0][2:0][0:0][1:0];

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

  assign ctrld[1] = 0;
  assign ctrld[2] = 0;
  assign ctrld[3] = 0;
  assign ctrld[4] = 0;
  assign ctrld[5] = 0;
  assign ctrld[6] = 0;
  assign ctrld[7] = 0;
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
  assign ctrlv[0] = A0[14:13];
  assign ctrlv[1] = A1[14:13];
  assign ctrlv[2] = A2[14:13];
  assign ctrlv[3] = A3[14:13];
  assign ctrlv[4] = A4[14:13];
  assign ctrlv[5] = A5[14:13];
  assign ctrlv[6] = A6[14:13];
  assign ctrlv[7] = A7[14:13];
  assign ctrlv[8] = A8[14:13];

  always @(posedge CLK) begin
    seld[1] <= ctrld[1];
    selh[1] <= ctrlh[1];
    selv[1] <= ctrlv[1];
    seld[2] <= ctrld[2];
    selh[2] <= ctrlh[2];
    selv[2] <= ctrlv[2];
    seld[3] <= ctrld[3];
    selh[3] <= ctrlh[3];
    selv[3] <= ctrlv[3];
    seld[4] <= ctrld[4];
    selh[4] <= ctrlh[4];
    selv[4] <= ctrlv[4];
    seld[5] <= ctrld[5];
    selh[5] <= ctrlh[5];
    selv[5] <= ctrlv[5];
    seld[6] <= ctrld[6];
    selh[6] <= ctrlh[6];
    selv[6] <= ctrlv[6];
    seld[7] <= ctrld[7];
    selh[7] <= ctrlh[7];
    selv[7] <= ctrlv[7];
    seld[8] <= ctrld[8];
    selh[8] <= ctrlh[8];
    selv[8] <= ctrlv[8];
  end

  generate
  for (h = 0; h < 4; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 3; v = v + 1) begin : gen_ctrl_vbanks
      for (hh = 0; hh < 1; hh = hh + 1) begin : gen_ctrl_hhbanks

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

          /** Handle 1w:0r **/
          // Duplicated bank set 0
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(0, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[12:2];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D0[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D0[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE0;
            end

          /** Handle 0w:8r **/
          // Always choose duplicated bank set 0
            if (ctrlh[1] == h && ctrlv[1] == v && CE1 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(1, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE1;
                bank_A[0][h][v][hh][0]   = A1[12:2];
            end
            if (ctrlh[2] == h && ctrlv[2] == v && CE2 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(2, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE2;
                bank_A[0][h][v][hh][1]   = A2[12:2];
            end
            if (ctrlh[3] == h && ctrlv[3] == v && CE3 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(3, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE3;
                bank_A[0][h][v][hh][0]   = A3[12:2];
            end
            if (ctrlh[4] == h && ctrlv[4] == v && CE4 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(4, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE4;
                bank_A[0][h][v][hh][1]   = A4[12:2];
            end
            if (ctrlh[5] == h && ctrlv[5] == v && CE5 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(5, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE5;
                bank_A[0][h][v][hh][1]   = A5[12:2];
            end
            if (ctrlh[6] == h && ctrlv[6] == v && CE6 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(6, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE6;
                bank_A[0][h][v][hh][0]   = A6[12:2];
            end
            if (ctrlh[7] == h && ctrlv[7] == v && CE7 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(7, 0, h, v, hh, 1);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][1]  = CE7;
                bank_A[0][h][v][hh][1]   = A7[12:2];
            end
            if (ctrlh[8] == h && ctrlv[8] == v && CE8 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(8, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE8;
                bank_A[0][h][v][hh][0]   = A8[12:2];
            end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 1; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_1 
       assign Q1[7:8 * hh] = bank_Q[seld[1]][selh[1]][selv[1]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_1 
      assign Q1[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[1]][selh[1]][selv[1]][hh][0];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_2 
       assign Q2[7:8 * hh] = bank_Q[seld[2]][selh[2]][selv[2]][hh][1][7:0];
    end else begin : gen_q_assign_hhbanks_others_2 
      assign Q2[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[2]][selh[2]][selv[2]][hh][1];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_3 
       assign Q3[7:8 * hh] = bank_Q[seld[3]][selh[3]][selv[3]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_3 
      assign Q3[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[3]][selh[3]][selv[3]][hh][0];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_4 
       assign Q4[7:8 * hh] = bank_Q[seld[4]][selh[4]][selv[4]][hh][1][7:0];
    end else begin : gen_q_assign_hhbanks_others_4 
      assign Q4[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[4]][selh[4]][selv[4]][hh][1];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_5 
       assign Q5[7:8 * hh] = bank_Q[seld[5]][selh[5]][selv[5]][hh][1][7:0];
    end else begin : gen_q_assign_hhbanks_others_5 
      assign Q5[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[5]][selh[5]][selv[5]][hh][1];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_6 
       assign Q6[7:8 * hh] = bank_Q[seld[6]][selh[6]][selv[6]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_6 
      assign Q6[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[6]][selh[6]][selv[6]][hh][0];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_7 
       assign Q7[7:8 * hh] = bank_Q[seld[7]][selh[7]][selv[7]][hh][1][7:0];
    end else begin : gen_q_assign_hhbanks_others_7 
      assign Q7[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[7]][selh[7]][selv[7]][hh][1];
    end
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_8 
       assign Q8[7:8 * hh] = bank_Q[seld[8]][selh[8]][selv[8]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_8 
      assign Q8[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[8]][selh[8]][selv[8]][hh][0];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 4; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 3; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 1; hh = hh + 1) begin : gen_wires_hhbanks

          BRAM_2048x8 bank_i(
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
