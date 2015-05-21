-------------------------------------------------------------------------------
-- Filename:        user_logic.vhd
-- Version:         v1.00c
-- Description:     The GCD functionallity of your choice
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
library Unisim;
use Unisim.all;

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity user_logic is
  port (
    Clk      : in std_logic; -- clock
    Rst		 : in std_logic; -- reset, active high
    -- read signals
    Exists   : in std_logic; -- active if data is available
    Rd_ack   : out std_logic; -- read ack from this core
    D_in     : in std_logic_vector(0 to 31); -- data to this core
    -- write signals
    Full     : in std_logic; -- active if fifo is full
    Wr_en    : out std_logic; -- read ack from this core
    D_out    : out std_logic_vector(0 to 31) -- data from this core
  );
end entity user_logic;

architecture IMP of user_logic is
-------------------------------------------------------------------------------
-- Type declarations
-------------------------------------------------------------------------------
type STATE_TYPE is (S_read1, S_ack1, S_read2, S_ack2, S_calc1, S_calc2, S_write);
signal CS, NS: STATE_TYPE;

signal CurrentVar1: std_logic_vector(0 to 31); 
signal CurrentVar2: std_logic_vector(0 to 31); 
signal Result: std_logic_vector(0 to 31);
signal NextVar1: std_logic_vector(0 to 31); 
signal NextVar2: std_logic_vector(0 to 31); 

-------------------------------------------------------------------------------
-- Signal declarations
-------------------------------------------------------------------------------

begin

  --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  --  Observe!!! only use the type std_logic_vector(0 to 31) for integers.
  --  The bit ordered of the vector must be 0 to 31, 31 downto 0 will not work!
  --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SYNC_PROC: process(Clk, Rst)
begin
	if (Rst = '1') then
		CS <= S_read1;
	-- other state variables reset
		CurrentVar1 <= "00000000000000000000000000000000";
		CurrentVar2 <= "00000000000000000000000000000000";
		--Result <= "00000000000000000000000000000000";
		--NextVar1 <= "00000000000000000000000000000000";
		--NextVar1 <= "00000000000000000000000000000000";
		--Rd_ack <= '0';
		--Wr_en <= '0';
		--D_out <= "00000000000000000000000000000000";
	elsif rising_edge(Clk) then
		CS <= NS;
	
		CurrentVar1 <= NextVar1;
		CurrentVar2 <= NextVar2;
	-- other state variable assignment
	end if;
end process;

COMB_PROC: process(CS,Exists,Full,D_in,CurrentVar1,CurrentVar2,Result,NextVar1,NextVar2)
	begin 	Wr_en <= '0';
	Rd_ack <= '0';
	D_out <= "00000000000000000000000000000000";
	NS <= CS;
	NextVar1 <= CurrentVar1;
	NextVar2 <= CurrentVar2;
	Result <= "00000000000000000000000000000000";
	
-- assign default signals here to avoid latches
		case CS is
			when S_read1 =>
				if (Exists = '1') then NextVar1 <= D_in; NS<=S_ack1; 
				end if;
			when S_ack1 =>
				Rd_ack <= '1';
				NS<=S_read2; --state shift
			when S_read2 => 
				if (Exists = '1') then NS<=S_ack2; 
				end if;
			when S_ack2 => 
				NextVar2 <= D_in;
				Rd_ack <= '1';
				NS<=S_calc1; --state shift
				
			--begin calc
			when S_calc1 =>
				if (CurrentVar1 = 0) 
					then 
					--Result <= CurrentVar2;
					NS <= S_write;
				else
					NS <= S_calc2;
				end if;
			when S_calc2 =>
				if (CurrentVar2 = 0) then
					NS <= S_write;
				else
					if (CurrentVar1 > CurrentVar2)
						then NextVar1 <= (CurrentVar1 - CurrentVar2);
						else NextVar2 <= (CurrentVar2 - CurrentVar1);
					end if;
				end if;
			when S_write =>
				--Result <= CurrentVar1;
				--write output
				if Full = '0' 
				then 
					D_out <= CurrentVar1;
					Wr_en <= '1';
					NS <= S_read1;
				end if;
	end case;
end process;

-- assign outputs here
-- assign the next state depending on various conditions
-- have a 'when' for all states

end   architecture IMP;
