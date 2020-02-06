# Find the wazuh shared library
find_library(WAZUHEXT NAMES libwazuhext.so HINTS "${SRC_FOLDER}")

if(NOT WAZUHEXT)
    message(FATAL_ERROR "libwazuhext not found! Aborting...")
endif()

# Add compiling flags
add_compile_options(-ggdb -O0 -g -coverage -DTEST_SERVER)

# Add server specific tests to the list
list(APPEND tests_names "test_syscheck_config")
list(APPEND tests_flags "-Wl,--wrap,_merror")

list(APPEND tests_names "test_syscheck")
list(APPEND tests_flags "-Wl,--wrap,_mwarn -Wl,--wrap,fim_db_init")

list(APPEND tests_names "test_fim_sync")
list(APPEND tests_flags "-Wl,--wrap,fim_send_sync_msg -Wl,--wrap,time -Wl,--wrap,_mwarn -Wl,--wrap,_mdebug1 \
                      -Wl,--wrap,_merror -Wl,--wrap,_mdebug2 -Wl,--wrap,queue_push_ex -Wl,--wrap,fim_db_get_row_path \
                       -Wl,--wrap,fim_db_get_data_checksum -Wl,--wrap,dbsync_check_msg -Wl,--wrap,fim_send_sync_msg \
                       -Wl,--wrap,fim_db_get_count_range -Wl,--wrap,fim_db_get_path -Wl,--wrap,fim_entry_json \
                       -Wl,--wrap,fim_db_data_checksum_range -Wl,--wrap,dbsync_state_msg \
                       -Wl,--wrap,fim_db_sync_path_range")

list(APPEND tests_names "test_run_check")
list(APPEND tests_flags "-Wl,--wrap,_minfo")

list(APPEND tests_names "test_syscheck_op")
list(APPEND tests_flags "-Wl,--wrap,rmdir_ex -Wl,--wrap,wreaddir -Wl,--wrap,_mdebug1 -Wl,--wrap,_mdebug2 \
                        -Wl,--wrap,_mwarn -Wl,--wrap,_merror -Wl,--wrap,getpwuid_r -Wl,--wrap,getgrgid \
                         -Wl,--wrap,cJSON_CreateArray -Wl,--wrap,cJSON_CreateObject -Wl,--wrap,wstr_split \
                         -Wl,--wrap,OS_ConnectUnixDomain -Wl,--wrap,OS_SendSecureTCP")

list(APPEND tests_names "test_fim_db")
list(APPEND tests_flags "-Wl,--wrap=w_is_file,--wrap=remove,--wrap=sqlite3_open_v2,--wrap=sqlite3_exec,--wrap=_merror \
                         -Wl,--wrap=sqlite3_prepare_v2,--wrap=sqlite3_step,--wrap=sqlite3_finalize,--wrap=sqlite3_close_v2 \
                         -Wl,--wrap=chmod,--wrap=sqlite3_free,--wrap=sqlite3_reset,--wrap=sqlite3_clear_bindings \
                         -Wl,--wrap=sqlite3_errmsg,--wrap=sqlite3_bind_int,--wrap=sqlite3_bind_text,--wrap=sqlite3_column_int \
                         -Wl,--wrap=sqlite3_column_text,--wrap=printf,--wrap=fim_send_sync_msg,--wrap=dbsync_state_msg \
                         -Wl,--wrap=fim_entry_json")

list(APPEND tests_names "test_wdb_fim")
list(APPEND tests_flags "-Wl,--wrap,_merror -Wl,--wrap,_mdebug1 -Wl,--wrap,cJSON_Parse -Wl,--wrap,wdb_begin2 \
                         -Wl,--wrap,cJSON_Delete -Wl,--wrap,cJSON_GetStringValue -Wl,--wrap,cJSON_IsNumber \
                         -Wl,--wrap,cJSON_IsObject -Wl,--wrap,wdb_stmt_cache -Wl,--wrap,sqlite3_bind_text \
                         -Wl,--wrap,sqlite3_bind_int64 -Wl,--wrap,sqlite3_step")

list(APPEND tests_names "test_wdb_parser")
list(APPEND tests_flags "-Wl,--wrap,_mdebug2 -Wl,--wrap,_mdebug1 -Wl,--wrap,_merror -Wl,--wrap,_mwarn \
                         -Wl,--wrap,wdb_scan_info_get -Wl,--wrap,wdb_fim_update_date_entry -Wl,--wrap,wdb_fim_clean_old_entries \
                         -Wl,--wrap,wdb_scan_info_update -Wl,--wrap,wdb_scan_info_fim_checks_control -Wl,--wrap,wdb_syscheck_load \
                         -Wl,--wrap,wdb_fim_delete -Wl,--wrap,wdb_syscheck_save -Wl,--wrap,wdb_syscheck_save2 \
                         -Wl,--wrap,wdbi_query_checksum -Wl,--wrap,wdbi_query_clear")

list(APPEND tests_names "test_analysisd_syscheck")
list(APPEND tests_flags "-Wl,--wrap,wdbc_query_ex -Wl,--wrap,wdbc_parse_result -Wl,--wrap,_merror -Wl,--wrap,_mdebug1")

list(APPEND tests_names "test_dbsync")
list(APPEND tests_flags "-Wl,--wrap,_merror -Wl,--wrap,OS_ConnectUnixDomain -Wl,--wrap,OS_SendSecureTCP \
                         -Wl,--wrap,connect_to_remoted -Wl,--wrap,send_msg_to_agent -Wl,--wrap,wdbc_query_ex \
                         -Wl,--wrap,wdbc_parse_result")

# Generate analysisd library
file(GLOB analysisd_files
    ../analysisd/*.o
    ../analysisd/cdb/*.o
    ../analysisd/decoders/*.o
    ../analysisd/decoders/plugins/*.o)

add_library(ANALYSISD_O STATIC ${analysisd_files})

set_source_files_properties(
    ${analysisd_files}
    PROPERTIES
    EXTERNAL_OBJECT true
    GENERATED true
)

set_target_properties(
    ANALYSISD_O
    PROPERTIES
    LINKER_LANGUAGE C
)

target_link_libraries(ANALYSISD_O ${WAZUHLIB} ${WAZUHEXT} -lpthread)

# Set tests dependencies
set(TEST_DEPS SYSCHECK_O ANALYSISD_O -lcmocka -fprofile-arcs -ftest-coverage)
