//+-------------------------------------------------------------------------
//
//  Microsoft Windows
//
//  Copyright (C) Microsoft Corporation, 2005 - 2006
//
//  File:       bitsctr.h
//
//--------------------------------------------------------------------------

//
//  bitsctr.h
//
//  Offset definition file for exensible counter objects and counters
//
//  These "relative" offsets must start at 0 and be multiples of 2 (i.e.
//  even numbers). In the Open Procedure, they will be added to the
//  "First Counter" and "First Help" values of the device they belong to,
//  in order to determine the  absolute location of the counter and
//  object names and corresponding help text in the registry.
//
//  this file is used by the extensible counter DLL code as well as the
//  counter name and help text definition file (.INI) file that is used
//  by LODCTR to load the names into the registry.
//
//  We use a version number to keep track of which set of counters we are
//  using, and whether the performance counters in the registry need to be
//  reloaded.  If you add or delete any counters, please change the version
//  number at the end of this file.
//

#define	BITS_PERF 0
#define BITS_SERVER_SPEED 2
#define BITS_NETCARD_SPEED 4
#define BITS_NETCARD_PERCENT_FREE 6
#define BITS_IGD_SPEED 8
#define BITS_IGD_PERCENT_FREE 10
#define BITS_BLOCK_SIZE 12
#define BITS_BLOCK_INTERVAL 14
#define BITS_EST_FREE_BANDWIDTH 16

 