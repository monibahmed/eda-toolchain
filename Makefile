### Please do 'sudo apt install make -y' first
### Manually setup docker for WSL rather than using Makefile

ubuntu: ubuntu-update conda gh-cli
be-tools: magic yosys netgen cvc klayout
open-tools: openroad open_pdks openlane
fe-tools: xschem ngspice verilator iverilog


ubuntu-update:
	sudo apt update; \
        sudo apt upgrade -y; \
        sudo apt install -y build-essential clang python3 python3-venv python3-pip; \
        sudo apt install -y libx11-xcb-dev libx11-dev libxrender1 libxrender-dev libxcb1 \
                libx11-xcb-dev libcairo2 libcairo2-dev gperf csh autopoint \
                tcl8.6 tcl8.6-dev tk8.6 tk8.6-dev flex bison libxpm4 libxpm-dev \
                gawk adms autoconf libtool libxcb1 libxaw7-dev libreadline6-dev;

conda:
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh ;\
        sh Miniconda3-latest-Linux-x86_64.sh -b ;\
        $(HOME)/miniconda3/bin/conda init ;\
        $(HOME)/miniconda3/bin/conda config --add channels conda-forge ;\
        $(HOME)/miniconda3/bin/conda config --add channels litex-hub ;\

gh-cli:
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg ;\
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg ;\
        echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null ;\
        sudo apt update ;\
        sudo apt install -y gh ;\

magic:
	git clone https://github.com/RTimothyEdwards/magic.git ; \
        cd $@ ; \
        ./configure ; \
        make -j16 && sudo make install;

cvc:
	git clone https://github.com/d-m-bailey/cvc.git ;  \
        cd $@; \
        autoreconf -vif; \
        ./configure --disable-nls; \
        make -j16 && sudo make install;

netgen:
	git clone https://github.com/RTimothyEdwards/netgen.git; \
        cd $@; \
        ./configure ; \
        make -j16 && sudo make install;

yosys:
	git clone https://github.com/YosysHQ/yosys.git ;\
        cd $@ ;\
        make config-gcc ;\
        make -j8 && sudo make install;

klayout:
	sudo apt-get install klayout; \


openroad:
	git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git ;\
        cd OpenROADi ;\
        sudo ./etc/DependencyInstaller.sh -runtime ;\
        sudo ./etc/DependencyInstaller.sh -development ;\
        ./etc/Build.sh ;\ 

open_pdks:
	git clone https://github.com/RTimothyEdwards/open_pdks.git ;\ 
	cd $@ ;\
	./configure --enable-sky130-pdk ; \
	make -j16 && make install; \

openlane:
	git clone https://github.com/The-OpenROAD-Project/OpenLane.git ;\

xschem: 
	git clone https://github.com/StefanSchippers/xschem.git ; \
	cd $@ ; \
	./configure && make -j16 && sudo make install; \

ngspice: 
	git clone https://git.code.sf.net/p/ngspice/ngspice ;\
	cd $@; \
 	./autogen.sh --adms; \
	mkdir release; \
	cd release; \
	../configure --with-x --enable-xspice --disable-debug \
		--enable-cider --with-readline=yes --enable-openmp --with-adms; \
	make -j16 && sudo make install; \
	make clean; \
	../configure --with-ngshared --with-x --enable-xspice --disable-debug \
		--enable-cider --with-readline=yes --enable-openmp --with-adms; \
	make -j16 && sudo make install; 
	
verilog:
	git clone https://github.com/steveicarus/iverilog.git ;\
	cd $@ ;\
	sh autoconf.sh; \
	./configure ;\
	make -j16 && sudo make install;

verilator:
	git clone https://github.com/verilator/verilator ;\
	cd $@ ;\
	autoconf; \
	./configure ;\
	make -j16 && sudo make install;



	
###############################################################################
#### ANYTHING BELOW THIS LINE IS A WORK IN PROGRESS - USE AT YOUR OWN RISK ####
###############################################################################
magical: 
	git clone https://github.com/magical-eda/MAGICAL.git $@;\
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
	sudo apt update ; \
	sudo apt-get install -y ca-certificates curl gnupg lsb-release ; \
	sudo mkdir -p /etc/apt/keyrings; \
 	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null ;\
	sudo apt update ; \
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin ; \
#	## Make sure Docker is running before setting up your user
#	sudo groupadd docker; \
#	sudo usermod -aG docker $$USER;\
#	newgrp docker;\
#        docker run hello-world; 

padring:
	git clone https://github.com/donn/padring.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@; \
	./bootstrap.sh; \
	cd build; \
	ninja ;\
        cp padring ${HOME}/tools/bin/. ;	

graywolf:
	git clone https://github.com/rubund/graywolf.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@; \
	mkdir build && cd build; \
	cmake -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
       		-DCMAKE_INSTALL_PREFIX=${PREFIX} ..; \
	make -j8 && make -j8 install;

qflow: 
	git clone https://github.com/RTimothyEdwards/qflow.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@; \
        ./configure --prefix=${PREFIX} ; \
	make -j8 && make -j8 install; 

qrouter: 
	git clone https://github.com/RTimothyEdwards/qrouter.git; \
        ./configure; \
	make -j8 && sudo make install; 
openroad:
	git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git ; \
	cd OpenROAD; \
	sudo ./etc/DependencyInstaller.sh -runtime; \
	sudo ./etc/DependencyInstaller.sh -development; \
	./etc/Build.sh; \

cuda:
	wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.0-1_all.deb; \
	sudo dpkg -i cuda-keyring_1.0-1_all.deb; \
	sudo apt-get update; \
	sudo apt-get -y install cuda; \

openroad-gpu:
	#git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git ; \
	cd OpenROAD; \
	sudo ./etc/DependencyInstaller.sh -runtime; \
	sudo ./etc/DependencyInstaller.sh -development; \
	CUDACXX=/usr/local/cuda-11.7/bin/nvcc ./etc/Build.sh -cmake="-DGPU=true -DCUDAToolkit_ROOT=/usr/local/cuda-11.7"

clean:
	rm  -rf $(HOME)/tools $(HOME)/installers ${HOME}/.xschem
