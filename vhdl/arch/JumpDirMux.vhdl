library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

entity JumpDirMux is
    port (
             JumpDir: in ctrl_t;
             jumpAddr : in addr_t;
             BranchMux : in addr_t;
             output : out addr_t
         );
end entity;

architecture behav of JumpDirMux is
begin
    output <= jumpAddr when JumpDir = '1' else BranchMux;
    printer: process(JumpDir, JumpAddr, BranchMux)
        variable output : addr_t;
    begin
        if JumpDir = '1' then
            output := jumpAddr;
        else
            output := BranchMux;
        end if;
        printf("pc_new = %s\n", output);
    end process;
end architecture behav;
