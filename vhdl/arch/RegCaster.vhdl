-- Zero/Sign extend integers before loading them into registers
library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.utils.all;

entity RegCaster is
    port (input : in word_t;
          SignExtend : in ctrl_t;
          size : in ctrl_memwidth_t;
          extended : out word_t
         );
    end;

Architecture behav of RegCaster is
    constant ZEROS : byte_t := X"00";
    constant ONES  : byte_t := X"ff";

    alias byte     is input( 7 downto 0);
    alias byte_msb is input(7);
    alias half     is input(15 downto 0);
    alias half_msb is input(15);
    alias word     is input(31 downto 0);
begin
    extended <= X"FFFF_FF" & byte when size = WIDTH_BYTE and SignExtend = '1' and byte_msb = '1'
           else X"0000_00" & byte when size = WIDTH_BYTE
           else X"FFFF"    & half when size = WIDTH_HALF and SignExtend = '1' and half_msb = '1'
           else X"0000"    & half when size = WIDTH_HALF
           else              word;
end;


