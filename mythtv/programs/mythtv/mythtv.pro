######################################################################
# Automatically generated by qmake (1.02a) Tue Jul 16 21:01:49 2002
######################################################################

include ( ../../settings.pro )

TEMPLATE = app
CONFIG += thread
TARGET = mythtv
target.path = $${PREFIX}/bin
INSTALLS = target

INCLUDEPATH += ../../libs/libmythtv ../../libs
LIBS += -L../../libs/libmythtv -L../../libs/libavcodec -L../../libs/libmyth

LIBS += -lmythtv -lavcodec -lmyth-$$LIBVERSION -lXv -lXinerama -lmp3lame

TARGETDEPS += ../../libs/libmythtv/libmythtv.a
TARGETDEPS += ../../libs/libavcodec/libavcodec.a

DEPENDPATH += ../../libs/libmythtv ../../libs/libmyth ../../libs/libavcodec

# Input
SOURCES += main.cpp
