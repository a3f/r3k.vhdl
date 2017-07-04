-- It's a trap!
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arch_defs.all;

entity exception is
    port (
            action: in exception_config_t;

            traps : in traps_t
         );
end exception;

architecture exception of exception is
begin
    -- Only EXCEPTION_IGNORE supported for now
    -- EXCEPTION_{HALT,RESET} would need to signal the instruction fetcher
    -- EXCEPTION_TRAP is a bit more involved. For proper handling of
    -- programmable exception handlers, we need to zero the control vector
    -- forcibly, as to avoid clobbering registers/memory.
    -- I think the cleanest way would be to multiplex all control
    -- signals here, so we may choose:
    -- * either pass through in normal operation
    -- * or flush the pipeline and zero the control signal out
end exception;

