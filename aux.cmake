# ファイルリスト[FILELIST]からキーワードリスト[KEYLIST]に該当する物は個別にexecutableを作成、リストから除外
function(MakeSeparationTest PREFIX KEYLIST FILELIST LIBS)
	set(FILELIST_R ${${FILELIST}})
	foreach(KEY IN LISTS KEYLIST)
		ExtractByKeyword(${KEY} FILELIST_R RESULT)
		foreach(SRC IN LISTS RESULT)
			GetFilename(${SRC} FN)
			AddTest(${PREFIX} ${FN} ${SRC} "${LIBS}")
		endforeach()
		list(REMOVE_ITEM FILELIST_R ${RESULT})
	endforeach()
	set(${FILELIST} ${FILELIST_R} PARENT_SCOPE)
endfunction()

# パス文字列PTHからファイル名を取り出し、DSTへ格納
function(GetFileName PTH DST)
	string(REGEX MATCH "(.*/)([^\\.]+)\\.(.*)" RES ${PTH})
	if(RES)
		set(${DST} ${CMAKE_MATCH_2} PARENT_SCOPE)
	endif()
endfunction()

function(LoadGTestLibs LIBS)
	find_package(Threads REQUIRED)
	find_package(GTest REQUIRED)
	include_directories(${GTEST_INCLUDE_DIRS})
	set(${LIBS}
		${CMAKE_THREAD_LIBS_INIT}
		${GTEST_LIBRARIES}
		${GTEST_MAIN_LIBRARIES}
		PARENT_SCOPE
	)
endfunction()

# リストSRCのソースファイルを用いてPREFIX_SUBNAME という名前でテストexecutableを作成
function(AddTest PREFIX SUBNAME SRC LIBS)
	list(LENGTH SRC LEN)
	if(${LEN} GREATER 0)
		string(CONCAT EXENAME ${PREFIX} _ ${SUBNAME})
		add_executable(${EXENAME} ${SRC})
		target_link_libraries(${EXENAME}
			${LIBS}
		)
		add_test(
			NAME ${SUBNAME}
			COMMAND $<TARGET_FILE:${EXENAME}>
		)
	endif()
endfunction()

# リスト[DATA]からKEYを含むソースファイル名をピックアップし[RESULT]へ格納
function(ExtractByKeyword KEY DATA RESULT)
	set(DATA_R ${${DATA}})
	foreach(D IN LISTS DATA_R)
		string(REGEX MATCH "(.*/)*.*${KEY}.*\\.cpp" MR ${D})
		if(MR)
			list(APPEND RES ${D})
		endif()
	endforeach()
	set(${RESULT} ${RES} PARENT_SCOPE)
endfunction()

# コンパイラ毎の処理分岐
function(BranchByCompiler Dst)
	set(Opt_Flags "")
	set(Opt_Single "")
	set(Opt_Multi CLANG GCC)
	cmake_parse_arguments(ACF "${Opt_Flags}" "${Opt_Single}" "${Opt_Multi}" ${ARGN})

	if(${CMAKE_CXX_COMPILER_ID} MATCHES ".*(C|c)lang")
		message(STATUS "Using clang...")
		set(${Dst} "${ACF_CLANG}" PARENT_SCOPE)
	elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
		message(STATUS "Using gcc...")
		set(${Dst} "${ACF_GCC}" PARENT_SCOPE)
	endif()
endfunction()
