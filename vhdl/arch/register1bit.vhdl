entity register1bit is
port(
    data   : in std_logic;
    enable  : in std_logic; -- load/enable.
    clr : in std_logic; -- async. clear.
    clk : in std_logic; -- clock.
    output   : out std_logic -- output.
);
END register1;

architecture behav of register1 is

begin
    process(clk, clr)
    begin
        if clr = '1' then
            output <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                output <= data;
            end if;
        end if;
    end process;
end behav;
