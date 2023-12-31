# Localized	05/07/2022 02:18 AM (GMT)	303:7.0.30723 	BitLockerStrings.psd1
ConvertFrom-StringData -stringdata @' 
###PSLOC
ErrorMountPointNotFound={0} does not have an associated BitLocker volume.
ErrorVolumeNotFound=Device Id: {0} does not have a corresponding volume.
ErrorVolumeBoundAlready=This key protector cannot be deleted because it is being used to automatically unlock the volume.
ErrorOperatingSystemMountPointNotFound=An operating system volume could not be found.
WarningUsedSpaceOnlyAndHardwareEncryption=UsedSpaceOnly switch and HardwareEncryption switch cannot be used together. Ignoring UsedSpaceOnly.
ErrorExternalKeyOrPasswordRequired=An external key or password protector is required to enable BitLocker on an operating system volume without a valid TPM.
WarningWriteDownRecoveryPassword=ACTIONS REQUIRED:{1}{1}1. Save this numerical recovery password in a secure location away from your computer:{1}{1}{0}{1}{1}To prevent data loss, save this password immediately. This password helps ensure that you can unlock the encrypted volume.
WarningWriteDownRecoveryPasswordInsertExternalKeyRestart=ACTIONS REQUIRED:{1}{1}1. Save this numerical recovery password in a secure location away from your computer:{1}{1}{0}{1}{1}To prevent data loss, save this password immediately. This password helps ensure that you can unlock the encrypted volume.{1}2.Insert a USB flash drive with an external key file into the computer.{1}3. Restart the computer to run a hardware test.{1}    (Type: get-help Restart-Computer for command line instructions.)
WarningWriteDownRecoveryPasswordRestart=ACTIONS REQUIRED:{1}{1}1. Save this numerical recovery password in a secure location away from your computer:{1}{1}{0}{1}{1}To prevent data loss, save this password immediately. This password helps ensure that you can unlock the encrypted volume.{1}2. Restart the computer to run a hardware test.{1}    (Type: get-help Restart-Computer for command line instructions.)
WarningHardwareTestFailed=ERROR: The hardware test failed with code 0x%1!08x!. All key protectors{0}were removed.{0}{0}Possible reasons that the hardware test failed are:{0}{0}1. A USB flash drive with an external key file was not found.{0}{0}- Insert a USB flash drive with an external key file into the computer.{0}- If this failure persists, the computer cannot read USB drives{0}during boot. You may not be able to use external keys to unlock{0}the OS volume during boot.{0}{0}2. The external key file on the USB flash drive was corrupt.{0}{0}- Try a different USB flash drive to store the external key file.{0}{0}3. The TPM is off.{0}{0}- To manage the Trusted Platform Module (TPM), use either the{0}TPM Management MMC snap-in or the TPM Management PowerShell cmdlets.{0}{0}4. The TPM detected a change in OS boot components.{0}{0}- Remove any bootable CD or DVD from the computer.{0}- If this failure persists, check that the latest firmware and BIOS{0}upgrades are installed, and that the TPM is otherwise working properly.{0}{0}5. The provided PIN was incorrect.{0}{0}6. The TPM storage root key (SRK) has an incompatible authorization value.{0}{0}- To reset this value, run the TPM Initialization Wizard.{0}{0}ACTIONS REQUIRED:{0}{0}1. Resolve the hardware test failure above.{0}2. Re-run the command to turn on BitLocker.{0}
WarningInsertExternalKeyRestart=ACTIONS REQUIRED:{0}{0}1.Insert a USB flash drive with an external key file into the computer.{0}2. Restart the computer to run a hardware test.{0}    (Type: get-help Restart-Computer for command line instructions.)
WarningRestart=ACTIONS REQUIRED:{0}{0}1. Restart the computer to run a hardware test.{0}    (Type: get-help Restart-Computer for command line instructions.)
ErrorSidProtectorRequiresAdditionalRecoveryProtector=To turn on BitLocker with a SID-based Identity protector on this volume, you must provide at least one additional protector for recovery.
ErrorRemoveDraProtector=Removal of the data recovery agent certificate must be done using the Certificates snap-in.
ErrorRemoveNkpProtector=Network Unlock can only be disabled within the BitLocker Drive Encryption group policy setting "Allow network unlock at startup", or by removing the Public Key Policies group policy setting "BitLocker Drive Encryption Network Unlock Certificate" on the domain controller.
PasswordPrompt=Enter Password:
ConfirmPasswordPrompt=Confirm Password:
NoMatchPassword=These passwords do not match. Please re-enter them.
PinPrompt=Enter Pin:
ConfirmPinPrompt=Confirm Pin:
NoMatchPin=These pins do not match. Please re-enter them.
ErrorGroupPolicyDisabledBackup=Group policy does not permit the storage of recovery information to Active Directory. The operation was not attempted.
'@
