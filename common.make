# Values(required):
#	LIB_NAME					= 作成しようとしているライブラリ(プログラム)名
# Values(optional):
# 	ADDITIONAL_CMAKE_OPTION		= CMakeオプション
#	ADDITIONAL_CMD				= CMakeタスクを実行した後の追加コマンド
# Options:
# 	JOBS						= 最大ジョブ数
# 	BUILD_TYPE					= Debug や Release など
# 	CXX							= コンパイルコマンド
# 	MAKE_COMPILECOMMANDS_LINK	= 定義するとcompile_commands.jsonへのリンクをカレントディレクトリに作る

# このファイル(common.make)が置かれているパス
CURRENT_MAKEDIR_PATH	:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

BUILD_BASE_DIR		?= /var/tmp
PWD					:= $(shell pwd)
WORK_DIR			:= $(BUILD_BASE_DIR)/$(LIB_NAME)

JOBS				?= $(shell expr $(shell nproc) + 1)
BUILD_TYPE			?= Debug
CXX					?= g++

OPT_BUILD_TYPE		= -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)
OPT_COMPILER		= -DCMAKE_CXX_COMPILER=$(CXX)

define Options =
	-G 'Unix Makefiles'\
	$(OPT_BUILD_TYPE)\
	$(OPT_COMPILER)\
	$(ADDITIONAL_CMAKE_OPTION)
endef

ifdef MAKE_GDBINIT
	MAKE_GDBINIT_CMD := \
		cd $(PWD);\
		python3 $(CURRENT_MAKEDIR_PATH)/make_gdbinit.py $(PWD) $(LIB_NAME) $(WORK_DIR)/.gdbinit;
else
	MAKE_GDBINIT_CMD :=
endif

CMake = \
	mkdir -p $(WORK_DIR);\
	cd $(WORK_DIR);\
	cmake $(PWD) $(Options);\
	$(MAKE_GDBINIT_CMD)\
	$(ADDITIONAL_CMD)

ifdef MAKE_COMPILECOMMANDS_LINK
	MakeLink := ln -sf $(WORK_DIR)/compile_commands.json ./
else
	MakeLink :=
endif

Make = \
	cd $(WORK_DIR);\
	make -j$(JOBS);

Clean = \
	cd $(WORK_DIR);\
	make clean;\
	rm -f Makefile CMakeCache.txt;\
	rm -r CMakeFiles;

.PHONY: cmake clean tags
all: $(WORK_DIR)/Makefile
	$(call Make)
cmake:
	$(call CMake)
	$(call MakeLink)
$(WORK_DIR)/Makefile:
	$(call CMake)
	$(call MakeLink)
clean:
	$(call Clean)
tags:
	@ctags -R -f ./.git/ctags .
	@cscope -b -f ./.git/cscope.out
test:
	cd $(WORK_DIR);\
	pwd;\
	ctest -j$(JOBS);
