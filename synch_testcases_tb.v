`include "synch_fifo.v"
module tb;
	parameter WIDTH=8;
	parameter FIFO_SIZE=16;
	parameter PTR_WIDTH=$clog2(FIFO_SIZE);
	reg clk,res,wr_en,rd_en;
	reg [WIDTH-1:0]wdata;
	wire[WIDTH-1:0]rdata;
	wire full,empty,overflow,underflow;
	
	synch_fifo dut(.clk(clk),.res(res),.wr_en(wr_en),.rd_en(rd_en),.wdata(wdata),.rdata(rdata),.full(full),.overflow(overflow),.empty(empty),.underflow(underflow));

	integer i,j,k,wr_delay,rd_delay;
	reg[8*15-1:0]test_name;
	always #5 clk=~clk;
	
	initial begin
			clk=0;
			res=1;
			wr_en=0;
			rd_en=0;
			wdata=0;
			repeat(2)@(posedge clk);
			res=0;

			$value$plusargs("test_name=%0s",test_name);
			case(test_name)
				"FULL":begin
						write(FIFO_SIZE);
				end
				"OVERFLOW":begin
						write(FIFO_SIZE+1);
				end
				"EMPTY":begin
						write(FIFO_SIZE);
						read(FIFO_SIZE);
				end
				"UNDERFLOW":begin
						write(FIFO_SIZE);
						read(FIFO_SIZE+1);
				end
				"CONCURRENT":begin
						for(k=0;k<20;k=k+1)begin
							fork
								begin
										write(1);
										wr_delay=$urandom_range(5,10);
										#(wr_delay);
								end
								begin
										wait(empty==0);
										read(1);
										rd_delay=$urandom_range(5,10);
										#(rd_delay);
								end
							join
						end
				end
			endcase
			#50;
			$finish;
	end
	task write(input integer N);begin
		for(i=0;i<N;i=i+1)begin
			@(posedge clk);
			wr_en=1;
			wdata=$random;
		end	
		@(posedge clk);
		wr_en=0;
		wdata=0;
	end
	endtask

	task read(input integer N);begin
		for(j=0;j<N;j=j+1)begin
			@(posedge clk);
			rd_en=1;
		end			
		@(posedge clk);
		rd_en=0;
	end
	endtask

endmodule
		



