# https://siptv.eu/howto/playlist.html
# https://siptv.eu/codes/

Param(
  [alias('csv')]
  [string]$InputCSV
)

Add-Type -AssemblyName System.Web

If (!$InputCSV) {
	Write-Error 'Parameter -InputCSV not set!'
	exit 0
} Else {
	If (-Not (Test-Path $InputCSV)) {
		Write-Error $($InputCSV+' does not exist!')
		exit 0
	} Else {
		$Output = $InputCSV+'.m3u'
	}
}

$Channels = Import-Csv -Delimiter "," -Path $InputCSV | Sort -Property 'nr'

$Header = '#EXTM3U'
Write-Host $Header
Set-Content -Path $Output -Value $Header

ForEach ($Channel in $Channels){ 
	$tvg_name = $Channel.'tvg-name'
	$tvg_id = $Channel.'tvg-id'
	$group_title = $Channel.'group-title'
	$tvg_logo = [System.Web.HttpUtility]::UrlDecode($Channel.'tvg-logo')
	$stream = [System.Web.HttpUtility]::UrlDecode($Channel.url)
	$service_name = $tvg_name.Replace(" ", "\ ")
	$service_provider = $group_title.Replace(" ", "\ ")

	$Line = '#EXTINF:-1 tvg-name="{0}" tvg-id="{1}" group-title="{2}" tvg-logo="{3}",{4}' -f $tvg_name, $tvg_id, $group_title, $tvg_logo, $tvg_name
	Write-Host $Line
	Add-Content -Path $Output -Value $Line
	
	$Line = 'pipe:///usr/bin/ffmpeg -loglevel fatal -i {0} -vcodec copy -acodec copy -metadata service_name={1} -metadata service_provider={2} -mpegts_service_type advanced_codec_digital_sdtv -f mpegts pipe:1' -f $stream, $service_name, $service_provider
	Write-Host $Line
	Add-Content -Path $Output -Value $Line
}
