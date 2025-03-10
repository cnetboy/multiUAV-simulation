#
# OMNeT++/OMNEST Makefile for multiUAV-simulation
#
# This file was generated with the command:
#  opp_makemake -f --deep -DWITH_OSG -DWITH_OSGEARTH
#

# Name of target to be created (-o option)
TARGET = multiUAV-simulation$(D)$(EXE_SUFFIX)
TARGET_DIR = .

# User interface (uncomment one) (-u option)
USERIF_LIBS = $(ALL_ENV_LIBS) # that is, $(TKENV_LIBS) $(QTENV_LIBS) $(CMDENV_LIBS)
#USERIF_LIBS = $(CMDENV_LIBS)
#USERIF_LIBS = $(TKENV_LIBS)
#USERIF_LIBS = $(QTENV_LIBS)

# C++ include paths (with -I)
INCLUDE_PATH =

# Additional object and library files to link with
EXTRA_OBJS =

# Additional libraries (-L, -l options)
LIBS =

# Output directory
PROJECT_OUTPUT_DIR = out
PROJECTRELATIVE_PATH =
O = $(PROJECT_OUTPUT_DIR)/$(CONFIGNAME)/$(PROJECTRELATIVE_PATH)

# Object files for local .cc, .msg and .sm files
OBJS = \
    $O/Battery.o \
    $O/ChannelController.o \
    $O/ChargeAlgorithmCCCV.o \
    $O/ChargeAlgorithmCCCVCurrent.o \
    $O/ChargingNode.o \
    $O/ChargingNodeSpotElement.o \
    $O/Command.o \
    $O/CommandExecEngine.o \
    $O/fallback.o \
    $O/GenericNode.o \
    $O/MissionControl.o \
    $O/MissionControlDataMap.o \
    $O/MobileNode.o \
    $O/OsgEarthScene.o \
    $O/ReplacementData.o \
    $O/UAVNode.o \
    $O/msgs/CmdCompletedMsg_m.o \
    $O/msgs/ExchangeCompletedMsg_m.o \
    $O/msgs/ForecastPointInTimeRequest_m.o \
    $O/msgs/ForecastResponse_m.o \
    $O/msgs/ForecastTargetRequest_m.o \
    $O/msgs/MissionMsg_m.o \
    $O/msgs/MobileNodeRequest_m.o \
    $O/msgs/MobileNodeResponse_m.o \
    $O/msgs/ReserveSpotMsg_m.o \
    $O/msgs/UpdateChargingMsg_m.o

# Message files
MSGFILES = \
    msgs/CmdCompletedMsg.msg \
    msgs/ExchangeCompletedMsg.msg \
    msgs/ForecastPointInTimeRequest.msg \
    msgs/ForecastResponse.msg \
    msgs/ForecastTargetRequest.msg \
    msgs/MissionMsg.msg \
    msgs/MobileNodeRequest.msg \
    msgs/MobileNodeResponse.msg \
    msgs/ReserveSpotMsg.msg \
    msgs/UpdateChargingMsg.msg

# SM files
SMFILES =

#------------------------------------------------------------------------------

# Pull in OMNeT++ configuration (Makefile.inc)

ifneq ("$(OMNETPP_CONFIGFILE)","")
CONFIGFILE = $(OMNETPP_CONFIGFILE)
else
ifneq ("$(OMNETPP_ROOT)","")
CONFIGFILE = $(OMNETPP_ROOT)/Makefile.inc
else
CONFIGFILE = $(shell opp_configfilepath)
endif
endif

ifeq ("$(wildcard $(CONFIGFILE))","")
$(error Config file '$(CONFIGFILE)' does not exist -- add the OMNeT++ bin directory to the path so that opp_configfilepath can be found, or set the OMNETPP_CONFIGFILE variable to point to Makefile.inc)
endif

include $(CONFIGFILE)

# Simulation kernel and user interface libraries
OMNETPP_LIBS = $(OPPMAIN_LIB) $(USERIF_LIBS) $(KERNEL_LIBS) $(SYS_LIBS)

COPTS = $(CFLAGS) $(IMPORT_DEFINES) -DWITH_OSG -DWITH_OSGEARTH $(INCLUDE_PATH) -I$(OMNETPP_INCL_DIR)
MSGCOPTS = $(INCLUDE_PATH)
SMCOPTS =

# we want to recompile everything if COPTS changes,
# so we store COPTS into $COPTS_FILE and have object
# files depend on it (except when "make depend" was called)
COPTS_FILE = $O/.last-copts
ifneq ("$(COPTS)","$(shell cat $(COPTS_FILE) 2>/dev/null || echo '')")
$(shell $(MKPATH) "$O" && echo "$(COPTS)" >$(COPTS_FILE))
endif

#------------------------------------------------------------------------------
# User-supplied makefile fragment(s)
# >>>
# inserted from file 'makefrag':
# add required libraries for OpenSceneGraph and osgEarth
ifeq ($(WITH_OSG),yes)
OMNETPP_LIBS += $(filter-out $(USERIF_LIBS),$(OSG_LIBS) -losgAnimation)
endif
ifeq ($(WITH_OSGEARTH),yes)
OMNETPP_LIBS += $(filter-out $(USERIF_LIBS),$(OSGEARTH_LIBS) -losgEarthFeatures -losgEarthSymbology -losgEarthAnnotation)
endif

COPTS += -isystem $(OMNETPP_ROOT)/include-boost

# <<<
#------------------------------------------------------------------------------

# Main target
all: $(TARGET_DIR)/$(TARGET)

$(TARGET_DIR)/% :: $O/%
	@mkdir -p $(TARGET_DIR)
	$(Q)$(LN) $< $@
ifeq ($(TOOLCHAIN_NAME),clangc2)
	$(Q)-$(LN) $(<:%.dll=%.lib) $(@:%.dll=%.lib)
endif

$O/$(TARGET): $(OBJS)  $(wildcard $(EXTRA_OBJS)) Makefile $(CONFIGFILE)
	@$(MKPATH) $O
	@echo Creating executable: $@
	$(Q)$(CXX) $(LDFLAGS) -o $O/$(TARGET) $(OBJS) $(EXTRA_OBJS) $(AS_NEEDED_OFF) $(WHOLE_ARCHIVE_ON) $(LIBS) $(WHOLE_ARCHIVE_OFF) $(OMNETPP_LIBS)

.PHONY: all clean cleanall depend msgheaders smheaders

.SUFFIXES: .cc

$O/%.o: %.cc $(COPTS_FILE) | msgheaders smheaders
	@$(MKPATH) $(dir $@)
	$(qecho) "$<"
	$(Q)$(CXX) -c $(CXXFLAGS) $(COPTS) -o $@ $<

%_m.cc %_m.h: %.msg
	$(qecho) MSGC: $<
	$(Q)$(MSGC) -s _m.cc -MD -MP -MF $O/$(basename $@).d $(MSGCOPTS) $?

%_sm.cc %_sm.h: %.sm
	$(qecho) SMC: $<
	$(Q)$(SMC) -c++ -suffix cc $(SMCOPTS) $?

msgheaders: $(MSGFILES:.msg=_m.h)

smheaders: $(SMFILES:.sm=_sm.h)

clean:
	$(qecho) Cleaning $(TARGET)
	$(Q)-rm -rf $O
	$(Q)-rm -f $(TARGET_DIR)/$(TARGET)
	$(Q)-rm -f $(TARGET_DIR)/$(TARGET:%.dll=%.lib)
	$(Q)-rm -f $(call opp_rwildcard, . , *_m.cc *_m.h *_sm.cc *_sm.h)

cleanall:
	$(Q)$(MAKE) -s clean MODE=release
	$(Q)$(MAKE) -s clean MODE=debug
	$(Q)-rm -rf $(PROJECT_OUTPUT_DIR)

# include all dependencies
-include $(OBJS:%.o=%.d)
