# UBX-CFG-TP5 (0x06 0x31)
# Time Pulse Configuration
# For Ublox 8, version 16 through 22

uint8 CLASS_ID = 6
uint8 MESSAGE_ID = 49 

uint8 tpIdx              # Time Pulse Selection (0 = TIMEPULSE, 1 = TIMEPULSE2)

uint8 version            # Message version (0x01 for this version)

uint8[2] reserved1

int16 antCableDelay
int16 rfGroupDelay

uint32 freqPeriod        # Frequency or period time, depending on bit isFreq
uint32 freqPeriodLock    # Frequency or period time when locked to GNSS time,
                         # only used if lockedOtherSet is set
uint32 pulseLenRatio     # Pulse length or duty cycle, depending on isLength
uint32 pulseLenRatioLock # Pulse length or duty cycle when locked to GNSS time,
                         # only used if lockedOtherSet is set

int32 userConfigDelay

uint32 flags
uint32 FLAGS_ACTIVE          = 1 # if set enable time pulse;
  # if pin assigned to another function, other function takes precedence
uint32 FLAGS_LOCK_GNSS_FREQ  = 2 # if set synchronize time pulse to GPS
  # as soon as GPS time is valid, otherwise use local clock
uint32 FLAGS_LOCKED_OTHER_SET= 4 # if 0 then freqPeriod & pulseLenRatio used
  # if set use freqPeriodLock & pulseLenRatioLock as soon as GPS time is valid
  #   use freqPeriod and pulseLenRatio if GPS time is invalid,

uint32 FLAGS_IS_FREQ     = 8 # if set freqPeriodLock and freqPeriod
  # interpreted as frequency, otherwise interpreted as period
uint32 FLAGS_IS_LENGTH   =16 # if set pulseLenRatioLock and pulseLenRatio
  # interpreted as pulse length, otherwise interpreted as duty cycle
uint32 FLAGS_ALIGN_TO_TOW=32 # align pulse to top of second
  # (period time must be integer fraction of 1s)
uint32 FLAGS_POLARITY    =64 # pulse polarity at top of sec, 0=falling 1=rising


# Timegrid to use:
  # This flag is only relevant if lockGnssFreq and alignToTow are set.
uint32 FLAGS_GRID_UTC_GNSS_MASK   =1920 # 4 bits 0xf<<7=0x0780
uint32 FLAGS_GRID_UTC_GNSS_UTC    =   0 # timegrid to use: 0=UTC
uint32 FLAGS_GRID_UTC_GNSS_GPS    = 128 # timegrid to use: 1=GPS
uint32 FLAGS_GRID_UTC_GNSS_GLONASS= 256 # timegrid to use: 2=GCLONAS
  #TODO "3" and "4" could instead mean bit 3 512 and bit 4 1024, not 384 & 512:
uint32 FLAGS_GRID_UTC_GNSS_BEIDOU = 384 # timegrid to use: 3=BeiDou
uint32 FLAGS_GRID_UTC_GNSS_GALILEO= 512 # timegrid to use: 4=Galileo


# Sync Manager lock mode:
  # This field is only relevant for the FTS product variant.
  # This field is only relevant if the flag lockedOtherSet is set.
uint32 FLAGS_SYNC_MODE_MASK=14336 # 3 bits 0x7<<11=0x2800

  # 0: switch to freqPeriodLock and pulseLenRatioLock as soon as Sync Manager
  # has an accurate time,
uint32 FLAGS_SYNC_MODE_0=0 # 0: never switch back to freqPeriod & pulseLenRatio

  # 1: switch to freqPeriodLock and pulseLenRatioLock as soon as Sync Manager
  # has an accurate time,
uint32 FLAGS_SYNC_MODE_1=2048 # 1: switch back to freqPeriod & pulseLenRatio
  # as soon as time gets inaccurate
