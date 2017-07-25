
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name r3k.vhdl -dir "/home/capplab02/r3k.vhdl/r3k.vhdl/ise/planAhead_run_2" -part xc3sd1800afg676-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "mips.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {../vhdl/arch_defs.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/utils.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/txt_utils.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/overloads.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/memory_map.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/dualport_bram.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/shiftMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/ShiftLeftImm.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/returnAddrMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/regDstMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/RegCaster.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/PC.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/memToRegMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/maindec.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/linkMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/JumpRegMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/JumpDirMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/InstructionMem.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/BranchMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/ALUSrcMux.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/alu.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/Adder.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/roms/vga.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/roms/default.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/vga_controller.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/tsc.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/leds.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/dipswitch.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/buttons.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/async_ram.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/addrdec.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/WB.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/PipeReg.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/Pipeliner.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/MUX1bit.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/MUX.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/MEM.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/IF.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/ID.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/EX.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/CtrlReg.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/AluOpReg.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/io/mem.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/regFile.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/cpu.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../vhdl/arch/mips.vhdl}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top mips $srcset
add_files [list {mips.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3sd1800afg676-4
