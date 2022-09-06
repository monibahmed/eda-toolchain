### Please do ' apt install make -y' first
### Manually setup docker for WSL rather than using Makefile

be-tools: magic yosys netgen cvc klayout
open-tools: openroad open_pdks openlane
fe-tools: xschem ngspice verilator iverilog


ubuntu:
	 apt update; \
         apt upgrade -y; \
         apt install -y build-essential clang python3 python3-venv python3-pip python-yaml ;\
         apt install -y libx11-xcb-dev libx11-dev libxrender1 libxrender-dev libxcb1 \
                libx11-xcb-dev libcairo2 libcairo2-dev gperf csh autopoint swig \
                tcl8.6 tcl8.6-dev tcllib tk8.6 tk8.6-dev flex bison libxpm4 libxpm-dev \
                gawk adms autoconf libtool libxcb1 libxaw7-dev libreadline6-dev libfl-dev;

conda:
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh ;\
        sh Miniconda3-latest-Linux-x86_64.sh -b ;\
        $(HOME)/miniconda3/bin/conda init ;\
        $(HOME)/miniconda3/bin/conda config --add channels conda-forge ;\
        $(HOME)/miniconda3/bin/conda config --add channels litex-hub ;\

magic:
	git clone --depth=1 https://github.com/RTimothyEdwards/magic.git ; \
        cd $@ ; \
        ./configure --prefix=$(HOME)/eda-toolchain/local  ; \
        make -j16 &&  make install;

cvc:
	git clone --depth=1 https://github.com/d-m-bailey/cvc.git ;  \
        cd $@; \
        autoreconf -vif; \
        ./configure --prefix=$(HOME)/eda-toolchain/local  --disable-nls; \
        make -j16 &&  make install;

netgen:
	git clone --depth=1 https://github.com/RTimothyEdwards/netgen.git; \
        cd $@; \
        ./configure --prefix=$(HOME)/eda-toolchain/local  ; \
        make -j16 &&  make install;

yosys:
	git clone --depth=1 https://github.com/YosysHQ/yosys.git ;\
        cd $@ ;\
        make config-gcc PREFIX=$(HOME)/eda-toolchain/local ;\
        make -j16 PREFIX=$(HOME)/eda-toolchain/local  &&  make install;

klayout:
	 apt install -y klayout; \

openroad:
	git clone --depth=1 --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git ;\
        cd OpenROAD ;\
         ./etc/DependencyInstaller.sh -runtime ;\
         ./etc/DependencyInstaller.sh -development ;\
        ./etc/Build.sh && cd build &&  make -j16 install;\
        
open_pdks:
	git clone --depth=1 https://github.com/RTimothyEdwards/open_pdks.git ;\
	cd $@ ;\
	./configure --prefix=$(HOME)/eda-toolchain/local  --enable-sky130-pdk --prefix=${HOME}/eda-toolchain ;\
	make -j16 && make install ;\

openlane:
	git clone --depth=1 https://github.com/The-OpenROAD-Project/OpenLane.git ;\

xschem: 
	git clone --depth=1 https://github.com/StefanSchippers/xschem.git ; \
	cd $@ ; \
	./configure --prefix=$(HOME)/eda-toolchain/local  && make -j16 &&  make install; \

ngspice: 
	git clone --depth=1 https://git.code.sf.net/p/ngspice/ngspice ;\
	cd $@; \
 	./autogen.sh ; \
	mkdir release; \
	cd release; \
	../configure --prefix=$(HOME)/eda-toolchain/local  --with-x --enable-xspice --disable-debug \
		--enable-cider --with-readline=yes --enable-openmp ; \
	make -j16 &&  make install; \
	make clean;\
	../configure --prefix=$(HOME)/eda-toolchain/local  --with-ngshared --with-x --enable-xspice --disable-debug \
		--enable-cider --with-readline=yes --enable-openmp ; \
	make -j16 &&  make install; 
	
iverilog:
	git clone --depth=1 https://github.com/steveicarus/iverilog.git ;\
	cd $@ ;\
	sh autoconf.sh; \
	./configure --prefix=$(HOME)/eda-toolchain/local  ;\
	make -j16 &&  make install;

verilator:
	git clone --depth=1 https://github.com/verilator/verilator ;\
	cd $@ ;\
	autoconf; \
	./configure --prefix=$(HOME)/eda-toolchain/local  ;\
	make -j16 &&  make install;


###############################################################################
#### ANYTHING BELOW THIS LINE IS A WORK IN PROGRESS - USE AT YOUR OWN RISK ####
###############################################################################

gh-cli:
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |  dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg ;\
         chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg ;\
        echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |  tee /etc/apt/sources.list.d/github-cli.list > /dev/null ;\
         apt update ;\
         apt install -y gh ;\

magical: 
	git clone --depth=1 https://github.com/magical-eda/MAGICAL.git $@;\
	cd magical ;\
	git submodule init ;\
	git submodule update ;\
	docker pull jayl940712/magical:latest ;\
	docker run -it -v $$(pwd):/MAGICAL jayl940712/magical:latest bash ;\
	#docker build . --file Dockerfile --tag magical:latest ;\
	#docker run -it -v $$(pwd):/MAGICAL magical:latest bash ;\

## Install Docker Desktop manually first
## https://docs.docker.com/engine/install/ubuntu/
## Enable Docker integration for WSL:
## https://docs.docker.com/desktop/windows/wsl/
## https://docs.docker.com/engine/install/linux-postinstall/
## Optional: Shutdown/Restart Ubuntu
##  'docker run hello-world' should work 
docker: 
	 apt update ; \
	 apt install -y ca-certificates curl gnupg lsb-release ; \
	 mkdir -p /etc/apt/keyrings; \
 	curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" |  tee /etc/apt/sources.list.d/docker.list > /dev/null ;\
	 apt update ; \
	 apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin ; \
#	## Make sure Docker is running before setting up your user
#	 groupadd docker; \
#	 usermod -aG docker $$USER;\
#	newgrp docker;\
#        docker run hello-world; 

padring:
	git clone --depth=1 https://github.com/donn/padring.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@; \
	./bootstrap.sh; \
	cd build; \
	ninja ;\
        cp padring ${HOME}/tools/bin/. ;	

graywolf:
	git clone --depth=1 https://github.com/rubund/graywolf.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@; \
	mkdir build && cd build; \
	cmake -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
       		-DCMAKE_INSTALL_PREFIX=${PREFIX} ..; \
	make -j8 && make -j8 install;

qflow: 
	git clone --depth=1 https://github.com/RTimothyEdwards/qflow.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@; \
        ./configure --prefix=$(HOME)/eda-toolchain/local  --prefix=${PREFIX} ; \
	make -j8 && make -j8 install; 

qrouter: 
	git clone --depth=1 https://github.com/RTimothyEdwards/qrouter.git; \
        ./configure --prefix=$(HOME)/eda-toolchain/local ; \
	make -j8 &&  make install; 

cuda:
	wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.0-1_all.deb; \
	 dpkg -i cuda-keyring_1.0-1_all.deb; \
	 apt update; \
	 apt -y install cuda; \

openroad-gpu:
	#git clone --depth=1 --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git ; \
	cd OpenROAD; \
	 ./etc/DependencyInstaller.sh -runtime; \
	 ./etc/DependencyInstaller.sh -development; \
	CUDACXX=/usr/local/cuda-11.7/bin/nvcc ./etc/Build.sh -cmake="-DGPU=true -DCUDAToolkit_ROOT=/usr/local/cuda-11.7"

clean:
	 rm -rf OpenROAD Miniconda3-latest-Linux-x86_64.sh* \
		open_pdks cvc iverilog magic netgen ngspice verilator xschem yosys ;\
