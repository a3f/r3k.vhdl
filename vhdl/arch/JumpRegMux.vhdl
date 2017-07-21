library ieee;
use ieee.std_logic_1164.all;
use work.arch_defs.all;
use work.txt_utils.all;

entity JumpRegMux is
    port (
             JumpReg: in ctrl_t;
             reg1data : in addr_t;
             JumpDirMux : in addr_t;
             output : out addr_t
         );
end entity;

architecture behav of JumpRegMux is
begin
    output <= reg1data when JumpReg = '1' else JumpDirMux;
    printer: process(JumpReg, reg1data, JumpDirMux)
        variable output : addr_t;
    begin
        if JumpReg = '1' then
            output := reg1data;
        else
            output := JumpDirMux;
        end if;
        printf("pc_new = %s\n", output);
    end process;
end architecture behav;
