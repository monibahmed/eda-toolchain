PREFIX := $(HOME)/tools
INSTALLER_PATH := $(HOME)/installers
 
### Please do 'sudo apt install make -y' first 

ubuntu:
	sudo apt update; \
	sudo apt upgrade -y; \
	sudo apt install -y build-essential clang python3 python3-venv python3-pip; \
	sudo apt install -y libx11-xcb-dev libx11-dev libxrender1 libxrender-dev libxcb1 \
       		libx11-xcb-dev libcairo2 libcairo2-dev gperf \
		tcl8.6 tcl8.6-dev tk8.6 tk8.6-dev flex bison libxpm4 libxpm-dev \
		gawk adms autoconf libtool libxcb1 libxaw7-dev libreadline6-dev; 


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
	## Make sure Docker is running before setting up your user
	sudo groupadd docker; \
	sudo usermod -aG docker $$USER;\
	newgrp docker;\
        docker run hello-world; 


## The following are Analog/Digital Design installs
openlane:
	git clone https://github.com/The-OpenROAD-Project/OpenLane.git; \
	cd OpenLane; \
	make; \
	make test; \

	
xschem: 
	git clone https://github.com/StefanSchippers/xschem.git ; \
	cd $@ ; \
	./configure && make -j16 && sudo make install; \
        #mkdir ${HOME}/.xschem && cp -rf ${INSTALLER_PATH}/$@/src/xschemrc ~/.xschem/.

## Two installs, one for shared and one for executable	
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
	
magical: 
	git clone https://github.com/magical-eda/MAGICAL.git $@;\
	cd magical ;\
	git submodule init ;\
	git submodule update ;\
	docker pull jayl940712/magical:latest ;\
	docker run -it -v $$(pwd):/MAGICAL jayl940712/magical:latest bash ;\
	#docker build . --file Dockerfile --tag magical:latest ;\
	#docker run -it -v $$(pwd):/MAGICAL magical:latest bash ;\


iverilog:
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

gh-cli:
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
		| sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg ;\
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg ;\
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null ;\
	sudo apt update ;\
	sudo apt install -y gh ;\

libs: 	
	sudo apt install -y fish csh tcsh tree tcllib cmake ninja-build doxygen graphviz; \
	sudo apt install -y build-essential python3 python3-venv python3-pip; \
	sudo apt-get install -y build-essential clang bison flex \
	libreadline-dev gperf gawk tcl-dev libffi-dev git \
	graphviz xdot pkg-config python3 libboost-system-dev \
	libboost-python-dev libboost-filesystem-dev zlib1g-dev libgsl-dev; \
	sudo apt install -y libeigen3-dev libspdlog-dev libcairo2 libcairo2-dev tcl8.6 tcl8.6-dev tk8.6 tk8.6-dev flex bison libxpm4 libxpm-dev gawk libtool automake autoconf autopoint libx11-dev libxrender1 libxrender-dev ;

cuda:
	wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.0-1_all.deb; \
	sudo dpkg -i cuda-keyring_1.0-1_all.deb; \
	sudo apt-get update; \
	sudo apt-get -y install cuda; \

qt5:
	git clone https://github.com/qt/qt5.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@; \
	./init-repository; \
	./configure -prefix $PWD/qtbase; \
	cmake --build .;
	
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

yosys:
	git clone https://github.com/YosysHQ/yosys.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@; \
        make config-gcc ; \
        make -j8 && sudo make install; 	

## QT issues
klayout: 
	sudo apt-get install klayout; \
	#git clone https://github.com/KLayout/klayout.git ${INSTALLER_PATH}/$@; \
	#cd ${INSTALLER_PATH}/$@; \
	#./build.sh -qt5 -prefix=${PREFIX} -j16; 

openroad:
	git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git ; \
	cd OpenROAD; \
	sudo ./etc/DependencyInstaller.sh -runtime; \
	sudo ./etc/DependencyInstaller.sh -development; \
	./etc/Build.sh; \
	#CUDACXX=/usr/local/cuda-11.7/bin/nvcc ./etc/Build.sh -cmake="-DCMAKE_INSTALL_PREFIX=$HOME/tools -DGPU=true"
	#cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} ..; \
	#make -j16 && make -j16 install; 

open_pdks:
	git clone https://github.com/RTimothyEdwards/open_pdks.git ${INSTALLER_PATH}/$@; \
	cd ${INSTALLER_PATH}/$@ ; \
	./configure  --enable-sky130-pdk --prefix=${PREFIX}; \
	make -j16 && make -j16 install; \

setup:
	export PATH=\$PATH:${PREFIX}/bin ; \

clean:
	rm  -rf $(HOME)/tools $(HOME)/installers ${HOME}/.xschem
