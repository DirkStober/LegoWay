# Target specific macros
FILE_NAME=lqg
TARGET = $(FILE_NAME)_OSEK
TARGET_SOURCES = $(FILE_NAME).c lqg_lego_controller.c
TOPPERS_OSEK_OIL_SOURCE = ./$(FILE_NAME).oil
NXTOSEK_PATH=/home/dirk/embedded_workspace/nxtOSEK/

# Don't modify below part
O_PATH ?= build
include $(NXTOSEK_PATH)ecrobot/ecrobot.mak
