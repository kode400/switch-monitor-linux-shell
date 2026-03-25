#!/bin/bash

declare -a listMonitorConnected=()
nameMonitorConnectedPrimary=''
declare -a listMonitorResolutionPrimary=()
declare -a listMonitorResolution=()
declare -a listMonitorResolutionSecondary=()
recomendationResolution=''
recomendationResolutionTop=''

getListMonitorConnected(){

	listMonitorConnected=($(xrandr | grep  " connected " | awk '{ print$1 }'))
}

getMonitorConnected(){
	nameMonitorConnectedPrimary=$(xrandr | grep  " connected " | grep "primary" | awk '{ print$1 }')
}

getListMonitorResolution(){
	monitorName=$1

	listMonitorResolution=($(xrandr | awk -v monitor="^$monitorName connected" '/connected/ {p = 0} $0 ~ monitor {p = 1} p { print$1 }' | awk 'NR>1'))
	
}

getMonitorResolution(){
	monitorName=$1

	recomendationResolution=($(xrandr | awk -v monitor="^$monitorName connected" '/connected/ {p = 0} $0 ~ monitor {p = 1} p { print }' | awk 'NR > 1' | grep '+' | awk '{ print$1 }'))
	
}

getMonitorResolutionTop(){
	monitorName=$1

	recomendationResolutionTop=($(xrandr | awk -v monitor="^$monitorName connected" '/connected/ {p = 0} $0 ~ monitor {p = 1} p { print$1 }' | awk 'NR > 1' | awk 'NR==1{print $1}'))
	
}

setMonitorPrimary(){
	gnameMonitorConnected=''
	getListMonitorConnected
	getMonitorConnected
	lengthMonitorConnected="${#listMonitorConnected[@]}"

	if (($lengthMonitorConnected > 0)); then
		for monitorConnected in "${listMonitorConnected[@]}"
		 	do	
		 		if [[ $nameMonitorConnectedPrimary != $monitorConnected ]]; then
					nameMonitorConnected=$monitorConnected
					break
				fi

		done
	fi
	
	if [[ $nameMonitorConnected != '' ]]; then
		$(xrandr --output $nameMonitorConnected --auto --primary)
	fi
}

setJoinMonitor(){
	nameMonitorConnected=''
	getListMonitorConnected
	getMonitorConnected
	lengthMonitorConnected="${#listMonitorConnected[@]}"

	if (($lengthMonitorConnected > 0)); then
		for monitorConnected in "${listMonitorConnected[@]}"
		 	do	
		 		if [[ $nameMonitorConnectedPrimary != $monitorConnected ]]; then
					nameMonitorConnected=$monitorConnected
					break
				fi

		done
	fi
	
	joinSide="left"
	param1=${1,,}
	if [[ $param1 != '' ]]; then
		if [[ $param1 == "left" || $param1 == "right" ]]; then
		joinSide=$param1
		fi
	fi
	
	getMonitorResolution "$nameMonitorConnectedPrimary"
	getMonitorResolutionTop "$nameMonitorConnectedPrimary"
	recomendationResolutionTopPrimary=$recomendationResolutionTop
	recomendationResolutionPrimary=$recomendationResolution
	
	getMonitorResolution "$nameMonitorConnected"
	getMonitorResolutionTop "$nameMonitorConnected"
	recomendationResolutionTopSecondary=$recomendationResolutionTop
	recomendationResolutionSecondary=$recomendationResolution
	
	primaryResolution=''
	secondaryResolution=''
	
	if [[ $nameMonitorConnected != '' ]]; then
	
		if [[ $recomendationResolutionTopPrimary == $recomendationResolutionPrimary ]]; then
			primaryResolution=$recomendationResolutionPrimary
		else
			primaryResolution=$recomendationResolutionTopPrimary				
		fi
		
		if [[ $recomendationResolutionTopSecondary == $recomendationResolutionSecondary ]]; then
			secondaryResolution=$recomendationResolutionSecondary
		else
			secondaryResolution=$recomendationResolutionTopSecondary				
		fi
							
		if [[ $primaryResolution != '' && $secondaryResolution != '' ]]; then
		$(xrandr --output $nameMonitorConnectedPrimary --mode $primaryResolution)
		$(xrandr --output $nameMonitorConnected --mode $secondaryResolution --$joinSide-of $nameMonitorConnectedPrimary)
		fi
	fi
	
}

setMirrorMonitor(){
	nameMonitorConnected=''
	getListMonitorConnected
	getMonitorConnected
	lengthMonitorConnected="${#listMonitorConnected[@]}"

	if (($lengthMonitorConnected > 0)); then
		for monitorConnected in "${listMonitorConnected[@]}"
		 	do	
		 		if [[ $nameMonitorConnectedPrimary != $monitorConnected ]]; then
					nameMonitorConnected=$monitorConnected
					break
				fi

		done
	fi
	
	getListMonitorResolution "$nameMonitorConnectedPrimary"
	listMonitorResolutionPrimary=("${listMonitorResolution[@]}")
	lengthMonitorResolutionPrimary="${#listMonitorResolutionPrimary[@]}"
	
	getListMonitorResolution "$nameMonitorConnected"
	listMonitorResolutionSecondary=("${listMonitorResolution[@]}")
	lengthMonitorResolutionSecondary="${#listMonitorResolutionSecondary[@]}"
	
	monitorResolution=''
	
	
	if (($lengthMonitorResolutionPrimary > 0 && lengthMonitorResolutionSecondary > 0)); then
		for monitorResolutionPrimary in "${listMonitorResolutionPrimary[@]}"
		 	do	
		 		if [[ ${listMonitorResolutionSecondary[@]} =~ $monitorResolutionPrimary ]]
				then
				  monitorResolution=$monitorResolutionPrimary
				  break
				fi

		done
	fi
	
	if [[ $nameMonitorConnected != '' && $monitorResolution != '' ]]; then
		$(xrandr --output $nameMonitorConnectedPrimary --mode $monitorResolution --output $nameMonitorConnected --same-as $nameMonitorConnectedPrimary --mode $monitorResolution)
	fi
	
	
}

setSingleMonitor(){
	nameMonitorConnected=''
	getListMonitorConnected
	getMonitorConnected
	lengthMonitorConnected="${#listMonitorConnected[@]}"
	getMonitorResolution "$nameMonitorConnectedPrimary"
	getMonitorResolutionTop "$nameMonitorConnectedPrimary"

	if (($lengthMonitorConnected > 0)); then
		for monitorConnected in "${listMonitorConnected[@]}"
		 	do	
		 		if [[ $nameMonitorConnectedPrimary != $monitorConnected ]]; then
					nameMonitorConnected=$monitorConnected
					if [[ $nameMonitorConnected != '' ]]; then
						if [[ $recomendationResolutionTop == $recomendationResolution ]]; then
							$(xrandr --output $nameMonitorConnectedPrimary --mode $recomendationResolution --output $nameMonitorConnected --off)
							else
							$(xrandr --output $nameMonitorConnectedPrimary --mode $recomendationResolutionTop --output $nameMonitorConnected --off)
					fi
				fi
				fi

		done
	fi
}
