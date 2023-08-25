# Copyright © 2017, Microsoft Corporation. All rights reserved.
# ==============================================================================

# ==============================================================================
# Functions
#	Get-ARMCompression
#	ARM-Zip
#	Get-SizeFormat
#	Test-DomainJoined
#	Update-TimeSource
#	Get-PendingReboot
#	Search-UpdatesAvailable
#*=================================================================================

#*=================================================================================
#Arm Compression code
#*=================================================================================
Function Get-ARMCompression()
{

$str = @'
using System;
using System.Collections.Generic;

using System.Text;
using System.IO;
using System.Diagnostics;
using System.IO.Compression;

	 namespace Compressions
	 {
		 public class OutputDataPackage
		 {
			 string fileName;
			 ZipArchive z;
			 FileStream fileStream;
			 ZipArchiveEntry zae;
			 public string FileName
			 {
				 get
				 {
					 return fileName;
				 }
			 }


			 public OutputDataPackage()
			 {
				 string dt = String.Format("{0:yyyy-MM-dd_hh-mm-ss}", DateTime.Now);
				 string filePath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
				 fileName = filePath +@"\RoamingLog"+dt+".zip";

				 fileStream = new FileStream(fileName, FileMode.Create);

				 z = new ZipArchive(fileStream, ZipArchiveMode.Create);

			 }

			 public OutputDataPackage(string outputPackagePath)
			 {
				 DateTime dt = DateTime.Now;
				 this.fileName = outputPackagePath;
				 fileStream = new FileStream(this.fileName, FileMode.Create);
				 z = new ZipArchive(fileStream, ZipArchiveMode.Create);
			 }

			 public OutputDataPackage(string outputPackagePath,bool overwrite)
			 {
				if(overwrite)
				{
					 DateTime dt = DateTime.Now;
					 this.fileName = outputPackagePath;
					 fileStream = new FileStream(this.fileName, FileMode.Create);
					 z = new ZipArchive(fileStream, ZipArchiveMode.Create);
				 }
           			 else
            			{
                			DateTime dt = DateTime.Now;
                			this.fileName = outputPackagePath;
                			fileStream = new FileStream(this.fileName, FileMode.OpenOrCreate);
                			z = new ZipArchive(fileStream, ZipArchiveMode.Update);
            			}
			 }
			 // Add a file to the package using the specified path on disk and path in package
			 //   Example call: "outputPackage.AddFile("temp.txt", new Uri("/temp.txt", UriKind.RelativeOrAbsolute));"
			 //
			 public void AddFile(String pathOnDisk, String pathInZip)
			 {

				 zae = z.CreateEntry(pathInZip, CompressionLevel.Fastest);
				 FileStream fs = new FileStream(pathOnDisk, FileMode.Open, FileAccess.Read);
				 using (Stream s = zae.Open())
				 {
					 fs.CopyTo(s);
				 }

				 fs.Close();

			 }

			 // Saves the package out
			 public void Close()
			 {
				 z.Dispose();

			 }


		 }
	 }
'@

	add-type $str -ReferencedAssemblies "System.IO.Compression"

}

#****************************************************************************************************
#ARM-Zip
#Params $srcdir,$destDir - Works on all Win 8 including ARM
#****************************************************************************************************
Function ARM-Zip()
{
	param([string]$srcdir,$destDir)
	
	Get-ARMCompression
	$obj = new-object Compressions.OutputDataPackage($destDir)
	get-childitem $srcdir -force -recurse -ea SilentlyContinue|?{!([system.io.directory]::Exists($_.FullName))}|%{
	$relativepath = [system.io.path]::GetFullPath($_.FullName).SubString([system.io.path]::GetFullPath($srcdir).Length + 1);
	$obj.AddFile($_.FullName.ToString(),$relativepath.ToString() -as [system.uri]) 2>$null
	}
	$obj.Close()
}

#*=================================================================================
#Get-SizeFormat
#*=================================================================================
function Get-SizeFormat ()
{ 
     param($length)    
	 
     if($length -gt 1gb)
     {
         $use=1gb;$ext="GB"
     }
     elseif($length -gt 1mb)
     {
        $use=1mb;$ext="MB"
     }
     else
     {
        $use=1kb;$ext="KB"
     }
    $size = [math]::Round($length/$use,2) 
    $size=$size.ToString()+"$ext"
    return $size     
}

#*=================================================================================
#Test-DomainJoined
#*=================================================================================
# Function to check whether the current machine is domain joined
Function Test-DomainJoined()
{
    return (Get-WmiObject -query "select * from win32_ntdomain where Status ='OK'") -ne $null
}

#*=================================================================================
#Update-TimeSource
# Function to update time source
#*=================================================================================
Function Update-TimeSource([string]$timeSource = $(throw "No time source is specified"))
{
    w32tm.exe /config /update /manualpeerlist:"$timeSource"
}
