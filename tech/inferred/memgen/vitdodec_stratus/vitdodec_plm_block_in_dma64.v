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

  reg               bank_CE  [0:0][7:0][1:0][0:0][0:0];
  reg        [10:0] bank_A   [0:0][7:0][1:0][0:0][0:0];
  reg         [7:0] bank_D   [0:0][7:0][1:0][0:0][0:0];
  reg               bank_WE  [0:0][7:0][1:0][0:0][0:0];
  reg         [7:0] bank_WEM [0:0][7:0][1:0][0:0][0:0];
  wire        [7:0] bank_Q   [0:0][7:0][1:0][0:0][0:0];
  wire        [0:0] ctrld    [8:8];
  wire        [2:0] ctrlh    [8:0];
  wire        [0:0] ctrlv    [8:0];
  reg         [0:0] seld     [8:8];
  reg         [2:0] selh     [8:8];
  reg         [0:0] selv     [8:8];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][7:0][1:0][0:0][0:0];

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
  assign ctrlh[0] = A0[2:0];
  assign ctrlh[1] = A1[2:0];
  assign ctrlh[2] = A2[2:0];
  assign ctrlh[3] = A3[2:0];
  assign ctrlh[4] = A4[2:0];
  assign ctrlh[5] = A5[2:0];
  assign ctrlh[6] = A6[2:0];
  assign ctrlh[7] = A7[2:0];
  assign ctrlh[8] = A8[2:0];
  assign ctrlv[0] = A0[14:14];
  assign ctrlv[1] = A1[14:14];
  assign ctrlv[2] = A2[14:14];
  assign ctrlv[3] = A3[14:14];
  assign ctrlv[4] = A4[14:14];
  assign ctrlv[5] = A5[14:14];
  assign ctrlv[6] = A6[14:14];
  assign ctrlv[7] = A7[14:14];
  assign ctrlv[8] = A8[14:14];

  always @(posedge CLK) begin
    seld[8] <= ctrld[8];
    selh[8] <= ctrlh[8];
    selv[8] <= ctrlv[8];
  end

  generate
  for (h = 0; h < 8; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 2; v = v + 1) begin : gen_ctrl_vbanks
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

          /** Handle 8w:0r **/
          // Duplicated bank set 0
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(0, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[13:3];
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
            if (ctrlh[1] == h && ctrlv[1] == v && CE1 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(1, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE1;
                bank_A[0][h][v][hh][0]   = A1[13:3];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D1[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM1[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D1[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM1[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE1;
            end
            if (ctrlh[2] == h && ctrlv[2] == v && CE2 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(2, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE2;
                bank_A[0][h][v][hh][0]   = A2[13:3];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D2[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM2[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D2[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM2[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE2;
            end
            if (ctrlh[3] == h && ctrlv[3] == v && CE3 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(3, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE3;
                bank_A[0][h][v][hh][0]   = A3[13:3];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D3[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM3[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D3[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM3[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE3;
            end
            if (ctrlh[4] == h && ctrlv[4] == v && CE4 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(4, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE4;
                bank_A[0][h][v][hh][0]   = A4[13:3];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D4[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM4[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D4[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM4[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE4;
            end
            if (ctrlh[5] == h && ctrlv[5] == v && CE5 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(5, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE5;
                bank_A[0][h][v][hh][0]   = A5[13:3];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D5[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM5[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D5[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM5[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE5;
            end
            if (ctrlh[6] == h && ctrlv[6] == v && CE6 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(6, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE6;
                bank_A[0][h][v][hh][0]   = A6[13:3];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D6[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM6[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D6[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM6[7 + 8 * hh:8 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE6;
            end
            if (ctrlh[7] == h && ctrlv[7] == v && CE7 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(7, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE7;
                bank_A[0][h][v][hh][0]   = A7[13:3];
              if (hh != 0) begin
                bank_D[0][h][v][hh][0]   = D7[8 * (hh + 1) - 1:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM7[8 * (hh + 1) - 1:8 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D7[7 + 8 * hh:8 * hh];
                bank_WEM[0][h][v][hh][0] = WEM7[7 + 8 * hh:8 * hh];
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
                bank_A[0][h][v][hh][0]   = A8[13:3];
            end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 1; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 0 && (hh + 1) * 8 > 8) begin : gen_q_assign_hhbanks_last_8 
       assign Q8[7:8 * hh] = bank_Q[seld[8]][selh[8]][selv[8]][hh][0][7:0];
    end else begin : gen_q_assign_hhbanks_others_8 
      assign Q8[8 * (hh + 1) - 1:8 * hh] = bank_Q[seld[8]][selh[8]][selv[8]][hh][0];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 8; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 2; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 1; hh = hh + 1) begin : gen_wires_hhbanks


          sram_behav #(.DATA_WIDTH(8), .NUM_WORDS(2048)) bank_i(
              .clk_i(CLK),
              .req_i(bank_CE[d][h][v][hh][0]),
              .addr_i(bank_A[d][h][v][hh][0]),
              .wdata_i(bank_D[d][h][v][hh][0]),
              .we_i(bank_WE[d][h][v][hh][0]),
              .be_i(bank_WEM[d][h][v][hh][0]),
              .rdata_o(bank_Q[d][h][v][hh][0])
            );

        end
      end
    end
  end
  endgenerate

endmodule
