module my_fifo (
    input clk,
    input rstn,

    input [7:0] din,

    input wr_en,
    input rd_en,

    output reg [7:0]     dout,
    output reg           full,
    output reg           empty
  ); //already tested! It works

  ////////////////////// Parameter define //////////////////////
  parameter WIDTH = 8;
  parameter DEPTH = 32;

  ////////////////////// Reg define //////////////////////
  reg [WIDTH-1:0] mem [DEPTH-1:0]; // width first, depth last
  reg [4:0] wr_ptr, rd_ptr;
  wire  empty_flag, full_flag;

  ////////////////////// Other define //////////////////////
  integer i ;

  ////////////////////// Assign Block//////////////////////
  assign empty_flag = (wr_ptr-1 == rd_ptr) ? 1 : 0;
  assign full_flag = ((wr_ptr%32) == rd_ptr) ? 1 : 0;


  ////////////////////// Always Block//////////////////////
  always @(posedge clk or negedge rstn)
  begin:MEM
    if (!rstn)
    begin
      for ( i = 0; i < DEPTH; i=i+1 )
      begin
        mem[i] <= 8'b0;
      end
    end
    else if(wr_en)
    begin
      mem[wr_ptr] <= din;
    end
    else
    begin
      for ( i = 0; i < DEPTH; i=i+1 )
      begin
        mem[i] <= mem[i];
      end
    end
  end

  always @(posedge clk or negedge rstn)
  begin:RD_PTR
    if (!rstn)
    begin
      rd_ptr <= 5'd0;
    end
    else if(rd_en && !empty_flag)
    begin
      if (rd_ptr == 5'd31)
      begin
        rd_ptr <= 5'd0;
      end
      else
        rd_ptr <= rd_ptr + 1'd1;
    end
    else
    begin
      rd_ptr <= rd_ptr;
    end
  end

  always @(posedge clk or negedge rstn)
  begin:WR_PTR
    if (!rstn)
    begin
      wr_ptr <= 5'd1;
    end
    else if(wr_en && !full_flag)
    begin
      if (wr_ptr == 5'd31)
      begin
        wr_ptr <= 5'd0;
      end
      else
        wr_ptr <= wr_ptr + 1'b1;
    end
    else
    begin
      wr_ptr <= wr_ptr;
    end
  end

  always @(*)
  if (!rstn) begin
    full <= 1'b0;
    empty <= 1'b1;
    dout <= 8'd0;
  end
  else begin
    full <= full_flag;
    empty <= empty_flag;
    dout <= mem[rd_ptr];
  end

endmodule //top
