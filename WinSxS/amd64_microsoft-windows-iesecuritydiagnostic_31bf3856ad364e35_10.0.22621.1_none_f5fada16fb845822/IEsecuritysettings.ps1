# Copyright © 2008, Microsoft Corporation. All rights reserved.


$methodDefinition = @"

using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Collections;
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct ZONEATTRIBUTES
    {
        public UInt32 cbSize;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
        public String szDisplayName;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 200)]
        public String szDescription;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
        public String szIconPath;
        public UInt32 dwTemplateMinLevel;
        public UInt32 dwTemplateRecommended;
        public UInt32 dwTemplateCurrentLevel;
        public UInt32 dwFlags;                     // ZAFLAGS.
    };

    enum URLZONEREG
    {
        URLZONEREG_DEFAULT=0,
        URLZONEREG_HKLM,
        URLZONEREG_HKCU
    };

    enum URLZONE
    {
        URLZONE_INVALID = -1,               // Invalid Zone. Should only be used if no appropriate zone available.
        URLZONE_PREDEFINED_MIN = 0,
        URLZONE_LOCAL_MACHINE = 0,         // local machine zone is not exposed in UI
        URLZONE_INTRANET,                   // My Intranet zone
        URLZONE_TRUSTED,                    // Trusted Web sites zone
        URLZONE_INTERNET,                   // The Internet zone
        URLZONE_UNTRUSTED,                  // Untrusted sites zone
        URLZONE_PREDEFINED_MAX = 999,

        URLZONE_USER_MIN = 1000,
        URLZONE_USER_MAX = 10000,
    };

    enum tagURLTEMPLATE
    {
        // This value is just used to indicate the current set
        // of policies are not based on any template.
        URLTEMPLATE_CUSTOM = 0x000000,

        URLTEMPLATE_PREDEFINED_MIN = 0x10000,
        URLTEMPLATE_LOW = 0x10000,
        URLTEMPLATE_MEDLOW = 0x10500,
        URLTEMPLATE_MEDIUM = 0x11000,
        URLTEMPLATE_MEDHIGH = 0x11500,
        URLTEMPLATE_HIGH = 0x12000,
        URLTEMPLATE_PREDEFINED_MAX = 0x20000
    }

    enum ZAFLAGS
    {
        ZAFLAGS_CUSTOM_EDIT = 0x00000001,
        ZAFLAGS_ADD_SITES = 0x00000002,
        ZAFLAGS_REQUIRE_VERIFICATION = 0x00000004,
        ZAFLAGS_INCLUDE_PROXY_OVERRIDE = 0x00000008,  // Intranet only.
        ZAFLAGS_INCLUDE_INTRANET_SITES = 0x00000010,  // Intranet only.
        ZAFLAGS_NO_UI = 0x00000020,  // Don't display UI (used for local machine)
        ZAFLAGS_SUPPORTS_VERIFICATION = 0x00000040,  // Supports server verification.
        ZAFLAGS_UNC_AS_INTRANET = 0x00000080,
        ZAFLAGS_DETECT_INTRANET = 0x00000100,  // Intranet only.

        // Locked/Unlocked state specific flags.
        ZAFLAGS_USE_LOCKED_ZONES = 0x00010000,
        // Used ONLY in GetZoneAttributes to specify that Template Matching should be done to verify
        // that zone's Current Level is correct.
        ZAFLAGS_VERIFY_TEMPLATE_SETTINGS = 0x00020000,
        // Bypass the zonemgr cache for this setting
        ZAFLAGS_NO_CACHE = 0x00040000,
    };

  [
    ComImport,
    Guid("EDC17559-DD5D-4846-8EEF-8BECBA5A4ABF"),
    InterfaceType(ComInterfaceType.InterfaceIsIUnknown)
  ]
    interface IInternetZoneManagerEx2
  {
     void GetZoneAttributes
    (
        [In]    uint dwZone,
        ref ZONEATTRIBUTES pZoneAttributes
    );


       int SetZoneAttributes
      (
          [In]    uint dwZone,
          ref ZONEATTRIBUTES pZoneAttributes
      );



       void GetZoneCustomPolicy
      (
          [In]    uint dwZone,     // zone index
          ref    Guid  guidKey,    // key to lookup value
          [Out]   IntPtr  // allocation via IMemAlloc; caller frees
                    ppPolicy,   // pointer to output buffer pointer
          [Out]   IntPtr pcbPolicy,  // pointer to output buffer size
          [In]    URLZONEREG urlZoneReg    // effective, HKCU, or HKLM
      );

       void SetZoneCustomPolicy
      (
          [In]    uint dwZone,     // zone index
          ref    Guid  guidKey,    // key to lookup value
          [In]    IntPtr pPolicy,    // input buffer pointer
          [In]    uint cbPolicy,   // input data size
          [In]    URLZONEREG urlZoneReg    // default, HKCU, or HKLM
      );

      int GetZoneActionPolicy
      (
          uint dwZone,     // zone index
          uint dwAction,   // index number of action
          ref uint pPolicy,    // output buffer pointer
          uint cbPolicy,    // output buffer size
          URLZONEREG urlZoneReg // effective, HKCU, or HKLM
      );

      int SetZoneActionPolicy
      (
          uint dwZone,     // zone index
          uint dwAction,   // index number of action
          ref uint pPolicy,    // input buffer pointer
          uint cbPolicy,    // input data size
          URLZONEREG urlZoneReg // HKCU, or HKLM
      );

      // UI, logging, and wrapper for both
      // This function is not implemented yet.
      void PromptAction
      (
          [In]    uint dwAction,                    // action type
          [In]    uint hwndParent,                    // parent window handle
          [In]    string pwszUrl,                    // URL to display
          [In]    string pwszText,                    // dialog text
          [In]    uint dwPromptFlags                // reserved, pass 0
      );
      // This method presents UI to ask user about specified action


      // This function is not implemented.
      void LogAction
      (
          [In]    uint dwAction,       // action type
          [In]    string pwszUrl,        // URL to log
          [In]    string pwszText,       // associated text
          [In]    uint dwLogFlags      // reserved, pass 0
      );


      // zone enumeration

      int CreateZoneEnumerator
      (
          ref uint pdwEnum,        // enum handle
          ref uint pdwCount,       // # of elements in the list.
          [In]    uint dwFlags         // reserved, pass 0
      );
      // Returns enumerator handle needed to enumerate defined zones.
      // The zone enumeration corresponds to a snap-shot of the zones when
      // the Create call is made.

      int GetZoneAt
      (
          [In]    uint dwEnum,         // returned by CreateZoneEnumerator
          [In]    uint dwIndex,        // 0-based
          ref  uint pdwZone        // absolute zone index.
      );


      void DestroyZoneEnumerator
      (
          [In]    uint dwEnum         // enum handle
      );
      // Destroys resources associated with an enumerator


      void CopyTemplatePoliciesToZone
      (
          [In]    uint dwTemplate,       // High, medium or low
          [In]    uint dwZone,           // Zone to copy policies to.
          [In]    uint dwReserved
      );


      void GetZoneActionPolicyEx
     (
         [In]    uint dwZone,     // zone index
         [In]    uint dwAction,   // index number of action
         [Out]   IntPtr pPolicy,    // output buffer pointer
         [In]    uint cbPolicy,    // output buffer size
         [In]    URLZONEREG urlZoneReg, // effective, HKCU, or HKLM
         [In]    uint dwFlags   //Lockdown Zones or Normal Zones via ZAFLAGS
     );


      void SetZoneActionPolicyEx
      (
          [In]    uint dwZone,     // zone index
          [In]    uint dwAction,   // index number of action
          [In]    IntPtr pPolicy,    // input buffer pointer
          [In]    uint cbPolicy,    // input data size
          [In]    URLZONEREG urlZoneReg, // HKCU, or HKLM
          [In]    uint dwFlags   //Lockdown Zones or Normal Zones via ZAFLAGS
      );

    int GetZoneAttributesEx
    (
        [In]    uint   dwZone,
        ref     ZONEATTRIBUTES pZoneAttributes,
        [In]    uint    dwFlags // can only be ZAFLAGS_VERIFY_TEMPLATE_SETTINGS
    );

    void GetZoneSecurityState
    (
        [In] uint dwZoneIndex,
        [In] bool fRespectPolicy,
        ref IntPtr pdwState,
        ref bool pfPolicyEncountered
    );

    void GetIESecurityState
    (
        [In] bool fRespectPolicy,
        ref IntPtr pdwState,
        ref bool pfPolicyEncountered,
        [In] bool fNoCache
    );

    void FixUnsecureSettings();

}


  [ComImport, Guid("7b8a2d95-0ac9-11d1-896c-00c04fb6bfc4")]
  class InternetZoneManagerEx2 {}

  public class IERepair
  {
      private IInternetZoneManagerEx2 coClass = null;

      uint uZoneEnum;
      uint uZoneCount;

      uint URLACTION_LOWRIGHTS = 0x00002500;
      uint uCurrentPolicy = 0; //current policy for protect mode
      uint uDefaultPolicy = 0; //default policy for protect mode

      public IERepair()
      {
          coClass = (IInternetZoneManagerEx2)new InternetZoneManagerEx2();
      }

      // This is the "big hammer" function to repair any settings that are not secure.
      // We will need to define more granular functions that tell us which zones settings were not secure,
      // and what the unsecure settings were...
        public Hashtable RepairIESettings()
        {
            Hashtable ZoneHash = new Hashtable();
            if (coClass != null)
            {
                int res = coClass.CreateZoneEnumerator(ref uZoneEnum, ref uZoneCount, 0);
                if (res == 0)
                {
                    for (uint i = 0; i < uZoneCount; i++)
                    {
                        uint uZone = 0;
                        ZONEATTRIBUTES zoneatt = new ZONEATTRIBUTES();
                        res = coClass.GetZoneAt(uZoneEnum, i, ref uZone);
                        if (res == 0)
                        {
                            res = coClass.GetZoneAttributesEx(uZone, ref zoneatt, (uint)ZAFLAGS.ZAFLAGS_VERIFY_TEMPLATE_SETTINGS);

                            if (res == 0)
                            {
                                if (zoneatt.dwTemplateCurrentLevel != zoneatt.dwTemplateRecommended)
                                {
                                    zoneatt.dwTemplateCurrentLevel = zoneatt.dwTemplateRecommended;
                                    res = coClass.SetZoneAttributes(uZone, ref zoneatt);
                                    if (res == 0)
                                    {
                                        ZoneHash.Add(zoneatt.szDisplayName, zoneatt);
                                    }
                                }
                            }
                        }

                    }

                }

            }
            return ZoneHash;
        }
        public Hashtable CheckIESettings()
        {
            Hashtable ZoneHash = new Hashtable();
            if (coClass != null)
            {
                int res = coClass.CreateZoneEnumerator(ref uZoneEnum, ref uZoneCount, 0);
                if (res == 0)
                {
                    for (uint i = 0; i < uZoneCount; i++)
                    {
                        uint uZone = 0;
                        ZONEATTRIBUTES zoneatt = new ZONEATTRIBUTES();
                        res = coClass.GetZoneAt(uZoneEnum, i, ref uZone);
                        if (res == 0)
                        {
                            res = coClass.GetZoneAttributesEx(uZone, ref zoneatt, (uint)ZAFLAGS.ZAFLAGS_VERIFY_TEMPLATE_SETTINGS);

                            if (res == 0)
                            {
                                if (zoneatt.dwTemplateCurrentLevel != zoneatt.dwTemplateRecommended)
                                {
                                    ZoneHash.Add(zoneatt.szDisplayName, zoneatt);
                                }
                            }
                        }

                    }

                }

            }
            return ZoneHash;
        }
        public Hashtable GetIEZones()
        {
            Hashtable ZoneHash = new Hashtable();
            if (coClass != null)
            {
                int res = coClass.CreateZoneEnumerator(ref uZoneEnum, ref uZoneCount, 0);
                if (res == 0)
                {
                    for (uint i = 0; i < uZoneCount; i++)
                    {
                        uint uZone = 0;
                        ZONEATTRIBUTES zoneatt = new ZONEATTRIBUTES();
                        res = coClass.GetZoneAt(uZoneEnum, i, ref uZone);
                        if (res == 0)
                        {
                            res = coClass.GetZoneAttributesEx(uZone, ref zoneatt, (uint)ZAFLAGS.ZAFLAGS_VERIFY_TEMPLATE_SETTINGS);

                            if (res == 0)
                            {
                                ZoneHash.Add(zoneatt.szDisplayName, zoneatt);
                            }
                        }

                    }

                }

            }
            return ZoneHash;
        }
        public Hashtable CheckIEProtectMode()
        {
            Hashtable ZoneHash = new Hashtable();
            if (coClass != null)
            {
                int res = coClass.CreateZoneEnumerator(ref uZoneEnum, ref uZoneCount, 0);
                if (res == 0)
                {
                    for (uint i = 0; i < uZoneCount; i++)
                    {
                        uint uZone = 0;
                        res = coClass.GetZoneAt(uZoneEnum, i, ref uZone);
                        ZONEATTRIBUTES zoneatt = new ZONEATTRIBUTES();

                        if (res == 0)
                        {
                            // check the IE protect mode for each zone
                            res = coClass.GetZoneAttributesEx(uZone, ref zoneatt, (uint)ZAFLAGS.ZAFLAGS_VERIFY_TEMPLATE_SETTINGS);

                            if (res == 0)
                            {
                                coClass.GetZoneActionPolicy(uZone, URLACTION_LOWRIGHTS, ref uCurrentPolicy, sizeof(uint), URLZONEREG.URLZONEREG_DEFAULT);

                                coClass.GetZoneActionPolicy(uZone, URLACTION_LOWRIGHTS, ref uDefaultPolicy, sizeof(uint), URLZONEREG.URLZONEREG_HKLM);

                                if (uCurrentPolicy != uDefaultPolicy)
                                {
                                    ZoneHash.Add(zoneatt.szDisplayName, uCurrentPolicy);
                                }
                            }
                        }

                    }

                }

            }
            return ZoneHash;
        }

        public Hashtable RepairIEProtectMode()
        {
            Hashtable ZoneHash = new Hashtable();
            if (coClass != null)
            {
                int res = coClass.CreateZoneEnumerator(ref uZoneEnum, ref uZoneCount, 0);
                if (res == 0)
                {
                    for (uint i = 0; i < uZoneCount; i++)
                    {
                        uint uZone = 0;
                        res = coClass.GetZoneAt(uZoneEnum, i, ref uZone);
                        ZONEATTRIBUTES zoneatt = new ZONEATTRIBUTES();

                        if (res == 0)
                        {
                            // Repair the IE protect mode for each zone
                            res = coClass.GetZoneAttributesEx(uZone, ref zoneatt, (uint)ZAFLAGS.ZAFLAGS_VERIFY_TEMPLATE_SETTINGS);

                            if (res == 0)
                            {
                                coClass.GetZoneActionPolicy(uZone, URLACTION_LOWRIGHTS, ref uCurrentPolicy, sizeof(uint), URLZONEREG.URLZONEREG_DEFAULT);

                                coClass.GetZoneActionPolicy(uZone, URLACTION_LOWRIGHTS, ref uDefaultPolicy, sizeof(uint), URLZONEREG.URLZONEREG_HKLM);

                                if (uCurrentPolicy != uDefaultPolicy)
                                {
                                    res = coClass.SetZoneActionPolicy(uZone, URLACTION_LOWRIGHTS, ref uDefaultPolicy, sizeof(uint), URLZONEREG.URLZONEREG_DEFAULT);
                                    ZoneHash.Add(zoneatt.szDisplayName, uDefaultPolicy);
                                }
                            }
                        }

                    }

                }

            }
            return ZoneHash;
        }

  }

"@

Add-Type -TypeDefinition $methodDefinition
$IERepairtype = [IERepair]
$IERepair = new-object $IERepairtype -ErrorAction Stop
