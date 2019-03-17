# DEPEND_TARGET = 依存ターゲット名リスト
function(DefineCompDB DEPEND_TARGET)
	# compdbが存在すればそれを使ってcompile_commands.jsonを変換
	set(COMPDB compdb)
	execute_process(
		COMMAND ${COMPDB} "help"
		RESULT_VARIABLE HASNOT_COMPDB
	)
	set(COMP_JSON compile_commands.json)
	if(HASNOT_COMPDB)
		# compile_commands.jsonへのリンクを張る
		add_custom_target(compcmd ALL
			DEPENDS ${${DEPEND_TARGET}}
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_BINARY_DIR}/${COMP_JSON} ${CMAKE_SOURCE_DIR}/${COMP_JSON}
		)
	else()
		add_custom_target(compcmd ALL
			DEPENDS ${${DEPEND_TARGET}}
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			COMMAND ${COMPDB} list ">" "${CMAKE_SOURCE_DIR}/${COMP_JSON}"
		)
	endif()
endfunction()