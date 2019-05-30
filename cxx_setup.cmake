# ライブラリ共通で使用するcmakeのセッティングファイル
cmake_minimum_required(VERSION 3.7)

# Versionに 11や14などを指定
function(SetupCXX Version)
	enable_language(CXX)
# C++バージョンを指定
	set(CMAKE_CXX_STANDARD ${Version} PARENT_SCOPE)
	set(CMAKE_CXX_STANDARD_REQUIRED ON PARENT_SCOPE)
# コンパイラ依存の拡張をオフにする
	set(CMAKE_CXX_EXTENSIONS OFF PARENT_SCOPE)

	set(CMAKE_CXX_FLAGS_DEBUG
		"${CMAKE_CXX_FLAGS_DEBUG} -O0 -ggdb3"
		PARENT_SCOPE)
	set(CMAKE_CXX_FLAGS_RELEASE
		"${CMAKE_CXX_FLAGS_RELEASE} -O3"
		PARENT_SCOPE)
	set(CMAKE_CXX_FLAGS
		"${CMAKE_CXX_FLAGS} -pedantic -Wall -Wextra -ftemplate-depth=1024"
		PARENT_SCOPE)
	if(CMAKE_BUILD_TYPE STREQUAL "Debug")
		# デバッグビルドの際はGLibのデバッグモードをONにする
		add_definitions(-D_GLIBCXX_DEBUG)
		add_definitions(-DDEBUG)
	endif()

	cmake_parse_arguments(SetupCXX "CompileCommands" "" "" ${ARGN})
	if(SetupCXX_CompileCommands)
		set(CMAKE_EXPORT_COMPILE_COMMANDS ON PARENT_SCOPE)
	endif()
endfunction()
