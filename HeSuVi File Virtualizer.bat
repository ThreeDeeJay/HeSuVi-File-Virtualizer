::Script by 3DJ
::Special thanks to UnionRings, AsianAreAsian and sintrode

@ECHO OFF
SETLOCAL EnableDelayedExpansion
pushd "%~dp0"

::Version
Set "ScriptName=HeSuVi File Virtualizer"
Set "ScriptVersion=1.0"
Set "ScriptNameVersion=!ScriptName! v!ScriptVersion!"
::Store input file full path into variable
SET "InputPath=%~1"
::Extract input folder path, filename, extension and filename.extension as variables from full path
For %%I in ("!InputPath!") do (
	    SET "InputFolder=%%~dpI"
	    SET "InputFileName=%%~nI"
	    SET "InputFileExtension=%%~xI"
	    SET "InputFile=%%~nxI"
	    )
::Set HeSuVi executable and HRIR paths
set "HeSuViFolder=%ProgramFiles%\EqualizerAPO\config\HeSuVi"
set "HeSuViExecutable=%HeSuViFolder%\HeSuVi.exe"
set "TempFolder=Output\Temp"
set "LogFilePath=!TempFolder!\Log.txt"
set "ConfigFilePath=Config.ini"
set "ToolsFolder=Resources\Tools"
set "FFmpegExe=!ToolsFolder!\FFmpeg\ffmpeg.exe"
set "SoXExe=!ToolsFolder!\SoX\sox.exe"
set "initoolExe=!ToolsFolder!\initool\initool.exe"

::Settings
	if exist !ConfigFilePath! (
		for /f "delims=" %%A in ('!initoolExe! g !ConfigFilePath! Settings OutputVideoFileFormat 		--value-only') do set "OutputVideoFileFormat=%%A"
		for /f "delims=" %%A in ('!initoolExe! g !ConfigFilePath! Settings OutputVideoFileFormat 		--value-only') do set "OutputVideoFileExtension=.%%A"
		for /f "delims=" %%A in ('!initoolExe! g !ConfigFilePath! Settings OutputAudioFileFormat 		--value-only') do set "OutputAudioFileFormat=%%A"
		for /f "delims=" %%A in ('!initoolExe! g !ConfigFilePath! Settings OutputAudioFileFormat 		--value-only') do set "OutputAudioFileExtension=.%%A"
		for /f "delims=" %%A in ('!initoolExe! g !ConfigFilePath! Settings OutputAudioBitrate 			--value-only') do set "OutputAudioBitrate=%%A"
		for /f "delims=" %%A in ('!initoolExe! g !ConfigFilePath! Settings HeSuViHRIR 					--value-only') do set "HeSuViHRIR=%%A"
		for /f "delims=" %%A in ('!initoolExe! g !ConfigFilePath! Settings OutputVideoFFmpegArguments 	--value-only') do set "OutputVideoFFmpegArguments=%%A"
		for /f "delims=" %%A in ('!initoolExe! g !ConfigFilePath! Settings OutputAudioFFmpegArguments 	--value-only') do set "OutputAudioFFmpegArguments=%%A"
		) else (
		set "OutputVideoFileExtension=.mkv"
		set "OutputVideoFileFormat=!OutputVideoFileExtension:.=!"
		set "OutputAudioFileExtension=.wav"
		set "OutputAudioFileFormat=!OutputAudioFileExtension:.=!"
		set "OutputAudioBitrate=128k"
		set "HeSuViHRIR=Common"
		)

::Output/temp
IF NOT EXIST Output (
	mkdir !TempFolder!
	) else (
	rmdir /s /q Output
	mkdir !TempFolder!
	)

::Check for drag and drop
IF NOT DEFINED InputPath (

	::From the top
	:FromTheTop

	cls

	::Intro
	title !ScriptNameVersion!
	call :PrintAndLog "[90m:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[0m"
	call :PrintAndLog "[90m::::::::::::::::::::::::::::[0m[1m !ScriptNameVersion! [0m[90m:::::::::::::::::::::::::::[0m"
	call :PrintAndLog "[90m::::::::::::::::[0m [90mBy 3DJ - github.com/ThreeDeeJay / Discord: 3DJ#5426[0m [90m::::::::::::::::[0m"
	call :PrintAndLog "[90m::::::::::[0m [90mScript that applies HeSuVi virtual surround to 7.1 input files[0m [90m:::::::::::[0m"
	call :PrintAndLog "[90m:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[0m"
	echo.
	::Window exe drag and drop
	call :PrintAndLog "Ways to virtualize audio or video files (one at a time):"
	call :PrintAndLog "A) Drag and drop file onto this window then press Enter."
	call :PrintAndLog "B) Drag and drop file onto the .bat file to start conversion immediately, skipping this info screen."
	call :PrintAndLog "C) Press Tab to cycle through files in this folder to select as input then press Enter."
	echo.
	call :PrintAndLog "Notes:"
	call :PrintAndLog "- Input sample rate needs to match HeSuVi HRIRs' (44100hz or 48000hz)."
	call :PrintAndLog "- Extra WAV files in this folder will be:"
	call :PrintAndLog "     - Added as new tracks, using filename without extension as label."
	call :PrintAndLog "     - Added without applying extra virtualization."
	call :PrintAndLog "- Only input file's main video track will be used, and copied without re-encoding."
	call :PrintAndLog "- Only input file's main audio track will be used, re-encoded only if required (MP4)."
	call :PrintAndLog "While processing, HeSuVi will be turned on and cycle through HRIRs, which also applies to system audio."
	echo.
	call :PrintAndLog "Settings:"
	call :PrintAndLog "- HRIR/s to use:        	!HeSuViHRIR:more\=!"
	call :PrintAndLog "- Output container format:  	!OutputVideoFileFormat!"
	call :PrintAndLog "- Output audio codec:  		!OutputAudioFileFormat!"
	if not !OutputAudioFileExtension!==.wav (call :PrintAndLog "- Audio output bitrate: 	!OutputAudioBitrate!")
	if defined OutputVideoFFmpegArguments (call :PrintAndLog "- FFmpeg video arguments: 	!OutputVideoFFmpegArguments!")
	if defined OutputAudioFFmpegArguments (call :PrintAndLog "- FFmpeg audio arguments: 	!OutputAudioFFmpegArguments!")
	call :PrintAndLog "*To change settings, press Enter without providing input."
	::Save settings:
	echo [Settings]> %ConfigFilePath%
	echo OutputVideoFileFormat=!OutputVideoFileFormat!>> %ConfigFilePath%
	echo OutputAudioFileFormat=!OutputAudioFileFormat!>> %ConfigFilePath%
	echo OutputAudioBitrate=!OutputAudioBitrate!>> %ConfigFilePath%
	echo HeSuViHRIR=!HeSuViHRIR!>> %ConfigFilePath%
	echo OutputVideoFFmpegArguments=!OutputVideoFFmpegArguments!>> %ConfigFilePath%
	echo OutputAudioFFmpegArguments=!OutputAudioFFmpegArguments!>> %ConfigFilePath%

	::Declare variable with placeholder value
	set InputPath=Null
	::Check for window drag and drop
	set /p InputPath=
	::Remove quotes from path
	set InputPath=!InputPath:"=!
	::Extract folder path and filename and save to separate variables
	For %%A in ("!InputPath!") do (
	    SET "InputFolder=%%~dpA"
		SET "InputFileName=%%~nA"
		SET "InputFileExtension=%%~xA"
		SET "InputFile=%%~nxA"
	    )

	::Open settings upon no input
	IF "!InputPath!"=="Null" (

		::SettingsConfiguration
		:SettingsConfiguration

		::HRIR selection
		cls
		call :PrintAndLog "Currently selected HeSuVi HRIR to use for virtualization: !HeSuViHRIR!"
		set count=0
		for %%x in ("C:\Program Files\EqualizerAPO\config\HeSuVi\hrir\*.wav") do (
		  set /a count=count+1
		  set choice[!count!]=%%~nx
		)
		set countmore=!count!
		for %%x in ("C:\Program Files\EqualizerAPO\config\HeSuVi\hrir\more\*.wav") do (
		  set /a countmore=countmore+1
		  set choicemore[!countmore!]=%%~nx
		)
		
		pushd %~dp0
		call :PrintAndLog "To change, select an option letter or number then press Enter."
		echo.
		::Print list of HRIRs
		call :PrintAndLog "A] All (Common + More)"
		echo.
		call :PrintAndLog " C] Common"
		for /l %%x in (1,1,!count!) do (
		   if %%x LEQ 9 (
				echo    %%x] !choice[%%x]!
			) else if %%x LEQ 99 (
				echo   %%x] !choice[%%x]!
			) else if %%x LEQ 999 (
				echo  %%x] !choice[%%x]!
			) else (
				echo %%x] !choice[%%x]!
			)
		)
		echo.

		call :PrintAndLog " M] More"
		set /a count=count+1
		for /l %%x in (!count!,1,!countmore!) do (
		   if %%x LEQ 9 (
				echo    %%x] !choicemore[%%x]!
			) else if %%x LEQ 99 (
				echo   %%x] !choicemore[%%x]!
			) else if %%x LEQ 999 (
				echo  %%x] !choicemore[%%x]!
			) else (
				echo %%x] !choicemore[%%x]!
			)
		)

		::Output format
		set /p selection=
		cls
		if !selection! LSS !count! (
			for /f "delims=" %%A in ("!selection!") do set "HeSuViHRIR=!choice[%%A]!"
			) else (
			for /f "delims=" %%A in ("!selection!") do set "HeSuViHRIR=more\!choicemore[%%A]!"
			)
		
		if !selection!==A (set "HeSuViHRIR=All")
		if !selection!==a (set "HeSuViHRIR=All")
		if !selection!==C (set "HeSuViHRIR=Common")
		if !selection!==c (set "HeSuViHRIR=Common")
		if !selection!==M (set "HeSuViHRIR=More")
		if !selection!==m (set "HeSuViHRIR=More")

		::Output video format
		cls
		call :PrintAndLog 			"Currently selected output video format:  !OutputVideoFileExtension!"
		set /p OutputVideoFileFormat=Press Enter to keep or input new format: .
		set "OutputVideoFileExtension=.!OutputVideoFileFormat!"

		::Output audio format
		cls
		call :PrintAndLog 			"Currently selected output audio format:  !OutputAudioFileExtension!"
		set /p OutputAudioFileFormat=Press Enter to keep or input new format: .
		set "OutputAudioFileExtension=.!OutputAudioFileFormat!"

		::Output audio bitrate
		if not !OutputAudioFileExtension!==.wav (
			cls
			call :PrintAndLog 		 "Currently selected output audio bitrate:  !OutputAudioBitrate!"
			set /p OutputAudioBitrate=Press Enter to keep or input new bitrate: 
			)
		
		::Output video FFmpeg Arguments
		cls
		call :PrintAndLog 				 "Extra FFmpeg video arguments:   			  !OutputVideoFFmpegArguments!"
		set /p OutputVideoFFmpegArguments=Press Enter to keep or input new arguments: 

		::Output audio FFmpeg Arguments
		cls
		call :PrintAndLog 				 "Extra FFmpeg audio arguments: 			  !OutputAudioFFmpegArguments!"
		set /p OutputAudioFFmpegArguments=Press Enter to keep or input new arguments: 

		goto :FromTheTop

		)

	cls

	::Proceed to conversion
	goto BeginProcess

) ELSE (
	::Begin process
	:BeginProcess

	::Check input-output compatibility
	IF "!InputFileExtension!"==".wav" (
			IF "!OutputVideoFileExtension!"==".mp4" (
				title INCOMPATIBLE FORMAT DETECTED
				call :PrintAndLog "WAV input not supported by MP4."
				call :PrintAndLog "If you continue, the script will change output format to MKV."
				pause
				set "OutputVideoFileExtension=.mkv"
				cls
			)
		)
	IF "!OutputAudioFileExtension!"==".wav" (
			IF "!OutputVideoFileExtension!"==".mp4" (
				title INCOMPATIBLE FORMAT DETECTED
				call :PrintAndLog "WAV input not supported by MP4."
				call :PrintAndLog "If you continue, the script will change output format to MKV."
				pause
				set "OutputVideoFileExtension=.mkv"
				cls
			)
		)

	::Intro
	title !ScriptNameVersion!
	
	echo.

	::Extract WAV from input
	call :PrintAndLog "Extracting main audio track from input..."
	echo.
	!FFmpegExe! -y -loglevel error -i "!InputPath!" "!InputFilename!-source.wav" 2> %LogFilePath%

	
	::Detect samplerate and change HRIR folder if needed
	call :PrintAndLog "Detecting sample rate..."
	echo.
	for /f "delims=" %%A in ('!SoXExe! --i -r "!InputFilename!-source.wav"') do set "InputSampleRate=%%A"
	if "!InputSampleRate!" == "44100" (
		SET "HeSuViHRIRfolder=!HeSuViFolder!\hrir\44"
	) else if "!InputSampleRate!" == "48000" (
		SET "HeSuViHRIRfolder=!HeSuViFolder!\hrir"
	) else (
		call :PrintAndLog "Input contains unsupported audio sample rate."
		call :PrintAndLog "Please, make sure the file is either 44100hz or 48000hz so it's compatible with HeSuVi HRIRs."
		pause
		exit
	)

	::Convert extra WAV files, normalize and encode to AAC
	call :PrintAndLog "Converting external WAV files..."
	echo.
	for %%A in ("*.wav") do (
		if not "%%~nxA"=="!InputFile!" (
			if not "%%~nxA"=="!InputFilename!-source.wav" (
					if not !OutputAudioFileExtension!==.wav (
						!FFmpegExe! -y -loglevel error -i "%%~nxA" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -b:a !OutputAudioBitrate! "%%~nA!OutputAudioFileExtension!" 2> %LogFilePath%
					)
				)
			)
		)

	::Iterate through all HeSuVi HRIRs
	if !HeSuViHRIR!==All (
		for %%A in ("!HeSuViHRIRfolder!\*.wav") do (
			::Enable HeSuVi and cycle through HRIRs
			"!HeSuViExecutable!" -deactivateeverything 0 -virtualization "%%~nA.wav"
	
			::Apply HRIR to extracted WAV
			call :PrintAndLog "Applying %%~nA.wav..."
			"C:\Program Files\EqualizerAPO\Benchmark.exe" --nopause -i "!InputFilename!-source.wav" -o "%%~nA.wav" >>%LogFilePath%
	
			::Downmix to discard extra channels, normalize and encode to AAC
			IF "!OutputAudioFileExtension!"==".ogg" (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -c:a libopus -vbr on -b:a !OutputAudioBitrate! !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				) else if "!OutputAudioFileExtension!"==".wav" (
				call :PrintAndLog "Discarding empty channels..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR"                                                                                         !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				del "%%~nA.wav"
				) else (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -b:a !OutputAudioBitrate!                               !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				)
			echo.
		)
		for %%A in ("!HeSuViHRIRfolder!\more\*.wav") do (
			::Enable HeSuVi and cycle through HRIRs
			"!HeSuViExecutable!" -deactivateeverything 0 -virtualization "more\%%~nA.wav"
	
			::Apply HRIR to extracted WAV
			call :PrintAndLog "Applying %%~nA.wav..."
			"C:\Program Files\EqualizerAPO\Benchmark.exe" --nopause -i "!InputFilename!-source.wav" -o "%%~nA.wav" >>%LogFilePath%
	
			::Downmix to discard extra channels, normalize and encode to AAC
			IF "!OutputAudioFileExtension!"==".ogg" (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -c:a libopus -vbr on -b:a !OutputAudioBitrate! !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				) else if "!OutputAudioFileExtension!"==".wav" (
				call :PrintAndLog "Discarding empty channels..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR"                                                                                         !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				del "%%~nA.wav"
				) else (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -b:a !OutputAudioBitrate!                               !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				)
			echo.
		)
	) else if !HeSuViHRIR!==Common (
		for %%A in ("!HeSuViHRIRfolder!\*.wav") do (
			::Enable HeSuVi and cycle through HRIRs
			"!HeSuViExecutable!" -deactivateeverything 0 -virtualization "%%~nA.wav"
	
			::Apply HRIR to extracted WAV
			call :PrintAndLog "Applying %%~nA.wav..."
			"C:\Program Files\EqualizerAPO\Benchmark.exe" --nopause -i "!InputFilename!-source.wav" -o "%%~nA.wav" >>%LogFilePath%
	
			::Downmix to discard extra channels, normalize and encode to AAC
			IF "!OutputAudioFileExtension!"==".ogg" (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -c:a libopus -vbr on -b:a !OutputAudioBitrate! !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				) else if "!OutputAudioFileExtension!"==".wav" (
				call :PrintAndLog "Discarding empty channels..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR"                                                                                         !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				del "%%~nA.wav"
				) else (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -b:a !OutputAudioBitrate!                               !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				)
			echo.
		)
	) else if !HeSuViHRIR!==More (
		for %%A in ("!HeSuViHRIRfolder!\more\*.wav") do (
			::Enable HeSuVi and cycle through HRIRs
			"!HeSuViExecutable!" -deactivateeverything 0 -virtualization "more\%%~nA.wav"
	
			::Apply HRIR to extracted WAV
			call :PrintAndLog "Applying %%~nA.wav..."
			"C:\Program Files\EqualizerAPO\Benchmark.exe" --nopause -i "!InputFilename!-source.wav" -o "%%~nA.wav" >>%LogFilePath%
	
			::Downmix to discard extra channels, normalize and encode to AAC
			IF "!OutputAudioFileExtension!"==".ogg" (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -c:a libopus -vbr on -b:a !OutputAudioBitrate! !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				) else if "!OutputAudioFileExtension!"==".wav" (
				call :PrintAndLog "Discarding empty channels..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR"                                                                                         !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				del "%%~nA.wav"
				) else (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "%%~nA.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -b:a !OutputAudioBitrate!                               !OutputAudioFFmpegArguments! "HeSuVi - %%~nA.!OutputAudioFileFormat!"
				)
			echo.
		)
	) else (
		::Enable HeSuVi and select HRIR
		"!HeSuViExecutable!" -deactivateeverything 0 -virtualization "!HeSuViHRIR!.wav"

		::Apply HRIR to extracted WAV
		call :PrintAndLog "Applying !HeSuViHRIR!..."
		"C:\Program Files\EqualizerAPO\Benchmark.exe" --nopause -i "!InputFilename!-source.wav" -o "!HeSuViHRIR:more\=!.wav" >>%LogFilePath%

		::Downmix to discard extra channels, normalize and encode to AAC
			IF "!OutputAudioFileExtension!"==".ogg" (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "!HeSuViHRIR:more\=!.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -c:a libopus -vbr on -b:a !OutputAudioBitrate! !OutputAudioFFmpegArguments! "HeSuVi - !HeSuViHRIR:more\=!.!OutputAudioFileFormat!"
				) else if "!OutputAudioFileExtension!"==".wav" (
				call :PrintAndLog "Discarding empty channels..."
				!FFmpegExe! -loglevel error -y -i "!HeSuViHRIR:more\=!.wav" -af "pan=stereo|c0=FL|c1=FR"                                                                                         !OutputAudioFFmpegArguments! "HeSuVi - !HeSuViHRIR:more\=!.!OutputAudioFileFormat!"
				del "!HeSuViHRIR:more\=!.wav"
				) else (
				call :PrintAndLog "Downmixing, normalizing and encoding..."
				!FFmpegExe! -loglevel error -y -i "!HeSuViHRIR:more\=!.wav" -af "pan=stereo|c0=FL|c1=FR, loudnorm" -ar !InputSampleRate! -b:a !OutputAudioBitrate!                               !OutputAudioFFmpegArguments! "HeSuVi - !HeSuViHRIR:more\=!.!OutputAudioFileFormat!"
				)
		echo.
	)
	
	::Cleanup
	call :PrintAndLog "Deleting temporary files..."
	del "!InputFilename!-source.wav"
	echo.

	::Disable HeSuVi to test output
	call :PrintAndLog "Resetting HeSuVi..."
	echo.
	"!HeSuViExecutable!" -deactivateeverything 1

	::Virtualization complete
	call :PrintAndLog "Virtualization complete."
	call :PrintAndLog "Press any key to add virtualized tracks to the input video and delete them,"
	call :PrintAndLog "or close this window if you just want the virtualized WAV (lossless) or !OutputAudioFileFormat! files."
	call :PrintAndLog "Note: due to how batch processing of HRIR works, HeSuVi has been set to the last HRIR and turned off."
	echo.
	pause

	cls

	::Combine all tracks
	set count=0
	for %%A in ("*!OutputAudioFileExtension!") do (
	  set /a count=!count!+1
	  set "map=!map! -map !count!:a"
	  set "i=!i! -i "%%~nxA""
	)
	if "!InputFileExtension!"==".wav" (
		set count=0
		) else (
		set count=1
		)
	for %%A in ("*!OutputAudioFileExtension!") do (
	  set /a count=!count!+1
	  set "metadata=!metadata! -metadata:s:!count! handler_name="%%~nA""
	)
	call :PrintAndLog "Merging all tracks..."
	echo.
	if "!InputFileExtension!"==".wav" (
			!FFmpegExe! -loglevel error -y -i "!InputPath!" !i! -map 0:v?:0 -map 0:a:0 !map! -metadata:s:0 handler_name="Source" !metadata! !OutputVideoFFmpegArguments! -codec copy "Output\!InputFilename!-Virtualized!OutputVideoFileExtension!"
		) else (
			!FFmpegExe! -loglevel error -y -i "!InputPath!" !i! -map 0:v?:0 -map 0:a:0 !map! -metadata:s:1 handler_name="Source" !metadata! !OutputVideoFFmpegArguments! -codec copy "Output\!InputFilename!-Virtualized!OutputVideoFileExtension!"
		)

	::Cleanup
	call :PrintAndLog "Performing cleanup..."
	echo.
	for %%A in ("*!OutputAudioFileExtension!") do (
		del "%%~nA!OutputAudioFileExtension!"
		)
	for %%A in ("!HeSuViHRIRfolder!\*.wav") do (
		if exist "%%~nA.wav" (
			del "%%~nA.wav"
			)
		)
	for %%A in ("!HeSuViHRIRfolder!\more\*.wav") do (
		if exist "%%~nA.wav" (
			del "%%~nA.wav"
			)
		)

	::Complete
	call :PrintAndLog "Virtualized audio tracks have been combined with the input."
	call :PrintAndLog "Continue to the Output folder?"
	pause
	start Output
	exit
)

::Print and log
:PrintAndLog
echo %~1
echo %~1 >>%LogFilePath%
EXIT /B 0