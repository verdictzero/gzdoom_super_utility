# GZDoom Super Utility ~ Attempt 6

Add-Type -AssemblyName System.Windows.Forms

# ---- change terminal to white on black, because A E S T H E T I C S  ----
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# ---- title and version info ----
$script:title = "GZDoom Super Utility"
$script:title_version_separator = " | "
$script:version = "A6_v1.00a"
$script:full_title = $title + $title_version_separator + $version

# ---- extra stuff ----
$script:title_deco_line = " =============================================== "
$script:title_deco_spacer = " === "
 
# ---- coloration info : title ---- 
$script:titleColors = @{
    ForegroundColor = "white"
    BackgroundColor = "darkblue"
}

# ---- coloration info : warning ---- 
$script:warningColors = @{
    ForegroundColor = "yellow"
    BackgroundColor = "black"
}

# ---- coloration info : success ---- 
$script:successColors = @{
    ForegroundColor = "green"
    BackgroundColor = "black"
}

# ---- coloration info : error ---- 
$script:errorColors = @{
    ForegroundColor = "red"
    BackgroundColor = "black"
}

# ---- coloration info : info ---- 
$script:infoColors = @{
    ForegroundColor = "cyan"
    BackgroundColor = "black"
}

# ---- coloration info : debug ---- 
$script:debugColors = @{
    ForegroundColor = "magenta"
    BackgroundColor = "black"
}

# ---- coloration info : debug alternate ---- 
$script:debugColors_alt = @{
    ForegroundColor = "darkgray"
    BackgroundColor = "black"
}


# ---- directory initialization ----
$script:project_root_directory = ""
$script:texture_import_source_directory = ""
$script:model_import_source_directory = ""

# +++++ +++++ +++++ START OF FUNCTION DEFINITION BLOCK +++++ +++++ +++++

# +++++ +++++ +++++ ZONE 1 START +++++ +++++ +++++

function Debug-EndOfScript {
    Write-Host "`n[ - DEBUG - ] - Script has finished." @script:debugColors
    Write-LineBreak
}

function Write-TryAgain {
    $asciiArt = @"
___________                       _____      ____          .__          
\__    ___/_______  ___.__.      /  _  \    / ___\ _____   |__|  ____   
  |    |   \_  __ \<   |  |     /  /_\  \  / /_/  >\__  \  |  | /    \  
  |    |    |  | \/ \___  |    /    |    \ \___  /  / __ \_|  ||   |  \ 
  |____|    |__|    / ____|    \____|__  //_____/  (____  /|__||___|  / 
                    \/                 \/               \/          \/  
"@

Write-LineBreak
Write-Host $asciiArt @errorColors
}

function Get-ScriptDirectory {
    $script:directory_this_script_is_being_run_from = $PSScriptRoot
}

function Debug-CheckResourcesFolder {
    # ---- define the path to the resources folder ----
    $resourcesPath = Join-Path -Path $script:directory_this_script_is_being_run_from -ChildPath 'resources'

    # ---- check if the resources directory exists ----
    if (-not (Test-Path -Path $resourcesPath -PathType Container)) {
        # ---- throw an error if the directory doesn't exist ----
        Write-Host "`n[ - ERROR - ] - Resources directory not found, fix that first." @script:errorColors
        Write-Host "[ - ERROR - ] - Exiting . . ." @script:errorColors
        Write-TryAgain 
        Write-LineBreak
        exit
    } 
    
    else {
        # ---- set the path if it exists ----
        $script:resourcesDirectoryPath = $resourcesPath
        Write-Host "`n[ - OK - ] - Resources directory found." @script:successColors
    }
}

function Debug-CheckForModelProxy {
    # ---- define the path to the resources folder ----
    $resourcesPath = Join-Path -Path $script:directory_this_script_is_being_run_from -ChildPath 'resources'

    # ---- define the path to the model_proxy.png file ----
    $modelProxyPath = Join-Path -Path $resourcesPath -ChildPath 'model_proxy.png'

    # ---- check if the model_proxy.png file exists ----
    if (-not (Test-Path -Path $modelProxyPath -PathType Leaf)) {
        # ---- throw an error if the file doesn't exist ----
        Write-Host "`n[ - ERROR - ] - 'model_proxy.png' not found, fix that first." @script:errorColors
        Write-Host "[ - ERROR - ] - Exiting . . ." @script:errorColors
        Write-TryAgain 
        Write-LineBreak
        exit
    } 
    
    else {
        # ---- set the path if it exists ----
        $script:modelProxyFilePath = $modelProxyPath
        Write-Host "`n[ - OK - ] - 'model_proxy.png' found." @script:successColors
    }
}

# ---- makes a linebreak ----
function Write-LineBreak {
    Write-Host "`n"
}

# ---- show the full title with text decorations ----
function Show-FullTitleWithDeco {
    Write-Host $script:title_deco_line @script:titleColors
    Write-Host $script:title_deco_spacer $script:full_title $script:title_deco_spacer @script:titleColors
    Write-Host $script:title_deco_line @script:titleColors
}

# ---- project directory selection function ----
function Select-ProjectRootDirectory {

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the project root directory"
    $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::Desktop
    $folderBrowser.ShowDialog() | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($folderBrowser.SelectedPath)) {
        return $folderBrowser.SelectedPath
    }
    
    else {
        return $null
    }

}

function Test-StartupPrecheck {
    # ---- tell the user what the hell is happening ----
    Write-Host "`nMaking sure GZDoom project folder has the correct sub-folders..." @infoColors

    # ---- list of all the directories to check and/or create --- 
    $directoriesToCheck = @(
        'acs', 
        'actors', 
        'brightmaps', 
        'dev', 
        'gldefs', 
        'graphics', 
        'hires', 
        'maps', 
        'materials', 
        'materials/ao',
        'materials/metallic',
        'materials/roughness',
        'materials/normalmaps',
        'materials/ao/auto',
        'materials/metallic/auto',
        'materials/roughness/auto',
        'materials/normalmaps/auto',
        'modeldefs', 
        'models', 
        'music', 
        'shaders', 
        'sounds', 
        'sprites', 
        'textures', 
        'voxels', 
        'zscript'
        )
    
    $existingDirectories = @()
    $missingDirectories = @()
    $createdDirectories = @()

    # ---- check each directory ----
    foreach ($directory in $directoriesToCheck) {
        $fullPath = Join-Path -Path $script:project_root_directory -ChildPath $directory
        
        # ---- check if the directory exists ----
        if (Test-Path $fullPath) {
            $existingDirectories += $directory
        } else {
            $missingDirectories += $directory
        }
    }

    # ---- display the results to the user ----
    # ---- display directories that exist ----
    if ($existingDirectories.Count -gt 0) {
        Write-Host "`nThe following directories already exist:" @script:successColors
        foreach ($directory in $existingDirectories) {
            Write-Host " -> $directory"
        }
    }

    # ---- display directories that don't exist ----
    if ($missingDirectories.Count -gt 0) {
        Write-Host "`nThe following directories don't exist and will be created:" @script:warningColors
        foreach ($directory in $missingDirectories) {
            Write-Host " -> $directory"
        }
    }

    # ---- now create the missing directories ----
    foreach ($directory in $missingDirectories) {
        $fullPath = Join-Path -Path $script:project_root_directory -ChildPath $directory
        New-Item -Path $fullPath -ItemType Directory | Out-Null
        $createdDirectories += $directory
    }

    # ---- inform the user about the directories that were created ----
    if ($createdDirectories.Count -gt 0) {
        Write-Host "`nThe following directories have been created:" @script:successColors
        foreach ($directory in $createdDirectories) {
            Write-Host " -> $directory"
        }
    }
}

# ---- check if directory was selected and inform the user ----
function Test-ProjectRootDirectory {

    if (-not [string]::IsNullOrWhiteSpace($script:project_root_directory)) {
        Write-Host "`nSelected project root directory: $script:project_root_directory" @script:successColors
    } 
    
    else {
        Write-Host "[ - ERROR - ] ~ No project root directory selected." @script:errorColors
    }    

}

# ---- identify project directory subfolders ----
function Test-ProjectSubfolders {
    # ---- ensure the $script:project_root_directory is set ----
    if (-not $script:project_root_directory) {
        Write-Host "[ - ERROR - ] ~ The project_root_directory variable is not set." @script:errorColors
        return
    }

    # ---- identify and store the paths based on the project root directory ----
    $script:gldefs_folder = Join-Path -Path $script:project_root_directory -ChildPath "gldefs"
    $script:materials_folder = Join-Path -Path $script:project_root_directory -ChildPath "materials"
    $script:materials_ao_auto_folder = Join-Path -Path $script:materials_folder -ChildPath "ao\auto"
    $script:materials_metallic_auto_folder = Join-Path -Path $script:materials_folder -ChildPath "metallic\auto"
    $script:materials_roughness_auto_folder = Join-Path -Path $script:materials_folder -ChildPath "roughness\auto"
    $script:materials_normalmaps_auto_folder = Join-Path -Path $script:materials_folder -ChildPath "normalmaps\auto"
    $script:textures_folder = Join-Path -Path $script:project_root_directory -ChildPath "textures"
    $script:models_folder = Join-Path -Path $script:project_root_directory -ChildPath "models"

    # ---- verify the existence of each folder and throw an error if not found ----
    $subfolders = @($script:gldefs_folder, $script:materials_folder, $script:materials_ao_auto_folder, $script:materials_metallic_auto_folder, $script:materials_roughness_auto_folder, $script:materials_normalmaps_auto_folder, $script:textures_folder, $script:models_folder)

    foreach ($folder in $subfolders) {
        if (-not (Test-Path $folder)) {
            Write-Host "The folder $folder does not exist." @script:errorColors 
            return
        }
    }
}

function Test-EssentialFilesAndFolders {

    # ---- ensure the $script:project_root_directory is set ----
    if (-not $script:project_root_directory) {
        Write-Host "[ - ERROR - ] ~ The project_root_directory variable is not set." @script:errorColors
        return
    }

    # ---- specify the paths based on the project root directory ----
    $script:gldefs_folder_path = Join-Path -Path $script:project_root_directory -ChildPath "gldefs"
    $script:gzdsu_auto_gldefs_path = Join-Path -Path $script:project_root_directory -ChildPath "gldefs\gzdsu_auto_gldefs.gl"
    $script:gzdsu_auto_PBR_color_path = Join-Path -Path $script:project_root_directory -ChildPath "textures\gzdsu_auto_PBR_color"
    $script:gldefs_lmp_path = Join-Path -Path $script:project_root_directory -ChildPath "gldefs.lmp"
    $script:modeldef_lmp_path = Join-Path -Path $script:project_root_directory -ChildPath "modeldef.lmp"
    $script:modeldefs_folder_path = Join-Path -Path $script:project_root_directory -ChildPath "modeldefs"
    $script:gzdsu_auto_modeldefs_path = Join-Path -Path $script:modeldefs_folder_path -ChildPath "gzdsu_auto_modeldefs.lmp"

    # ---- check for each file/folder ----
    $essentialItems = @($script:gldefs_folder_path, $script:gzdsu_auto_gldefs_path, $script:gzdsu_auto_PBR_color_path, $script:gldefs_lmp_path, $script:modeldef_lmp_path, $script:modeldefs_folder_path, $script:gzdsu_auto_modeldefs_path)
    $foundItems = @()
    $missingItems = @()

    foreach ($item in $essentialItems) {
        if (Test-Path $item) {
            $foundItems += $item
        } else {
            $missingItems += $item
        }
    }

    # ---- display found items to the user ----
    if ($foundItems.Count -gt 0) {
        Write-Host "`nThe following items were found:" @script:successColors
        foreach ($foundItem in $foundItems) {
            Write-Host " -> $foundItem"
        }
    }

    # ---- display missing items to the user ----
    if ($missingItems.Count -gt 0) {
        Write-Host "`nThe following items were not found and will be created:" @script:warningColors
        foreach ($missingItem in $missingItems) {
            Write-Host " -> $missingItem"
        }
    }

    $createdItems = @()

    foreach ($item in $missingItems) {

        # ---- check if it's a file or directory ----

        if ($item -match "\.\w+$") { # contains a file extension
            $newItem = New-Item -Path $item -ItemType File

            # ---- check for GLDEFS.lmp and append content if necessary ----
            if ($item -eq $script:gldefs_lmp_path) {
                $header = @"
// Auto-generated by $script:full_title
#include "gldefs/gzdsu_auto_gldefs.gl"
"@

                $newItem | Set-Content -Value $header
            }

            elseif ($item -eq $script:modeldef_lmp_path) {
                $content = @"
// Auto-generated by $script:full_title
#include "modeldefs/gzdsu_auto_modeldefs.lmp"
"@
                $newItem | Add-Content -Value $content
            }

            elseif ($item -eq $script:gzdsu_auto_gldefs_path) {
                $content = @"
// Auto-generated by $script:full_title
// Note: this is referenced by an #include statement in the root GLDEFS.lmp file,
// this is used for GLDEFs generated by the GZDoom Super Utility
"@
                $newItem | Add-Content -Value $content
            }
            

            elseif ($item -eq $script:gzdsu_auto_modeldefs_path) {
                $content = @"
// Auto-generated by $script:full_title
// Note: this is referenced by an #include statement in the root MODELDEF.lmp file,
// this is used for MODELDEFs generated by the GZDoom Super Utility
"@
                $newItem | Add-Content -Value $content
            }

            $createdItems += $item
        }

        else {
            New-Item -Path $item -ItemType Directory | Out-Null
            $createdItems += $item
        }

    }

    # ---- inform the user about created items ----
    if ($createdItems.Count -gt 0) {
        Write-Host "`nThe following items were created:" @script:successColors
        foreach ($createdItem in $createdItems) {
            Write-Host " -> $createdItem"
        }
    }
}
function Test-Make_Sure_Root_GLDEFS_Include_Exists {

    Write-Host "`nChecking gldefs.lmp for automation configuration . . ." @script:warningColors

    # ---- ensure the $script:gldefs_lmp_path is set ----
    if (-not $script:gldefs_lmp_path) {
        Write-Host "[ - ERROR - ] ~ The gldefs_lmp_path variable is not set." @script:errorColors
        return
    }

    # ---- check if the file contains the desired line ----
    $desiredLine = '#include "gldefs/gzdsu_auto_gldefs.gl"'

    # ---- get the content of the file ----
    $fileContent = Get-Content -Path $script:gldefs_lmp_path

    # ---- check if desired line exists in the content ----
    if ($fileContent -notcontains $desiredLine) {
        
        # ---- append two line breaks, the desired line, then two more line breaks ----
        Add-Content -Path $script:gldefs_lmp_path -Value ("`n`n" + $desiredLine + "`n`n")

        Write-Host "[ - SUCCESS - ] - gldefs.lmp is configured for automation." @script:successColors
    } else {
        Write-Host "[ - INFO - ] - gldefs.lmp already configured for automation." @script:infoColors
    }
}

function Test-Make_Sure_Root_MODELDEF_Include_Exists {

    Write-Host "`nChecking modeldef.lmp for automation configuration . . ." @script:warningColors

    # ---- ensure the $script:modeldef_lmp_path is set ----
    if (-not $script:modeldef_lmp_path) {
        Write-Host "[ - ERROR - ] - The modeldef_lmp_path variable is not set." @script:errorColors
        return
    }

    # ---- specify the desired line ----
    $desiredLine = '#include "modeldefs/gzdsu_auto_modeldefs.lmp"'

    # ---- get the content of the file ----
    $fileContent = Get-Content -Path $script:modeldef_lmp_path

    # ---- check if desired line exists in the content ----
    if ($fileContent -notcontains $desiredLine) {
        
        # ---- append two line breaks, the desired line, then two more line breaks ----
        Add-Content -Path $script:modeldef_lmp_path -Value ("`n`n" + $desiredLine + "`n`n")

        Write-Host "`n[ - OK - ] - modeldefs.lmp is configured for automation." @script:successColors
    } else {
        Write-Host "[ - INFO - ] - modeldefs.lmp already configured for automation." @script:infoColors
    }
}

# +++++ +++++ +++++ ZONE 1 END +++++ +++++ +++++

# +++++ +++++ +++++ ZONE 2 START +++++ +++++ +++++

# ---- texture directory selection function ----
function Select-TextureImportSourceDirectory {

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the texture import source directory"
    $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::Desktop
    $folderBrowser.ShowDialog() | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($folderBrowser.SelectedPath)) {
        $script:texture_import_source_directory = $folderBrowser.SelectedPath
        return Write-Host "`nSelected texture source directory:" $folderBrowser.SelectedPath @script:successColors
    }
    
    else {
        Write-Host "[ - ERROR - ] - No texture import source directory selected." @script:errorColors
        return $null
    }
}

function Find-TextureFiles {
    # ---- ensure the source directory variable is set ----
    if (-not $script:texture_import_source_directory) {
        Write-Host "Texture import source directory is not set."
        return
    }

    # ---- ensure the directory exists ----
    if (-not (Test-Path $script:texture_import_source_directory)) {
        Write-Host "The specified directory does not exist."
        return
    }

    # ---- find files with matching suffixes ----
    $files = Get-ChildItem -Path $script:texture_import_source_directory -File

    foreach ($file in $files) {
        $baseName = $file.BaseName  # ---- file name without extension ----

        # ---- check for each suffix and assign the full path to the corresponding variable if a match is found ----
        if ($baseName -imatch "_COLOR$") { $script:texture_source_file_color = $file.FullName }
        elseif ($baseName -imatch "_AO$") { $script:texture_source_file_AO = $file.FullName }
        elseif ($baseName -imatch "_METAL$") { $script:texture_source_file_metal = $file.FullName }
        elseif ($baseName -imatch "_ROUGH$") { $script:texture_source_file_rough = $file.FullName }
        elseif ($baseName -imatch "_NORMAL$") { $script:texture_source_file_normal = $file.FullName }
    }
}
function Show-TextureSourceFiles {
    Write-Host "`nIdentified texture source files:" @script:successColors
    Write-Host " -> Color:     $($script:texture_source_file_color)"
    Write-Host " -> AO:        $($script:texture_source_file_AO)"
    Write-Host " -> Metal:     $($script:texture_source_file_metal)"
    Write-Host " -> Rough:     $($script:texture_source_file_rough)"
    Write-Host " -> Normal:    $($script:texture_source_file_normal)"
}

function Invoke-RandomTextureName {
    $characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $script:randomly_generated_texture_name = -join (1..8 | ForEach-Object { Get-Random -Minimum 0 -Maximum $characters.length | % { $characters[$_] } })
}

function Show-RandomTextureName {
    if ($script:randomly_generated_texture_name) {
        Write-Host "`nRandomly generated GZDoom compliant 8 character texture name:" @script:successColors
        Write-Host " -> $script:randomly_generated_texture_name"
     }
    
    else {
            Write-Host "No texture name has been generated yet."
    }

}

function Set-MaterialPaths {
    # ---- ensure the project root directory variable is set ----
    if (-not $script:project_root_directory) {
        Write-Host "Project root directory is not set."
        return
    }

    # ---- construct the paths ----
    $script:ao_dest_path = Join-Path -Path $script:project_root_directory -ChildPath "/materials/ao/auto"
    $script:metallic_dest_path = Join-Path -Path $script:project_root_directory -ChildPath "/materials/metallic/auto"
    $script:roughness_dest_path = Join-Path -Path $script:project_root_directory -ChildPath "/materials/roughness/auto"
    $script:normalmaps_dest_path = Join-Path -Path $script:project_root_directory -ChildPath "/materials/normalmaps/auto"
    $script:color_dest_path = Join-Path -Path $script:project_root_directory -ChildPath "/textures/gzdsu_auto_PBR_color"

    # ---- display the paths ----
    Write-Host "`n[ - DEBUG - ] - Material destination path mapping check. ( Part 1 )" @debugColors
    Write-Host " -> ao_path is set to: $script:ao_dest_path" @debugColors_alt
    Write-Host " -> metallic_path is set to: $script:metallic_dest_path" @debugColors_alt
    Write-Host " -> roughness_path is set to: $script:roughness_dest_path" @debugColors_alt
    Write-Host " -> normalmaps_path is set to: $script:normalmaps_dest_path" @debugColors_alt
    Write-Host " -> color_dest_path is set to: $script:color_dest_path" @debugColors_alt
}

function Set-RemapTextureSourceDirectories {
    $script:ao_src_path = $script:texture_source_file_AO
    $script:metallic_src_path = $script:texture_source_file_metal
    $script:roughness_src_path = $script:texture_source_file_rough
    $script:normalmaps_src_path = $script:texture_source_file_normal
    $script:color_src_path = $script:texture_source_file_color
}

function Debug-ShowTexSrcDestMapping {
    # ---- display the source values ----
    Write-Host "`n[ - DEBUG - ] - Material source and destination path mapping check. ( Part 2 )" @debugColors
    Write-Host "`n[ - DEBUG - ] -------- TEX SOURCE VALUES --------" @debugColors
    Write-Host " -> AO Source:         $script:ao_src_path" @debugColors_alt
    Write-Host " -> Metallic Source:   $script:metallic_src_path" @debugColors_alt
    Write-Host " -> Roughness Source:  $script:roughness_src_path" @debugColors_alt
    Write-Host " -> Normalmaps Source: $script:normalmaps_src_path" @debugColors_alt
    Write-Host " -> Color Source:      $script:color_src_path" @debugColors_alt
    
    # ---- display the destination values ----
    Write-Host "`n[ - DEBUG - ] -------- TEX DESTINATION VALUES --------" @debugColors
    Write-Host " -> AO Destination:         $script:ao_dest_path" @debugColors_alt
    Write-Host " -> Metallic Destination:   $script:metallic_dest_path" @debugColors_alt
    Write-Host " -> Roughness Destination:  $script:roughness_dest_path" @debugColors_alt
    Write-Host " -> Normalmaps Destination: $script:normalmaps_dest_path" @debugColors_alt
    Write-Host " -> Color Destination:      $script:color_dest_path" @debugColors_alt
}

function Copy-TexturesToDestination {

    Write-Host "`nCopying textures files from source to destination with generated name..." @successColors

    # ---- ensure the random texture name variable is set ----
    if (-not $script:randomly_generated_texture_name) {
        Write-Host "Random texture name is not set."
        return
    }

    # ---- define a helper function to copy and rename ----
    function Copy-RenamedTexture {
        param (
            [string]$sourcePath,
            [string]$destinationDirectory,
            [string]$newBaseName
        )

        if (Test-Path $sourcePath) {
            $extension = [System.IO.Path]::GetExtension($sourcePath)
            $newPath = Join-Path -Path $destinationDirectory -ChildPath ("$newBaseName" + $extension)

            Copy-Item -Path $sourcePath -Destination $newPath -Force
            Write-Host " -> Copied $sourcePath to $newPath"
        } else {
            Write-Host "Source path $sourcePath not found." @errorColors
        }
    }

    # ---- use the helper function for each source-destination pair ----
    Copy-RenamedTexture -sourcePath $script:ao_src_path -destinationDirectory $script:ao_dest_path -newBaseName $script:randomly_generated_texture_name
    Copy-RenamedTexture -sourcePath $script:metallic_src_path -destinationDirectory $script:metallic_dest_path -newBaseName $script:randomly_generated_texture_name
    Copy-RenamedTexture -sourcePath $script:roughness_src_path -destinationDirectory $script:roughness_dest_path -newBaseName $script:randomly_generated_texture_name
    Copy-RenamedTexture -sourcePath $script:normalmaps_src_path -destinationDirectory $script:normalmaps_dest_path -newBaseName $script:randomly_generated_texture_name
    Copy-RenamedTexture -sourcePath $script:color_src_path -destinationDirectory $script:color_dest_path -newBaseName $script:randomly_generated_texture_name
}

function Debug-VerifyCopiedTextures {
    Write-Host "`n[ - DEBUG - ] - Check if texture is copied, renamed, and exists in the destination directory." @debugColors

    # ---- define a helper function to verify the copied file ----
    function Debug-CheckTextureExistence {
        param (
            [string]$destinationDirectory,
            [string]$baseName
        )

        $file = Get-ChildItem -Path $destinationDirectory | Where-Object { $_.Name -like "$baseName.*" }
        if ($file) {
            Write-Host " -> File exists at: $($file.FullName)" @debugColors_alt
        } else {
            Write-Host "File not found in $destinationDirectory with base name $baseName" @debugColors_alt
        }
    }

    # ---- use the helper function for each destination path ----
    Debug-CheckTextureExistence -destinationDirectory $script:ao_dest_path -baseName $script:randomly_generated_texture_name
    Debug-CheckTextureExistence -destinationDirectory $script:metallic_dest_path -baseName $script:randomly_generated_texture_name
    Debug-CheckTextureExistence -destinationDirectory $script:roughness_dest_path -baseName $script:randomly_generated_texture_name
    Debug-CheckTextureExistence -destinationDirectory $script:normalmaps_dest_path -baseName $script:randomly_generated_texture_name
    Debug-CheckTextureExistence -destinationDirectory $script:color_dest_path -baseName $script:randomly_generated_texture_name
}

function Debug-CheckProjectAgain {
    Write-Host "`n[ - DEBUG - ] - Check project folder dependencies (again):" @script:debugColors
    Write-Host " -> \gldefs folder path:" $script:gldefs_folder_path @script:debugColors_alt
    Write-Host " -> \gldefs\gzdsu_auto_gldefs.gl file path:" $script:gzdsu_auto_gldefs_path @script:debugColors_alt
    Write-Host " -> \textures\gzdsu_auto_PBR_color folder path:" $script:gzdsu_auto_PBR_color_path @script:debugColors_alt
    Write-Host " -> \gldefs.lmp file path:" $script:gldefs_lmp_path @script:debugColors_alt
    Write-Host " -> \modeldef.lmp path:" $script:modeldef_lmp_path @script:debugColors_alt
    Write-Host " -> \modeldefs folder path:" $script:modeldefs_folder_path @script:debugColors_alt
    Write-Host " -> \modeldefs\gzdsu_auto_modeldef.lmp file path:" $script:gzdsu_auto_modeldefs_path @script:debugColors_alt
}

function Write-Append_Texture_Entry_to___gzdsu_auto_gldefs_gl {

    # ---- ensure the $script:gzdsu_auto_gldefs_path is set ----
    if (-not $script:gzdsu_auto_gldefs_path) {
        Write-Host "[ - ERROR - ] ~ The gzdsu_auto_gldefs_path variable is not set." @script:errorColors
        return
    }

    # ---- ensure the $script:randomly_generated_texture_name is set ----
    if (-not $script:randomly_generated_texture_name) {
        Write-Host "[ - ERROR - ] ~ The randomly_generated_texture_name variable is not set." @script:errorColors
        return
    }

    # ---- content to append ----
    $contentToAppend = @"
`n`n
material texture $($script:randomly_generated_texture_name)
{
	//auto
}
"@

    # ---- append content to the file ----
    Add-Content -Path $script:gzdsu_auto_gldefs_path -Value $contentToAppend
}

# +++++ +++++ +++++ ZONE 2 END +++++ +++++ +++++

# +++++ +++++ +++++ ZONE 2.5 START +++++ +++++ +++++

function Show-BrightmapImportPrompt {
    $response = Read-Host "`nDo you want to import a brightmap? (Y/N)"
    
    switch ($response) {
        'y' {
            $script:importBrightmap = $true
            Write-Host "`nStarting brightmap import . . ." @script:warningColors
        }
        'n' {
            $script:importBrightmap = $false
            Write-Host "`nSkipping brightmap import . . ." @script:warningColors
        }
        default {
            Write-Host "`n[ - ERROR - ] Invalid input. Please answer with 'yes' or 'no'." @script:errorColors
            Show-BrightmapImportPrompt # Recursively call the function until a valid answer is given.
        }
    }
}

function Find-BrightmapImportSource {
    # Assuming $script:texture_input_source_path is the directory where you keep the texture inputs
    $brightmapFiles = Get-ChildItem -Path $script:texture_input_source_path -Filter "*_BRIGHT.*" 

    if ($brightmapFiles.Count -eq 0) {
        Write-Host "`n[ - WARNING - ] No brightmap files found in the source directory." @script:warningColors
        $script:brightmap_input_source_path = $null
    } elseif ($brightmapFiles.Count -eq 1) {
        $script:brightmap_input_source_path = $brightmapFiles[0].FullName
        Write-Host "`nFound brightmap file at: $($script:brightmap_input_source_path)" @script:successColors
    } else {
        Write-Host "`n[ - ERROR - ] Multiple brightmap files found in the source directory. Please ensure only one brightmap file exists." @script:errorColors
        $script:brightmap_input_source_path = $null
    }
}

function Show-BrightmapImportDebugInfo {

    Write-Host "======= ======= DEBUG INFO ======= =======" @script:debugColors

    # ---- displaying the brightmap input source path ---- 
    if ($null -ne $script:brightmap_input_source_path) {
        Write-Host "`nBrightmap Input Source Path: $script:brightmap_input_source_path" @script:infoColors
    } else {
        Write-Host "`nBrightmap Input Source Path is not set." @script:warningColors
    }

    Write-Host "==========================================" @script:debugColors
    
}

# +++++ +++++ +++++ ZONE 2.5 END +++++ +++++ +++++

# +++++ +++++ +++++ ZONE 3 START +++++ +++++ +++++

function Show-AskImport3DModel {
    $response = Read-Host "`nDo you want to import a 3D model that uses the material you just imported? (Y/N)"

    switch ($response.ToUpper()) {
        'Y' { 
            # This is where you continue with the next part of your script.
            Write-Host "`nProceeding with model import . . ." @successColors
        }

        'N' {
            Write-Host "`nExiting the script..." @warningColors
            exit
        }

        default {
            Write-Host "`nInvalid response. Please enter Y or N." @errorColors
            Show-AskImport3DModel
        }
    }
}

function Set-ModelAndSpriteDirectoryPaths {
    # ---- setting path for /models folder ----
    $script:models_folder = Join-Path -Path $script:project_root_directory -ChildPath 'models'
    Write-Host "[ - OK - ] - Path for /models folder is set to: $script:models_folder" @script:successColors

    # ---- setting path for /sprites folder ----
    $script:sprites_folder = Join-Path -Path $script:project_root_directory -ChildPath 'sprites'
    Write-Host "[ - OK - ] - Path for /sprites folder is set to: $script:sprites_folder" @script:successColors
}

function Debug-CheckModelAndSpriteDirectoryPaths {
    # ---- verifying if /models directory exists ----
    if (-not (Test-Path -Path $script:models_folder -PathType Container)) {
        Write-Host "[ - ERROR - ] - The /models directory does not exist at: $script:models_folder" @script:errorColors
        Write-Host "[ - ERROR - ] - Make sure the project folder has a /sprites directory!" @script:errorColors
        Write-TryAgain
        exit
    } 
    
    else {
        Write-Host "[ - OK - ] - Verified: /models directory exists at $script:models_folder" @script:successColors
    }

    # ---- verifying if /sprites directory exists ----
    if (-not (Test-Path -Path $script:sprites_folder -PathType Container)) {
        Write-Host "[ - ERROR - ] - The /sprites directory does not exist at: $script:sprites_folder" @script:errorColors
        Write-Host "[ - ERROR - ] - Make sure the project folder has a /models directory!" @script:errorColor
        Write-TryAgain
        exit
    } 
    
    else {
        Write-Host "[ - OK - ] - Verified: /sprites directory exists at $script:sprites_folder" @script:successColors
    }
}

function Set-ModelAutomationPath {
    # ---- check if $script:models_folder exists, it if does not, throw an error ----
    if (-not (Test-Path $script:models_folder)) {
        Write-Host "The models folder does not exist!" @script:errorColors
        exit
    }

    # ---- construct the path to the models_auto folder ----
    $modelsAutoPath = Join-Path -Path $script:models_folder -ChildPath "models_auto"

    # ---- check if models_auto folder exists ----
    if (Test-Path $modelsAutoPath) {
        Write-Host "[ - OK - ] - The models_auto folder exists at: $modelsAutoPath" @script:successColors
    } 
    
    else {
        # ---- create the models_auto folder ----
        Write-Host "`n[ - INFO - ] - models_auto folder not found" @script:infoColors
        Write-Host "[ - OK - ] Created the models_auto folder at: $modelsAutoPath" @script:successColors
        New-Item -Path $modelsAutoPath -ItemType Directory | Out-Null
    }

    # Record the path in $script:models_auto_folder
    $script:models_auto_folder = $modelsAutoPath
}

function Set-SpriteAutomationPath {
    # ---- check if $script:sprites_folder exists, if it does not, throw an error ----
    if (-not (Test-Path $script:sprites_folder)) {
        Write-Host "The sprites folder does not exist!" @script:errorColors
        exit
    }

    # ---- construct the path to the sprites_auto folder ----
    $spritesAutoPath = Join-Path -Path $script:sprites_folder -ChildPath "sprites_auto"

    # ---- check if sprites_auto folder exists ----
    if (Test-Path $spritesAutoPath) {
        Write-Host "[ - OK - ] - The sprites_auto folder exists at: $spritesAutoPath" @script:successColors
    } 
    
    else {
        # ---- create the sprites_auto folder ----
        Write-Host "`n[ - INFO - ] - sprites_auto folder not found" @script:infoColors
        Write-Host "[ - OK - ] Created the sprites_auto folder at: $spritesAutoPath" @script:successColors
        New-Item -Path $spritesAutoPath -ItemType Directory | Out-Null
    }

    # ---- record the path in $script:sprites_auto_folder ----
    $script:sprites_auto_folder = $spritesAutoPath
}

function Debug-CheckModelAutomationPath {
    Write-Host "`n[ - DEBUG - ] - value of `$script:models_auto_folder: $($script:models_auto_folder)" @script:debugColors
}

function Debug-CheckSpriteAutomationPath {
    Write-Host "[ - DEBUG - ] - value of `$script:sprites_auto_folder: $($script:sprites_auto_folder)" @script:debugColors
}

function Set-ZscriptRootPath {
    Write-Host "`nChecking for zscript.txt in project root . . ." @script:warningColors

    # ---- construct the path to zscript.txt in the project root directory ----
    $zscriptPath = Join-Path -Path $script:project_root_directory -ChildPath "zscript.txt"

    # ---- check if zscript.txt exists ----
    if (Test-Path $zscriptPath) {
        Write-Host "[ - OK - ] zscript.txt found" @script:successColors
    } else {
        # ---- create zscript.txt ----
        New-Item -Path $zscriptPath -ItemType File | Out-Null
        Write-Host "[ - INFO - ] - zscript.txt not found" @script:infoColors
        Write-Host "[ - OK - ] - zscript.txt created at $zscriptPath" @script:successColors
    }
}

function Write-ZscriptRoot_ZscriptAutoInclude {
    Write-Host "`nChecking zscript.txt for required inclusion(s) . . ." @script:warningColors
    # ---- construct the path to zscript.txt in the project root directory ----
    $zscriptPath = Join-Path -Path $script:project_root_directory -ChildPath "zscript.txt"

    # ---- generate the individual lines to check and append ----
    $line1 = "// Auto-generated by $($script:full_title)"
    $line2 = "#include `"zscript/zscript_auto.zs`""
    $line3 = "// ZZ_automation_recognition_token___NUKE_THIS_UP___"

    # ---- get the content of zscript.txt as an array of lines ----
    $existingContent = Get-Content -Path $zscriptPath

    # ---- check if content already exists in zscript.txt ----
    if (-not ($existingContent -contains $line1) -or -not ($existingContent -contains $line2)) {
        # ---- append the content to zscript.txt ----
        Add-Content -Path $zscriptPath -Value "`n$line1`n$line2`n$line3"
        Write-Host "[ - INFO - ] - zscript.txt does not have required inclusion(s)" @script:infoColors
        Write-Host "[ - OK - ] - Added required inclusion statement(s) to zscript.txt" @script:successColors
    } else {
        Write-Host "[ - OK - ] - zscript.txt has required inclusion statement(s)." @script:successColors
    }

    $script:zscript = $zscriptPath
}

function Set-ZscriptAutoPath {
    Write-Host "`nChecking for zscript/zscript_auto.txt in project root . . ." @script:warningColors

    # ---- construct the path to zscript/zscript_auto.zs in the project root directory ----
    $zscriptAutoPath = Join-Path -Path $script:project_root_directory -ChildPath "zscript/zscript_auto.zs"

    # ---- check if zscript/zscript_auto.zs exists ----
    if (Test-Path $zscriptAutoPath) {
        Write-Host "[ - OK - ] - zscript/zscript_auto.zs found" @script:successColors
    } else {
        # ---- create zscript/zscript_auto.zs ----
        New-Item -Path $zscriptAutoPath -ItemType File | Out-Null
        Write-Host "[ - INFO - ] - zscript/zscript_auto.zs not found" @script:infoColors
        Write-Host "[ - OK - ] - zscript/zscript_auto.zs created at $zscriptAutoPath" @script:successColors
    }

    $script:zscript_auto = $zscriptAutoPath
}

function Debug-CheckZscriptAndZscriptAutoPathVariables {
    Write-Host "`n[ - DEBUG - ] - value of `$script:zscript: $($script:zscript)" @script:debugColors
    Write-Host "[ - DEBUG - ] - value of `$script:zscript_auto: $($script:zscript_auto)" @script:debugColors
}

function Write-ZscriptAutoHeader {
    Write-Host "`nUpdating zscript_auto.zs . . ." @script:warningColors
    
    # ---- construct the path to zscript_auto.zs in the zscript directory ----
    $zscriptAutoPath = Join-Path -Path $script:project_root_directory -ChildPath "zscript/zscript_auto.zs"

    # ---- generate the content to check ----
    $content = "// Auto-generated by $($script:full_title)"

    # ---- get the content of zscript_auto.zs as an array of lines ----
    $existingContent = if (Test-Path $zscriptAutoPath) { Get-Content -Path $zscriptAutoPath } else { @() }

    # ---- check if content already exists in zscript_auto.zs ----
    if (-not ($existingContent -contains $content)) {
        # ---- append the content to zscript_auto.zs ----
        Add-Content -Path $zscriptAutoPath -Value "`n$content`n"
        Write-Host "[ - INFO - ] - zscript_auto.zs header not found." @script:infoColors
        Write-Host "[ - OK - ] - zscript_auto.zs updated with auto-generated header." @script:successColors
    } else {
        Write-Host "[ - OK - ] - zscript_auto.zs already has the auto-generated header." @script:successColors
    }
}

function Select-ModelImportSourceFolder {
    # ---- create a new instance of the folder browser dialog ----
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

    # ---- set properties for the folder browser dialog ----
    $folderBrowser.Description = "Select a model import source folder"
    $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::Desktop

    # ---- display the folder browser dialog ----
    $folderBrowser.ShowDialog() | Out-Null

    # ---- check if a valid path was selected and return it ----
    if (-not [string]::IsNullOrWhiteSpace($folderBrowser.SelectedPath)) {
        return $folderBrowser.SelectedPath
    } else {
        return $null
    }
}

function Test-ModelImportSourceFolder {
    if (-not [string]::IsNullOrWhiteSpace($script:model_import_source_folder)) {
        Write-Host "`nSelected model import source folder: $script:model_import_source_folder" @script:successColors
    } else {
        Write-Host "[ - ERROR - ] ~ No model import source folder selected." @script:errorColors
    }    
}

function Test-ObjFilesInModelSourceFolder {
    # ---- check if the directory exists ----
    if (-not (Test-Path -Path $script:model_import_source_folder -PathType Container)) {
        Write-Host "[ - ERROR - ] - The directory defined in `\$script:model_import_source_folder` does not exist." @script:errorColors
        return
    }

    # ---- get all the .obj files in the directory ----
    $objFiles = Get-ChildItem -Path $script:model_import_source_folder -Filter "*.obj" -File

    # ---- test for multiple .obj files ----
    if ($objFiles.Count -gt 1) {
        Write-Host "[ - ERROR - ] - Multiple .obj files found in the directory. Only one .obj file is expected." @script:errorColors
        return
    }

    # ---- test for no .obj files ----
    if ($objFiles.Count -eq 0) {
        Write-Host "[ - ERROR - ] - No .obj files found in the directory." @script:errorColors
        return
    }

    # ---- if only one .obj file is found, store its path and provide a success message ----
    $script:model_for_import = $objFiles.FullName
    Write-Host "`n[ - OK - ] - Single .obj file found and is valid. Path stored for import." @script:successColors
    Write-Host "`n[ - INFO - ] - Model to be imported: $script:model_for_import" @script:infoColors
}

function Invoke-RandomSpriteName {
    # ---- generate a random four-character sequence (0-9 A-Z) ----
    $characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $randomName = -join (1..4 | ForEach-Object { $characters[(Get-Random -Maximum $characters.Length)] })

    # ---- append 'A0' to the generated sequence ----
    $randomName += "A0"

    # ---- store it in the $script:RandomSpriteName variable ----
    $script:RandomSpriteName = $randomName
}

function Test-RandomSpriteName {
    # ---- check if the $script:RandomSpriteName variable exists ----
    if (-not $script:RandomSpriteName) {
        Write-Host "`n[ - ERROR - ] - `$script:RandomSpriteName variable not found or is empty." @script:errorColors
        return
    }
    
    # ---- display the $script:RandomSpriteName to the user ----
    Write-Host "[ - INFO - ] - Random Sprite Name: $($script:RandomSpriteName)" @script:infoColors
}

function Copy-ModelProxySprite {
    # ---- define the path to model_proxy.png ----
    $sourcePath = Join-Path -Path $script:directory_this_script_is_being_run_from -ChildPath 'resources\model_proxy.png'

    Write-Host "`n[ - DEBUG - ] - Defined source path: $sourcePath" @script:debugColors
    
    # ---- verify if the model_proxy.png exists ----
    if (-not (Test-Path -Path $sourcePath -PathType Leaf)) {
        Write-Host "`n[ - ERROR - ] - model_proxy.png not found in the resources directory." @script:errorColors
        return
    }

    Write-Host "[ - DEBUG - ] - Verified model_proxy.png exists at source." @script:debugColors

    # ---- define the destination path using $script:sprites_auto_folder ----
    $destinationDirectory = $script:sprites_auto_folder
    $destinationPath = Join-Path -Path $destinationDirectory -ChildPath 'model_proxy.png'
    
    Write-Host "[ - DEBUG - ] - Defined destination path: $destinationPath" @script:debugColors

    # ---- copy the file ----
    Copy-Item -Path $sourcePath -Destination $destinationPath

    Write-Host "`n[ - OK - ] - model_proxy.png copied to: $destinationPath" @script:successColors

    # ---- rename the copied file to the value of $script:RandomSpriteName ----
    $newFilePath = Join-Path -Path $destinationDirectory -ChildPath "$script:RandomSpriteName.png"
    Rename-Item -Path $destinationPath -NewName $newFilePath

    Write-Host "[ - OK - ] - model_proxy.png renamed to: $script:RandomSpriteName.png" @script:successColors
}

function Copy-3DModel {
    # ---- check if the source model exists ----
    if (-not (Test-Path -Path $script:model_for_import -PathType Leaf)) {
        Write-Host "`n[ - ERROR - ] - Model not found at the specified path: $script:model_for_import" @script:errorColors
        return
    }

    Write-Host "`n[ - DEBUG - ] - Verified model exists at: $script:model_for_import" @script:debugColors

    # ---- get the model's filename to preserve the original name ----
    $modelName = [System.IO.Path]::GetFileName($script:model_for_import)

    # ---- define the destination path using $script:models_auto_folder ----
    $destinationPath = Join-Path -Path $script:models_auto_folder -ChildPath $modelName
    
    Write-Host "`n[ - DEBUG - ] - Defined destination path: $destinationPath" @script:debugColors

    # ---- copy the model ----
    Copy-Item -Path $script:model_for_import -Destination $destinationPath

    Write-Host "`n[ - OK - ] - Model copied to: $destinationPath" @script:successColors
}

function Set-ZScriptActorsAutoFolder {
    # ---- define the path to the zscript folder within the project root directory ----
    $zscriptFolderPath = Join-Path -Path $script:project_root_directory -ChildPath 'zscript'
    
    Write-Host "`n[ - DEBUG - ] - Looking for zscript folder at: $zscriptFolderPath" @script:debugColors
    
    # ---- verify if the zscript folder exists ----
    if (-not (Test-Path -Path $zscriptFolderPath -PathType Container)) {
        Write-Host "`n[ - ERROR - ] - zscript folder not found within the project root directory." @script:errorColors
        return
    }

    # ---- define the path for the new zscript_actors_auto folder ----
    $zscriptActorsAutoFolderPath = Join-Path -Path $zscriptFolderPath -ChildPath 'zscript_actors_auto'
    
    # ---- create the zscript_actors_auto folder if it doesn't exist ----
    if (-not (Test-Path -Path $zscriptActorsAutoFolderPath)) {
        New-Item -Path $zscriptActorsAutoFolderPath -ItemType Directory
        Write-Host "`n[ - OK - ] - zscript_actors_auto folder created at: $zscriptActorsAutoFolderPath" @script:successColors
    } else {
        Write-Host "`n[ - INFO - ] - zscript_actors_auto folder already exists at: $zscriptActorsAutoFolderPath" @script:infoColors
    }
}
function Set-UserDefinedActorName {
    # ---- prompt the user for input ----
    $userInput = Read-Host "`nPlease provide an Actor Name (A-Z, 0-9, and _ only, no spaces)"

    # ---- check if the input matches the required pattern (A-Z, 0-9, and _) ----
    while ($userInput -notmatch '^[A-Z0-9_]+$') {
        Write-Host "`n[ - ERROR - ] - Invalid Actor Name. Please use only A-Z, 0-9, and _ characters without spaces." @script:errorColors
        $userInput = Read-Host "`nPlease provide a valid Actor Name"
    }

    # ---- store the valid input in the script variable ----
    $script:UserDefinedActorName = $userInput
    Write-Host "`n[ - OK - ] - Actor Name set to: $script:UserDefinedActorName" @script:successColors
}

function Set-ZscriptActorDefinition {
    # Extract the first four characters from RandomSpriteName
    $spriteNamePrefix = $script:RandomSpriteName.Substring(0, 4)

    # Append _ and the prefix to the user-defined actor name
    $script:adjustedActorName = $script:UserDefinedActorName + "_" + $spriteNamePrefix

    # Derive the filename based on the adjusted actor name
    $filename = "$script:adjustedActorName".ToLower() + ".zs"

    Write-Host "`n[ - DEBUG - ] - Derived file name: $filename" @script:debugColors
    
    # Update the $script:zscript_auto file with the new include statement
    $zscript_auto_path = $script:zscript_auto
    $includeStatement = "#include `"zscript_actors_auto/$filename`""
    Add-Content -Path $zscript_auto_path -Value $includeStatement
    
    Write-Host "`n[ - DEBUG - ] - Appended include statement to $zscript_auto_path" @script:debugColors

    # Set the full path for the new actor definition file
    $script:actorDefinitionPath = Join-Path -Path "$script:project_root_directory\zscript\zscript_actors_auto" -ChildPath $filename
    
    # Construct the actor definition text
    $trimmedSpriteName = $script:RandomSpriteName -replace 'A0$'  # Trim 'A0' from the end
    $actorDefinition = @"

// ZZ_automation_token_ACTOR_TRIM_START
class $script:adjustedActorName : Actor {
    Default {
        Radius 0;
        Height 0;
        +SOLID;
        +FloorClip;
    }

    States {
        Spawn:
        $trimmedSpriteName A -1;
        Stop;
    }
}
// ZZ_automation_token_ACTOR_TRIM_END

"@
    
    # Write the actor definition to the new file
    Set-Content -Path $script:actorDefinitionPath -Value $actorDefinition
    
    Write-Host "`n[ - DEBUG - ] - Written actor definition to $script:actorDefinitionPath" @script:debugColors
    Write-Host "`n[ - OK - ] - Actor definition operation completed." @script:successColors
}

<#
function Debug-ZscriptActorDefinitionCheck {
    # ---- derive the filename based on $UserDefinedActorName ----
    $suffix = $script:RandomSpriteName.Substring(0, 4)
    $filename = ($script:UserDefinedActorName + "_" + $suffix).ToLower() + ".zs"

    # ---- check the $script:zscript_auto file ----
    $zscript_auto_path = $script:zscript_auto
    if (Test-Path -Path $zscript_auto_path -PathType Leaf) {
        Write-Host "`n[ - DEBUG - ] - Found the $zscript_auto_path file." @script:debugColors
    } else {
        Write-Host "`n[ - ERROR - ] - $zscript_auto_path file not found." @script:errorColors
    }

    # ---- check for the new actor definition file ----
    $script:actorDefinitionPath = Join-Path -Path "$script:project_root_directory\zscript\zscript_actors_auto" -ChildPath $filename
    if (Test-Path -Path $script:actorDefinitionPath -PathType Leaf) {
        Write-Host "`n[ - DEBUG - ] - Found the actor definition file at $script:actorDefinitionPath." @script:debugColors
    } else {
        Write-Host "`n[ - ERROR - ] - Actor definition file not found at $script:actorDefinitionPath." @script:errorColors
    }

    # ---- check if the include statement is in the $script:zscript_auto file ----
    $includeStatement = "#include `"`"zscript_actors_auto/$filename`"`""
    if ((Get-Content -Path $zscript_auto_path) -match [regex]::Escape($includeStatement)) {
        Write-Host "`n[ - DEBUG - ] - Include statement found in $zscript_auto_path." @script:debugColors
    } else {
        Write-Host "`n[ - ERROR - ] - Include statement not found in $zscript_auto_path." @script:errorColors
    }
}
#>

function Invoke-MAPINFO {
    # Define the path to the MAPINFO file
    $mapinfoPath = Join-Path -Path $script:project_root_directory -ChildPath 'MAPINFO'

    Write-Host "`n[ - DEBUG - ] - Checking for MAPINFO file at: $mapinfoPath" @script:debugColors

    # Verify if the MAPINFO file exists
    if (-not (Test-Path -Path $mapinfoPath)) {
        Write-Host "`n[ - DEBUG - ] - MAPINFO file not found." @script:debugColors

        # Create the MAPINFO file since it doesn't exist
        New-Item -Path $mapinfoPath -ItemType File -Force
        Write-Host "`n[ - OK - ] - MAPINFO file created at: $mapinfoPath" @script:successColors
    } else {
        Write-Host "`n[ - INFO - ] - MAPINFO file already exists at: $mapinfoPath" @script:infoColors
    }

    # Store the path for MAPINFO in $script:mapinfo_path
    $script:mapinfo_path = $mapinfoPath

    Write-Host "`n[ - DEBUG - ] - MAPINFO path stored in `$script:mapinfo_path" @script:debugColors
}

function Debug-Check_MAPINFO {
    # Extract MAPINFO path from $script:mapinfo_path
    $mapinfoPath = $script:mapinfo_path

    Write-Host "`n[ - DEBUG - ] - Checking for MAPINFO file at: $mapinfoPath" @script:debugColors

    # Test if the MAPINFO file exists
    if (Test-Path -Path $mapinfoPath) {
        Write-Host "`n[ - OK - ] - MAPINFO file exists at: $mapinfoPath" @script:successColors
    } else {
        Write-Host "`n[ - ERROR - ] - MAPINFO file not found at: $mapinfoPath" @script:errorColors
    }
}

<#
function __OLD__Write-DoomEdNums {
    # Ensure the MAPINFO file exists at the defined path
    if (-not (Test-Path -Path $script:mapinfo_path)) {
        Write-Host "`n[ - ERROR - ] - MAPINFO file not found at $script:mapinfo_path." @script:errorColors
        return
    }

    # ---- Generate a random number between 10000 and 20000 ----
    $script:random_ednum = Get-Random -Minimum 5000 -Maximum 32767
    Write-Host "`n[ - DEBUG - ] - Generated random ednum: $script:random_ednum" @script:debugColors

    # ---- Read the content of MAPINFO ----
    $mapinfoContent = Get-Content -Path $script:mapinfo_path -Raw

    # ---- Check for the automation token ----
    if ($mapinfoContent -match "// ZZ_doom_ednum_automation_token_DO_NOT_DELETE") {
        # ---- token found, replace it with the new lines ----
        $replacementText = @"
$script:random_ednum = $script:UserDefinedActorName
// ZZ_doom_ednum_automation_token_DO_NOT_DELETE
"@
        $mapinfoContent = $mapinfoContent -replace "// ZZ_doom_ednum_automation_token_DO_NOT_DELETE", $replacementText
        Set-Content -Path $script:mapinfo_path -Value $mapinfoContent
        Write-Host "`n[ - DEBUG - ] - Updated MAPINFO with new ednum definition." @script:debugColors

    } else {
        # ---- token not found, append the whole block ----
        $doomEdNumsBlock = @"
// Autogenerated by $script:full_title
DoomEdNums 
{
    $script:random_ednum = $script:UserDefinedActorName
    // ZZ_doom_ednum_automation_token_DO_NOT_DELETE
}
"@
        Add-Content -Path $script:mapinfo_path -Value $doomEdNumsBlock
        Write-Host "`n[ - DEBUG - ] - Appended new DoomEdNums block to MAPINFO." @script:debugColors
    }

    Write-Host "`n[ - OK - ] - MAPINFO update operation completed." @script:successColors
}
#>

function Write-DoomEdNums {
    # ---- Ensure the MAPINFO file exists at the defined path ----
    if (-not (Test-Path -Path $script:mapinfo_path)) {
        Write-Host "`n[ - ERROR - ] - MAPINFO file not found at $script:mapinfo_path." @script:errorColors
        return
    }

    # ---- Generate a random number between 10000 and 20000 ----
    $script:random_ednum = Get-Random -Minimum 5000 -Maximum 32767
    Write-Host "`n[ - DEBUG - ] - Generated random ednum: $script:random_ednum" @script:debugColors

    # ---- Extract the first four characters from RandomSpriteName ----
    $spriteNamePrefix = $script:RandomSpriteName.Substring(0, 4)

    # ---- Append _ and the prefix to the user-defined actor name ----
    $script:adjustedActorName = $script:UserDefinedActorName + "_" + $spriteNamePrefix

    # ---- Read the content of MAPINFO ----
    $mapinfoContent = Get-Content -Path $script:mapinfo_path -Raw

    # ---- Check for the automation token ----
    if ($mapinfoContent -match "// ZZ_doom_ednum_automation_token_DO_NOT_DELETE") {
        # ---- token found, replace it with the new lines ----
        $replacementText = @"
$script:random_ednum = $script:adjustedActorName
// ZZ_doom_ednum_automation_token_DO_NOT_DELETE
"@
        $mapinfoContent = $mapinfoContent -replace "// ZZ_doom_ednum_automation_token_DO_NOT_DELETE", $replacementText
        Set-Content -Path $script:mapinfo_path -Value $mapinfoContent
        Write-Host "`n[ - DEBUG - ] - Updated MAPINFO with new ednum definition." @script:debugColors

    } else {
        # ---- token not found, append the whole block ----
        $doomEdNumsBlock = @"
// Autogenerated by $script:full_title
DoomEdNums 
{
    $script:random_ednum = $script:adjustedActorName
    // ZZ_doom_ednum_automation_token_DO_NOT_DELETE
}
"@
        Add-Content -Path $script:mapinfo_path -Value $doomEdNumsBlock
        Write-Host "`n[ - DEBUG - ] - Appended new DoomEdNums block to MAPINFO." @script:debugColors
    }

    Write-Host "`n[ - OK - ] - MAPINFO update operation completed." @script:successColors
}

function Get-JustTheModelFilenameForModeldef {
    # ---- Extract the filename from $script:model_for_import ----
    $script:model_filename = [System.IO.Path]::GetFileName($script:model_for_import)

    Write-Host "`n[ - DEBUG - ] - Extracted model filename: $script:model_filename" @script:debugColors

    # ---- Search for the model file in the specified directory ----
    $searchPath = Join-Path -Path $script:project_root_directory -ChildPath "models"
    $foundModel = Get-ChildItem -Path $searchPath -Recurse | Where-Object { $_.Name -eq $script:model_filename }

    if ($foundModel) {
        # ---- Retain the filename including its extension ----
        $script:__model_filename__USE_THIS_FOR_MODELDEF = $foundModel.Name
        Write-Host "`n[ - DEBUG - ] - Found and stored model filename for modeldef: $script:__model_filename__USE_THIS_FOR_MODELDEF" @script:debugColors
    } else {
        Write-Host "`n[ - ERROR - ] - Model file not found in $searchPath." @script:errorColors
    }

    Write-Host "`n[ - OK - ] - Model filename capture and search operation completed." @script:successColors
}

function Write-Modeldef {
    # ---- ensure the file exists at the defined path or create it ----
    if (-not (Test-Path -Path $script:gzdsu_auto_modeldefs_path)) {
        New-Item -Path $script:gzdsu_auto_modeldefs_path -ItemType File
        Write-Host "`n[ - DEBUG - ] - Created a new modeldefs file at $script:gzdsu_auto_modeldefs_path." @script:debugColors
    }
    
    # ---- display the original sprite name for debugging purposes ----
    Write-Host "`n[ - DEBUG - ] - Original Sprite Name: $script:RandomSpriteName" @script:debugColors

    # ---- trim the last two characters of $script:RandomSpriteName ----
    $trimmedSpriteName = $script:RandomSpriteName.Substring(0, $script:RandomSpriteName.Length - 2)

    # ---- display the trimmed sprite name for debugging purposes ----
    Write-Host "`n[ - DEBUG - ] - Trimmed Sprite Name: $trimmedSpriteName" @script:debugColors

    # ---- display the model for import and randomly generated texture name for debugging purposes ----
    Write-Host "`n[ - DEBUG - ] - Model for Import: $script:model_for_import" @script:debugColors
    Write-Host "`n[ - DEBUG - ] - Randomly Generated Texture Name: $script:randomly_generated_texture_name" @script:debugColors

    # ---- construct the block of text to append ----

    $script:__fixed__UserDefinedActorName = $script:adjustedActorName
    $currentDate = Get-Date

    $modeldefBlock = @"

// Auto-generated by $($script:full_title) at $currentDate
Model $script:__fixed__UserDefinedActorName {
    Path "models/models_auto"
    Model 0 "$script:__model_filename__USE_THIS_FOR_MODELDEF"
    Skin 0 "$script:randomly_generated_texture_name"
    Scale 1.0 1.0 1.0
    FrameIndex $trimmedSpriteName A 0 0
}

"@
    
    Write-Host "`n[ - DEBUG - ] - Preparing to append model definition to $script:gzdsu_auto_modeldefs_path." @script:debugColors

    # ---- append to the file ----
    Add-Content -Path $script:gzdsu_auto_modeldefs_path -Value $modeldefBlock

    Write-Host "`n[ - DEBUG - ] - Appended model definition to $script:gzdsu_auto_modeldefs_path." @script:debugColors
    Write-Host "`n[ - OK - ] - Modeldef operation completed." @script:successColors
}

# +++++ +++++ +++++ ZONE 3 END +++++ +++++ +++++

# +++++ +++++ +++++ ZONE 4 START +++++ +++++ +++++

<#

NOTE: the following function(s) are intended to undo some of the previous file operations.

I did not realize GZDoom did not support multiple layers of #include

In order to ensure this script actually generates usable content, we are undoing any zscript.txt
related #include statements, and putting all Zscript Actor entries directly in zscript.txt

#>

# !!!!! !!!!! !!!!! HACKY BULLSHIT START !!!!! !!!!! !!!!! 

function Invoke-ExtremelyElegantFix {
    Write-Host "`n////////////////////////////////////////////////" @script:warningColors
    Write-Host "[ !! CAUTION !! ] - Hacky bullshit commencing..." @script:warningColors
    Write-Host "////////////////////////////////////////////////" @script:warningColors

    # ---- Operations on zscript.txt ----
    $zscriptPath = Join-Path -Path $script:project_root_directory -ChildPath "zscript.txt"

    # Check if zscript.txt exists
    if (-not (Test-Path $zscriptPath)) {
        Write-Host "`n[ - ERROR - ] - zscript.txt not found." @script:errorColors
        return
    }

    # Read the content
    $zscriptContent = Get-Content -Path $zscriptPath -Raw

    # Try to find and remove the include line
    if ($zscriptContent -match '#include "zscript/zscript_auto.zs"') {
        Write-Host "`n[ - DEBUG - ] - Located target include line in zscript.txt" @script:debugColors
        $zscriptContent = $zscriptContent -replace '#include "zscript/zscript_auto.zs"', ''
        Set-Content -Path $zscriptPath -Value $zscriptContent
        Write-Host "[ - DEBUG - ] - Deleted target include line from zscript.txt" @script:debugColors
    } else {
        Write-Host "[ - DEBUG - ] - Target include line not found in zscript.txt" @script:debugColors
    }

    # ---- Delete zscript_auto.zs ----
    $zscriptAutoPath = Join-Path -Path "$script:project_root_directory\zscript" -ChildPath "zscript_auto.zs"
    if (Test-Path $zscriptAutoPath) {
        Remove-Item -Path $zscriptAutoPath -Force
        Write-Host "[ - DEBUG - ] - Deleted zscript_auto.zs" @script:debugColors
    } else {
        Write-Host "[ - DEBUG - ] - zscript_auto.zs not found." @script:debugColors
    }

    # ---- Recover actor definition and delete file ----
    if (Test-Path $script:actorDefinitionPath) {
        $script:__recovered__ActorDefinition = Get-Content -Path $script:actorDefinitionPath -Raw
        Remove-Item -Path $script:actorDefinitionPath -Force
        Write-Host "[ - DEBUG - ] - Deleted and recovered actor definition from $script:actorDefinitionPath" @script:debugColors
    } else {
        Write-Host "[ - DEBUG - ] - File not found at $script:actorDefinitionPath" @script:debugColors
    }

    # ---- Write to zscript.txt ----
    $currentDate = Get-Date
    Add-Content -Path $zscriptPath -Value "`n// Auto-generated by $($script:full_title) at $currentDate"
    Add-Content -Path $zscriptPath -Value "$script:__recovered__ActorDefinition`n"
    Write-Host "`n[ - DEBUG - ] - Appended recovered actor definition to zscript.txt" @script:debugColors

    Write-Host "`n[ - OK - ] - Elegant fix operation completed." @script:successColors
}

function Debug-ExtractZscriptActor {
    Write-Host "`nParsing zscript.txt for actor extraction..." @script:warningColors

    # ---- construct the path to zscript.txt in the project root directory ----
    $zscriptPath = Join-Path -Path $script:project_root_directory -ChildPath "zscript.txt"

    # Check if zscript.txt exists
    if (-not (Test-Path $zscriptPath)) {
        Write-Host "`n[ - ERROR - ] - zscript.txt not found." @script:errorColors
        return
    }

    # ---- get the content of zscript.txt as an array of lines ----
    $existingContent = Get-Content -Path $zscriptPath

    # ---- identify the index of the start and end tokens ----
    $startTokenIndex = $existingContent.IndexOf("// ZZ_automation_token_ACTOR_TRIM_START")
    $endTokenIndex = $existingContent.IndexOf("// ZZ_automation_token_ACTOR_TRIM_END")

    # ---- validate the presence and order of the tokens ----
    if ($startTokenIndex -eq -1 -or $endTokenIndex -eq -1 -or $startTokenIndex -ge $endTokenIndex) {
        Write-Host "[ - ERROR - ] - Tokens not found or improperly ordered in zscript.txt" @script:errorColors
        return
    }

    # ---- extract the content between the tokens and assign to the buffer variable ----
    $script:ZscriptActorCopyBuffer = $existingContent[($startTokenIndex + 1)..($endTokenIndex - 1)]

    # ---- create updated content without the tokens and the content between them ----
    $updatedContent = $existingContent[0..($startTokenIndex - 1)] + $existingContent[($endTokenIndex + 1)..($existingContent.Length - 1)]

    # ---- write the updated content back to zscript.txt ----
    Set-Content -Path $zscriptPath -Value $updatedContent
    Write-Host "[ - OK - ] - Extracted and removed actor content from zscript.txt" @script:successColors
}

function Debug-DisplayZscriptActorCopyBuffer {
    if ($null -eq $script:ZscriptActorCopyBuffer) {
        Write-Host "`n[ - WARNING - ] - The ZscriptActorCopyBuffer is empty or not set." @script:warningColors
    } else {
        Write-Host "`nContents of ZscriptActorCopyBuffer:" @script:infoColors
        Write-Host "-------------------------------------------------------------"
        $script:ZscriptActorCopyBuffer | ForEach-Object { Write-Host $_ }
        Write-Host "-------------------------------------------------------------"
    }
}

function Debug-CreateActorsFolderInZscript {
    # Construct the path to the 'actors' folder inside 'zscript'
    $actorsFolderPath = Join-Path -Path "$script:project_root_directory\zscript" -ChildPath "actors"

    # Check if the directory already exists
    if (-not (Test-Path $actorsFolderPath)) {
        # Create the 'actors' directory
        Write-Host "`nCreating zscript/actors directory..." @script:warningColors
        New-Item -Path $actorsFolderPath -ItemType Directory

        Write-Host "`n[ - OK - ] - 'actors' folder created inside 'zscript'." @script:successColors
    } else {
        Write-Host "[ - INFO - ] - 'actors' folder already exists inside 'zscript'." @script:infoColors
    }
}

function Write-ActorToFile {
    if (-not $script:ZscriptActorCopyBuffer) {
        Write-Host "[ - ERROR - ] - No content found in ZscriptActorCopyBuffer." @script:errorColors
        return
    }

    $actorNameFound = $false

    # Split the buffer by newlines
    $lines = $script:ZscriptActorCopyBuffer -split "`n"

    foreach ($line in $lines) {
        # Trim any whitespace from the line
        $trimmedLine = $line.Trim()

        # Check if the line begins with "class "
        if ($trimmedLine.StartsWith("class ")) {
            # Split the line by spaces
            $words = $trimmedLine -split '\s+'

            # If there are enough words and the next word isn't empty
            if ($words.Count -gt 1 -and -not [string]::IsNullOrEmpty($words[1])) {
                $script:ZscriptActorNameCopyBuffer = $words[1]
                $actorNameFound = $true
                break
            }
        }
    }

    if (-not $actorNameFound) {
        Write-Host "[ - ERROR - ] - Unable to extract actor name from buffer." @script:errorColors
        return
    }

    # Construct file path
    $actorFilePath = Join-Path -Path "$script:project_root_directory\zscript\actors" -ChildPath "$script:ZscriptActorNameCopyBuffer.zs"

    # Write content to the file
    Set-Content -Path $actorFilePath -Value $script:ZscriptActorCopyBuffer

    $script:ZscriptActorSidecarFilePath = $actorFilePath

    Write-Host "[ - OK - ] - Actor saved to $actorFilePath" @script:successColors
}


function Debug-CleanZscriptFile {
    Write-Host "`nProcessing zscript.txt for cleaning..." @script:warningColors

    # Construct the path to zscript.txt in the project root directory
    $zscriptPath = Join-Path -Path $script:project_root_directory -ChildPath "zscript.txt"

    # Check if zscript.txt exists
    if (-not (Test-Path $zscriptPath)) {
        Write-Host "`n[ - ERROR - ] - zscript.txt not found." @script:errorColors
        return
    }

    # Get the content of zscript.txt as an array of lines
    $existingContent = Get-Content -Path $zscriptPath

    # Filter the content
    $filteredContent = $existingContent | Where-Object {
        $_ -notmatch '^// Auto' -and $_ -notmatch '^// ZZ' -and $_ -ne ''
    }

    # Write the updated content back to zscript.txt
    Set-Content -Path $zscriptPath -Value $filteredContent
    Write-Host "[ - OK - ] - Cleaned specified content from zscript.txt" @script:successColors
}

function Write-ZscriptInclude {
    Write-Host "`nAppending include statement to zscript.txt..." @script:warningColors

    # Construct the path to zscript.txt in the project root directory
    $zscriptPath = Join-Path -Path $script:project_root_directory -ChildPath "zscript.txt"

    # Check if zscript.txt exists
    if (-not (Test-Path $zscriptPath)) {
        Write-Host "`n[ - ERROR - ] - zscript.txt not found." @script:errorColors
        return
    }

    # Escape the project_root_directory for regex
    $escapedProjectRoot = [regex]::Escape($script:project_root_directory)

    # Format the path to be relative and with forward slashes
    $relativePath = $script:ZscriptActorSidecarFilePath -replace "^$escapedProjectRoot\\", "" -replace "\\", "/"

    # Construct the include statement
    $currentDate = Get-Date
    $includeStatement = "#include `"$relativePath`" // ZA__autogen__gdszu $currentDate"

    # Append the include statement to zscript.txt
    Add-Content -Path $zscriptPath -Value $includeStatement
    Write-Host "`n[ - OK - ] - Appended include statement to zscript.txt" @script:successColors
}

function Debug-ExtremelyElegantFixCompletionMessage {
    Write-Host "`n/////////////////////////////////////////////////////" @script:infoColors
    Write-Host "[ -- INFO -- ] - Hacky bullshit is now complete..." @script:infoColors
    Write-Host "/////////////////////////////////////////////////////" @script:infoColors
}

function Debug-CleanZscriptActorsAuto {
    # Construct the path to the 'zscript_actors_auto' folder inside 'zscript'
    $zscriptActorsAutoPath = Join-Path -Path "$script:project_root_directory\zscript" -ChildPath "zscript_actors_auto"

    # Check if the directory exists
    if (Test-Path $zscriptActorsAutoPath) {
        # Try to remove the directory and capture any potential errors
        try {
            Remove-Item -Path $zscriptActorsAutoPath -Recurse -Force
            Write-Host "[ - OK - ] - 'zscript_actors_auto' folder deleted from 'zscript'." @script:successColors
        } catch {
            Write-Host "[ - ERROR - ] - Failed to delete 'zscript_actors_auto' folder. Details: $_" @script:errorColors
        }
    } else {
        Write-Host "[ - INFO - ] - 'zscript_actors_auto' folder not found inside 'zscript'." @script:infoColors
    }
}

# !!!!! !!!!! !!!!! HACKY BULLSHIT END !!!!! !!!!! !!!!! 

# +++++ +++++ +++++ END OF FUNCTION DEFINITION BLOCK +++++ +++++ +++++

# ////////////////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////////////////
# ////////////////////////////////////////////////////////////////////////////////////////

# +++++ +++++ +++++ START OF EXECUTION BLOCK +++++ +++++ +++++

# //////////////////////////////////// [ ~ ZONE 1 ~ ] ////////////////////////////////////

# ---- title display ----

Show-FullTitleWithDeco

# ---- some initial checks ----

Get-ScriptDirectory
Debug-CheckResourcesFolder
Debug-CheckForModelProxy

# ---- prompt to select the project directory ----

Write-Host "`nSelect a project root directory (GUI)" @script:warningColors

# ---- user selects the project directoy----

$script:project_root_directory = Select-ProjectRootDirectory

# ---- project directory verification ----

Test-ProjectRootDirectory

# ---- project directory content verification (next 3 functions) ----

Test-StartupPrecheck
Test-ProjectSubfolders
Test-EssentialFilesAndFolders

# ---- these deal with previously existing files ----

Test-Make_Sure_Root_GLDEFS_Include_Exists
Test-Make_Sure_Root_MODELDEF_Include_Exists

# ---- lets me know the project directory setup is done (for debug purposes) ----

Write-Host "`n[ - DEBUG - ] - Project folder setup is complete. Moving on to the material import phase." @script:debugColors

# //////////////////////////////////// [ ~ ZONE 2 ~ ] ////////////////////////////////////

# ---- this is the texture import part ----

Write-Host "`nSelect a texture source directory (GUI)" @script:warningColors

# ---- texture import (next 10 functions) ----

Select-TextureImportSourceDirectory
Find-TextureFiles
Show-TextureSourceFiles
Invoke-RandomTextureName
Show-RandomTextureName
Set-MaterialPaths
Set-RemapTextureSourceDirectories
Debug-ShowTexSrcDestMapping
Copy-TexturesToDestination
Debug-VerifyCopiedTextures

#   ---- texture GLDEFs entry (next 2 functions) ----

Debug-CheckProjectAgain
Write-Append_Texture_Entry_to___gzdsu_auto_gldefs_gl

Write-Host "`n[ - DEBUG - ] - Material import complete. Moving on to the model import phase." @script:debugColors

# //////////////////////////////////// [ ~ ZONE 2.5 ~ ] ////////////////////////////////////

Show-BrightmapImportPrompt
Find-BrightmapImportSource
Show-BrightmapImportDebugInfo

# //////////////////////////////////// [ ~ ZONE 3 ~ ] ////////////////////////////////////

Show-AskImport3DModel

Write-Host "`nChecking /models and /sprite directory paths . . ."  @script:warningColors

Set-ModelAndSpriteDirectoryPaths
Debug-CheckModelAndSpriteDirectoryPaths

Write-Host "`nChecking /models/models_auto and /sprites/sprites_auto directory paths . . ."  @script:warningColors

Set-ModelAutomationPath
Set-SpriteAutomationPath
Debug-CheckModelAutomationPath
Debug-CheckSpriteAutomationPath
Set-ZscriptRootPath
Write-ZscriptRoot_ZscriptAutoInclude
Set-ZscriptAutoPath
Debug-CheckZscriptAndZscriptAutoPathVariables
Write-ZscriptAutoHeader 

Write-Host "`nSelect a model source directory (GUI)" @script:warningColors
$script:model_import_source_folder = Select-ModelImportSourceFolder

Test-ModelImportSourceFolder
Test-ObjFilesInModelSourceFolder

Invoke-RandomSpriteName
Test-RandomSpriteName

Copy-ModelProxySprite
Copy-3DModel

Set-ZScriptActorsAutoFolder
Set-UserDefinedActorName
Set-ZscriptActorDefinition
# Debug-ZscriptActorDefinitionCheck

Invoke-MAPINFO
Debug-Check_MAPINFO

Get-JustTheModelFilenameForModeldef
Write-DoomEdNums
Write-Modeldef

# //////////////////////////////////// [ ~ ZONE 4 ~ ] ////////////////////////////////////

Invoke-ExtremelyElegantFix
Debug-ExtractZscriptActor
Debug-DisplayZscriptActorCopyBuffer
Debug-CreateActorsFolderInZscript
Write-ActorToFile
Debug-CleanZscriptFile
Write-ZscriptInclude
Debug-CleanZscriptActorsAuto 
Debug-ExtremelyElegantFixCompletionMessage

# ---- lets me know the whole thing is done (for debug purposes) ----

Debug-EndOfScript

# +++++ +++++ +++++ END OF EXECUTION BLOCK +++++ +++++ +++++