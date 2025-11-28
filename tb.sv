`timescale 1ns/1ps

module sync_fifo_tb;
	// Enable waveform dumping for EPWave (EDA Playground visualization)
// Generates dump.vcd file used to view signals after simulation
	initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, sync_fifo_tb);
	end

    localparam int WIDTH = 8;
    localparam int DEPTH = 8;

    logic                  clk;
    logic                  rst_n;
    logic                  wr_en;
    logic                  rd_en;
    logic [WIDTH-1:0]      din;
    logic [WIDTH-1:0]      dout;
    logic                  full;
    logic                  empty;
	logic [WIDTH-1:0] ref_q [$];
	logic [WIDTH-1:0] expected;
	logic [WIDTH-1:0] expected_single;
	logic wrap_error_flag;


    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .din   (din),
        .dout  (dout),
        .full  (full),
        .empty (empty)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task automatic apply_reset;
    begin
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        din   = '0;
        #20;
        rst_n = 1;
        #10;
    end
    endtask

    initial begin
        apply_reset();
      
 // --Test 1: simple FIFO check (3 writes ,3 reads)--
      $display("--TEST 1 : Simple writing and reading check--");
		wr_en = 0;
		rd_en = 0;
 	// writing AA
      	wr_en = 1;
      	din = 8'hAA;
      	@(posedge clk);
      	wr_en = 0;
		ref_q.push_back(8'hAA);

 	// writing BB
      	wr_en = 1;
      	din = 8'hBB;
      	@(posedge clk);
      	wr_en = 0;
      ref_q.push_back(8'hBB);

 	// writing CC
      	wr_en = 1;
      	din = 8'hCC;
      	@(posedge clk);
      	wr_en = 0;
      ref_q.push_back(8'hCC);


	// reading
      for (int i = 0 ; i<3 ; i++) begin
          @(posedge clk);
          rd_en = 1;
          @(posedge clk);
          rd_en = 0;
          @(posedge clk);
          expected = ref_q.pop_front();

          if (dout !== expected)
              $display("ERROR: expected = %0h, got = %0h", 					expected, dout);
          else
              $display("OK   : %0h", dout);
      end

      
// --Test 2:FULL Condition --
      $display("--TEST 2 : FULL Condition--"); 
      ref_q = {};
      for (int i = 0; i < DEPTH; i++) begin
    	wr_en = 1;
    	din   = i;          
    	@(posedge clk);
    	wr_en = 0;
    	ref_q.push_back(i); // ref model
		end
	 	wr_en = 1;
        din   = 8'hFF;   // writing while full is ON
		@(posedge clk);
		wr_en = 0;
      for (int i = 0 ; i < DEPTH ; i++) begin
			rd_en = 1;
     	 @(posedge clk);
			rd_en = 0; 
     	 @(posedge clk);
			expected = ref_q.pop_front();
			if (dout !== expected)
    			$display("ERROR FULL CHECK: expected = %0h, got 				= %0h", expected, dout);
			else
    			$display("FULL CHECK OK  : %0h", dout);
      end 

      
// --Test 3 : EMPTY Condition --
      $display("--TEST 3 : EMPTY Condition--"); 
      ref_q = {};
      if (empty == 1 && full == 0) // --Flag test --
        	$display("EMPTY TEST: flags after reset OK");
      else
        $display("EMPTY TEST ERROR: empty=%0b full=%0b", empty, full);
         
      $display("TEST 3 : Single write/read check:");

      // writing one value
      wr_en = 1;
      din   = 8'hAA;
      @(posedge clk);
      wr_en = 0;

      // reference model update
      ref_q.push_back(8'hAA);

      // reading the value
      rd_en = 1;
      @(posedge clk);
      rd_en = 0;
      @(posedge clk);

      // output check
      expected_single = ref_q.pop_front();

      if (dout !== expected_single)
          $display("EMPTY TEST ERROR: expected %0h, got %0h", expected_single, dout);
      else
          $display("EMPTY TEST OK: read %0h", dout);

      // fifo's emptiness check 
      if (empty == 1 && full == 0)
          $display("EMPTY TEST: fifo returned to empty OK");
      else
          $display("EMPTY TEST ERROR: fifo did not return to empty (empty=%0b full=%0b)", empty, full);
      
      
// --Test 4 : WRAP-AROUND Test --
      $display("--TEST 4 : WRAP-AROUND --");
	  wrap_error_flag = 0 ;
      ref_q = {};
      // writing DEPTH + 2 values
      for (int i = 0; i < DEPTH+2; i++) begin
          wr_en = 1;
          din   = i;
          @(posedge clk);
          wr_en = 0;
          @(posedge clk);

        if (ref_q.size() < DEPTH) // ref model update
              ref_q.push_back(i);
      end
      
      while (!empty) begin
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        @(posedge clk);

        expected = ref_q.pop_front();
        if (dout !== expected) begin
            $display("WRAP ERROR: expected %0d, got %0d", expected, dout);
             wrap_error_flag = 1; 
			end
        else
            $display("WRAP OK  : %0d", dout);
      end
	
      if (empty == 1 && ref_q.size() == 0 && wrap_error_flag == 0 )
          $display("WRAP-AROUND TEST PASSED");
      else
          $display("WRAP-AROUND TEST FAILED: empty=%0b, ref_q.size=%0d",
                     empty, ref_q.size());




        #200;
        $finish;
    end

endmodule

