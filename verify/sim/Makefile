# tb_top name
tc =  tb_top

verdi_opts = -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab $(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a

rtl_list = ../../design/rtl
commonip_list = ../../design/common_ip
include_list = ../../design/incl
tb_list	= ../../verify/tb

tb_files = $(tb_list)/$(tc).sv

all:  mklist compile elaborateR sim 

allv: mklist compile elaborate sim verdi

mklist:
				rm -rf ./filelist.f
				touch ./filelist.f
				echo "+incdir+${include_list}" > filelist.f
				find  $(rtl_list) -type f \( -name "*.v" -o -name "*.sv" \) >> filelist.f

compile:
				vlogan \
				+v2k \
				-full64 \
				-work xil_defaultlib \
				"/opt/vivado/glbl.v" \
				+incdir+${include_list} \
				-sverilog \
				+define+SIMULATION_EN \
				$(tb_files) \
				-F ./filelist.f \
				-l com.log \

elaborate:
				vcs \
				-full64 \
				-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed \
				-Mdir=./vcs_lib/xil_defaultlib \
				-sverilog \
			    -debug_acc+all -debug_region+cell+encrypt \
				$(verdi_opts) \
				xil_defaultlib.${tc} xil_defaultlib.glbl\
				-o simv \
				2>&1 | tee -a vlogan.log

elaborateR:
				vcs \
				-full64 \
				-R \
				-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed \
				-Mdir=./vcs_lib/xil_defaultlib \
				-sverilog \
			    -debug_acc+all -debug_region+cell+encrypt \
				$(verdi_opts) \
				xil_defaultlib.${tc} xil_defaultlib.glbl\
				-o simv \
				2>&1 | tee -a vlogan.log


sim:
				./simv -ucli -licqueue -l simulate.log -do simulate.do

verdi:
				verdi \
				-sv \
				+v2k \
				$(tb_files) \
				-F ./filelist.f \
				-ssf *.fsdb \
				-nologo &


clean:
				rm -rf  *.key *.vpd DVEfiles coverage *.vdb  novas* verdiLog vfastLog *.mr *.pvl *.syn *.svf ./filelist.f simv.daidir *.log *.fsdb  simv vcs_lib 64

