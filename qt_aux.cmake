# Qt5のセットアップルーチンなど

macro(BuildWithQt5 SRC PROJNAME)
	set(Lcl_Opt_Flags "")
	set(Lcl_Opt_Single "")
	set(Lcl_Opt_Multi UI_FILE TS_FILE MODULE LIB)
	cmake_parse_arguments(BQt5 "${Lcl_Opt_Flags}" "${Lcl_Opt_Single}" "${Lcl_Opt_Multi}" ${ARGN})

	set(CMAKE_AUTOMOC ON)
	set(CMAKE_AUTOUIC ON)
	set(CMAKE_INCLUDE_CURRENT_DIR ON)

	find_package(Qt5 COMPONENTS
		${BQt5_MODULE}
		REQUIRED
	)
	qt5_create_translation(QM_FILES
		"${SRC};${BQt5_UI_FILE}"
		${BQt5_TS_FILE}
	)
	add_executable(
		${PROJNAME}
		${SRC}
		${BQt5_UI_FILE}
		${QM_FILES}
	)
	# LinguistTools以外をリストアップ
	foreach(m IN LISTS BQt5_MODULE)
		if(NOT m STREQUAL "LinguistTools")
			list(APPEND Lcl_LinkLibs "Qt5::${m}")
		endif()
	endforeach()
	# 追加で依存ライブラリがあったらそれも加える
	foreach(lib IN LISTS BQt5_LIB)
		list(APPEND Lcl_LinkLibs "${lib}")
	endforeach()
	target_link_libraries(
		${PROJNAME}
		${Lcl_LinkLibs}
		${CMAKE_THREAD_LIBS_INIT}
	)
endmacro()
